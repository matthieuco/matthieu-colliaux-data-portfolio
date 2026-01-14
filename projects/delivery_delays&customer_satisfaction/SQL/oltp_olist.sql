-------- OLTP SCHEMA CREATION --------
---- FIRST, DROP TABLES IF EXISTS
DROP TABLE IF EXISTS product_category_name_translation CASCADE;
DROP TABLE IF EXISTS olist_geolocation_dataset CASCADE;
DROP TABLE IF EXISTS olist_order_items_dataset CASCADE;
DROP TABLE IF EXISTS olist_order_payments_dataset CASCADE;
DROP TABLE IF EXISTS olist_order_reviews_dataset CASCADE;
DROP TABLE IF EXISTS olist_sellers_dataset CASCADE;
DROP TABLE IF EXISTS olist_products_dataset CASCADE;
DROP TABLE IF EXISTS olist_orders_dataset CASCADE;
DROP TABLE IF EXISTS olist_customers_dataset CASCADE;


--------- TABLE  olist_customers_dataset 
CREATE TABLE olist_customers_dataset (
customer_id VARCHAR (50) PRIMARY KEY,
customer_unique_id VARCHAR (50) NOT NULL,
customer_zip_code_prefix VARCHAR(50) NOT NULL,
customer_city VARCHAR(50) NOT NULL,
customer_state VARCHAR(50) NOT NULL
);

--- copy .CSV to SQL
COPY olist_customers_dataset
FROM '/{path}/data/projetOlist/archive/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_sellers_dataset
CREATE TABLE olist_sellers_dataset (
seller_id VARCHAR(50) PRIMARY KEY,
seller_zip_code_prefix VARCHAR (50) NOT NULL,
seller_city  VARCHAR (50) NOT NULL,
seller_state VARCHAR (50) NOT NULL
);

--- copy .CSV to SQL
COPY olist_sellers_dataset
FROM '/{path}/data/projetOlist/archive/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_products_dataset
CREATE TABLE olist_products_dataset (
product_id VARCHAR(50) PRIMARY KEY,
product_category_name VARCHAR (50),
product_name_length INT,
product_description_length INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT
);

--- copy .CSV to SQL
COPY olist_products_dataset
FROM '/{path}/data/projetOlist/archive/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_orders_dataset
CREATE TABLE olist_orders_dataset (
order_id VARCHAR(50) PRIMARY KEY,
customer_id VARCHAR(50) REFERENCES olist_customers_dataset(customer_id),
order_status VARCHAR(50) NOT NULL,
order_purchase_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
order_approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
order_delivered_carrier_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
order_delivered_customer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
order_estimated_delivery_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--- copy .CSV to SQL
COPY olist_orders_dataset
FROM '/{path}/data/projetOlist/archive/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_order_reviews_dataset
CREATE TABLE olist_order_reviews_dataset (
review_id VARCHAR(50),
order_id VARCHAR(50) REFERENCES olist_orders_dataset(order_id) ON DELETE CASCADE,
review_score INT NOT NULL,
review_comment_title VARCHAR(50),
review_comment_message VARCHAR,
review_creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
review_answer_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--- copy .CSV to SQL
COPY olist_order_reviews_dataset
FROM '/{path}/data/projetOlist/archive/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_order_payments_dataset
CREATE TABLE olist_order_payments_dataset (
order_id VARCHAR(50) REFERENCES olist_orders_dataset(order_id) ON DELETE CASCADE,
payment_sequential NUMERIC NOT NULL,
payment_type VARCHAR(50) NOT NULL,
payment_installments INT NOT NULL,
payment_value NUMERIC NOT NULL
);

--- copy .CSV to SQL
COPY olist_order_payments_dataset
FROM '/{path}/data/projetOlist/archive/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_order_items_dataset
CREATE TABLE olist_order_items_dataset (
order_id VARCHAR(50) REFERENCES olist_orders_dataset(order_id) ON DELETE CASCADE,
order_item_id INT,
product_id VARCHAR(50) REFERENCES olist_products_dataset(product_id) ON DELETE CASCADE,
seller_id VARCHAR(50) REFERENCES olist_sellers_dataset(seller_id) ON DELETE CASCADE,
shipping_limit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
price NUMERIC NOT NULL,
freight_value NUMERIC NOT NULL
);

--- copy .CSV to SQL
COPY olist_order_items_dataset
FROM '/{path}/data/projetOlist/archive/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE olist_geolocation_dataset
CREATE TABLE olist_geolocation_dataset (
geolocation_zip_code_prefix INT NOT NULL,
geolocation_lat NUMERIC NOT NULL,
geolocation_lng NUMERIC NOT NULL,
geolocation_city VARCHAR(50) NOT NULL,
geolocation_state VARCHAR(50) NOT NULL
);

--- copy .CSV to SQL
COPY olist_geolocation_dataset
FROM '/{path}/data/projetOlist/archive/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;


--------- TABLE product_category_name_translation
CREATE TABLE product_category_name_translation (
product_category_name VARCHAR (50) NOT NULL,
product_category_name_english VARCHAR (50) NOT NULL
);

--- copy .CSV to SQL
COPY product_category_name_translation
FROM '/{path}/data/projetOlist/archive/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;

--------- CHECK TABLES LOAD
/*
SELECT DISTINCT COUNT(*) as distinctNBrows from product_category_name_translation;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_geolocation_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_order_items_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_order_payments_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_order_reviews_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_sellers_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_products_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_orders_dataset;
SELECT DISTINCT COUNT(*) as distinctNBrows from olist_customers_dataset;
*/