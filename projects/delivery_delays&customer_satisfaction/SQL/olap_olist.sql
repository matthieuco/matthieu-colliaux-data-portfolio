-------- OLAP SCHEMA CREATION for ANALYSIS --------
/* DEFINITION of the "GRAIN" of the fact_table at the order_level to align performance 
with customer satisfaction metrics 
ONE ROW, ONE DELIVERY, ONE SELLER, ONE CUSTOMER, ONE REVIEW (the one with the MAX CA) */

---- FIRST, DROP TABLES and VIEWS IF EXISTS
DROP VIEW IF EXISTS delivery_delay_View;
DROP VIEW IF EXISTS review_per_order_View;
DROP VIEW IF EXISTS stg_orders_View;
DROP VIEW IF EXISTS stg_reviews_View;
DROP VIEW IF EXISTS nbItemsAndValuePerOrder_View;
DROP VIEW IF EXISTS sellerPerOrder_View;
DROP TABLE IF EXISTS dim_sellers;
DROP TABLE IF EXISTS fact_deliveries;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_time;



------ Definition STAGING TABLES 

---- VIEW stg_orders
-- view creation with renaming and filters on order_status
CREATE OR REPLACE VIEW stg_orders_View AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::date AS order_date,
    order_delivered_customer_date::date AS delivered_date,
    order_estimated_delivery_date::date AS estimated_delivery_date
FROM olist_orders_dataset
WHERE order_status NOT IN ('canceled', 'unavailable');


---- VIEW stg_reviews	
CREATE OR REPLACE VIEW stg_reviews_View AS
SELECT
    order_id,
	review_id,
    review_score,
    review_creation_date::date AS review_date
FROM olist_order_reviews_dataset;

------ Definition VIEWS and METRICS used by FACT TABLE
/* CALCULATE day delay per order "Delivered" and label it "On Time; Delay" */

---- VIEW delivery_delay_View
CREATE OR REPLACE VIEW delivery_delay_View AS
SELECT 
	order_id,
	order_date,
	customer_id,
	delivered_date,
	estimated_delivery_date,
	(delivered_date-estimated_delivery_date) as delay_days,
	CASE
		WHEN (delivered_date-estimated_delivery_date <= 0) THEN FALSE
		WHEN (delivered_date-estimated_delivery_date > 0) THEN TRUE
	END as is_delayed
FROM stg_orders_View
WHERE order_status = 'delivered';

---- VIEW for Nb Items and value per Order
CREATE OR REPLACE VIEW nbItemsAndValuePerOrder_View AS
SELECT 
	order_id,
	SUM(price+freight_value) as order_value,
	COUNT(order_item_id) as nb_items_order
FROM olist_order_items_dataset group by order_id;

----- associate order to Seller with the MAX CA
CREATE OR REPLACE VIEW sellerPerOrder_View AS 
WITH cte_revenueOrderxSellers AS (
	select order_id, seller_id, SUM(price+freight_value) as revenueOrderxSellers
	from olist_order_items_dataset group by order_id,seller_id
),

cte_rankSellerOrder AS (
	select
	order_id,
	seller_id,
	revenueOrderxSellers,
	row_number() over(
	partition by order_id order by revenueOrderxSellers desc
	) as rnSeller
	from cte_revenueOrderxSellers
)

SELECT order_id, seller_id, revenueOrderxSellers from cte_rankSellerOrder WHERE rnSeller = 1;

COMMENT ON VIEW sellerPerOrder_View IS 'Assign each order to the seller with the highest revenue within the order';

----- GET the most recent review per Order
CREATE OR REPLACE VIEW review_per_order_View AS
WITH cte_rankedreviews AS (
	select 
	order_id,
	review_score,
	review_date,
	row_number() over(
	partition by order_id order by review_date desc
	) as last_review
	from stg_reviews_View
)
SELECT order_id,
	review_score,
	review_date
	from cte_rankedreviews where last_review = 1;
	
---- DEFINITION Dimensions TABLES
-- dimension customers
COMMENT ON TABLE dim_customers IS 'Make "customer_unique_id" unique to get a reel customers behind the row in the table not like customer_id';

CREATE TABLE dim_customers AS
SELECT
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM (
    SELECT
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        COUNT(*) AS cnt,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM olist_customers_dataset
    GROUP BY
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
) t
WHERE rn = 1;

ALTER TABLE dim_customers
ADD CONSTRAINT dim_customers_pkey PRIMARY KEY (customer_unique_id);

-- dimension sellers
CREATE TABLE dim_sellers AS
WITH cte_orderSellers AS (
	select oidt.seller_id, COUNT(stg_ov.order_id) as nbOrder, SUM(oidt.price+oidt.freight_value) as totalRevenue
	from olist_sellers_dataset as osd JOIN olist_order_items_dataset as oidt
	ON osd.seller_id=oidt.seller_id 
	JOIN stg_orders_View as stg_ov ON stg_ov.order_id = oidt.order_id group by oidt.seller_id
)

SELECT
 osd.seller_id,
 osd.seller_zip_code_prefix as zip_code,
 osd.seller_city as city,
 osd.seller_state as state,
 cte_os.nbOrder,
 cte_os.totalRevenue
FROM olist_sellers_dataset as osd JOIN
cte_orderSellers as cte_os 
ON osd.seller_id = cte_os.seller_id;

ALTER TABLE dim_sellers
ADD CONSTRAINT dim_sellers_pkey PRIMARY KEY (seller_id);

-- dimension time
/* GENERATE FROM DATE '2016-01-01' TO DATE '2019-12-31' */
CREATE TABLE dim_time (
    time_key        INT         PRIMARY KEY,   -- ex: 20170101
    date_yyyy_mm_dd     DATE        NOT NULL,

    day             INT         NOT NULL,
    day_name        VARCHAR(10) NOT NULL,
    day_of_week     INT         NOT NULL,       -- 1 = lundi
    week_of_year    INT         NOT NULL,

    month           INT         NOT NULL,
    month_name      VARCHAR(10) NOT NULL,
    quarter         INT         NOT NULL,
    year            INT         NOT NULL,

    is_weekend      BOOLEAN     NOT NULL,
    is_month_end    BOOLEAN     NOT NULL,
    is_quarter_end  BOOLEAN     NOT NULL,
    is_year_end     BOOLEAN     NOT NULL
);

INSERT INTO dim_time
SELECT
    CAST(TO_CHAR(d, 'YYYYMMDD') AS INT)        AS time_key,
    d                                          AS date_actual,

    EXTRACT(DAY FROM d)                        AS day,
    TO_CHAR(d, 'Day')                          AS day_name,
    EXTRACT(ISODOW FROM d)                     AS day_of_week,
    EXTRACT(WEEK FROM d)                       AS week_of_year,

    EXTRACT(MONTH FROM d)                      AS month,
    TO_CHAR(d, 'Month')                        AS month_name,
    EXTRACT(QUARTER FROM d)                    AS quarter,
    EXTRACT(YEAR FROM d)                       AS year,

    CASE WHEN EXTRACT(ISODOW FROM d) IN (6,7)
         THEN TRUE ELSE FALSE END              AS is_weekend,

    (d = (DATE_TRUNC('month', d) 
          + INTERVAL '1 month - 1 day'))       AS is_month_end,

    (d = (DATE_TRUNC('quarter', d) 
          + INTERVAL '3 month - 1 day'))       AS is_quarter_end,

    (d = (DATE_TRUNC('year', d) 
          + INTERVAL '1 year - 1 day'))        AS is_year_end

FROM generate_series(
    DATE '2016-01-01',
    DATE '2019-12-31',
    INTERVAL '1 day'
) AS d;


---- FACT TABLE fact_deliveries
CREATE TABLE fact_deliveries (
    order_id                    VARCHAR(32),
    customer_unique_id          VARCHAR(32),
    seller_id                   VARCHAR(32),

    order_date_key              INT NOT NULL,
    delivery_date_key           INT,
    estimated_delivery_date_key INT,
	delay_days                  NUMERIC,
	is_delayed					VARCHAR(32),
	review_score                INT,
	nb_items_order				INT,
    order_value                 NUMERIC(10,2),

	PRIMARY KEY (order_id),
    CONSTRAINT fk_order_date
        FOREIGN KEY (order_date_key)
        REFERENCES dim_time(time_key),

    CONSTRAINT fk_delivery_date
        FOREIGN KEY (delivery_date_key)
        REFERENCES dim_time(time_key),

    CONSTRAINT fk_estimated_date
        FOREIGN KEY (estimated_delivery_date_key)
        REFERENCES dim_time(time_key)
);

-- INSERT INTO fact_deliveries 
INSERT INTO fact_deliveries (
    order_id,
    customer_unique_id,
    seller_id,
    order_date_key,
    delivery_date_key,
    estimated_delivery_date_key,
	delay_days,
    is_delayed,
	review_score,
	nb_items_order,
    order_value
)
SELECT
    dd_v.order_id,
    dim_customer.customer_unique_id,
    spo.seller_id,

    CAST(TO_CHAR(dd_v.order_date, 'YYYYMMDD') AS INT)
        AS order_date_key,

    CAST(TO_CHAR(dd_v.delivered_date, 'YYYYMMDD') AS INT)
        AS delivery_date_key,

    CAST(TO_CHAR(dd_v.estimated_delivery_date, 'YYYYMMDD') AS INT)
        AS estimated_delivery_date_key,
		
	dd_v.delay_days,	
	dd_v.is_delayed,
	rpov.review_score,
    nvp.nb_items_order,
	nvp.order_value

from delivery_delay_View as dd_v
JOIN dim_customers as dim_customer ON dd_v.customer_id = dim_customer.customer_id
JOIN sellerPerOrder_View as spo ON dd_v.order_id = spo.order_id
JOIN nbItemsAndValuePerOrder_View as nvp ON dd_v.order_id = nvp.order_id
JOIN review_per_order_View as rpov ON dd_v.order_id = rpov.order_id;

----- INDEX CREATION TO Optimize REQUESTS
CREATE INDEX idx_fact_seller ON fact_deliveries(seller_id);
CREATE INDEX idx_fact_customer ON fact_deliveries(customer_unique_id);
CREATE INDEX idx_fact_order_date ON fact_deliveries(order_date_key);

CREATE INDEX idx_fact_is_delayed ON fact_deliveries(is_delayed);
CREATE INDEX idx_fact_review_score ON fact_deliveries(review_score);

------ DATA QUALITY CHECK & GRAIN
-- Review fact table
/*SELECT order_id, COUNT(*) FROM fact_deliveries
GROUP BY order_id HAVING COUNT(*) > 1;

-- Review uniqueness
SELECT order_id, COUNT(*) FROM review_per_order_View
GROUP BY order_id HAVING COUNT(*) > 1;*/