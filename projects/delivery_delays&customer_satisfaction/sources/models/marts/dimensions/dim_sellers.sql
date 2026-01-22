WITH orderSellers AS (
	select 
        oidt.seller_id, 
        COUNT(stg_ov.order_id) as nbOrder, 
        SUM(oidt.price+oidt.freight_value) as totalRevenue
	from {{ ref('stg_sellers') }} as osd JOIN {{ ref('stg_order_items') }} as oidt
	ON osd.seller_id=oidt.seller_id 
	JOIN {{ ref('stg_orders') }} as stg_ov ON stg_ov.order_id = oidt.order_id group by oidt.seller_id
)

SELECT
 osd.seller_id,
 osd.seller_zip_code_prefix as zip_code,
 osd.seller_city as city,
 osd.seller_state as state,
 cte_os.nbOrder,
 cte_os.totalRevenue
FROM {{ ref('stg_sellers') }} as osd JOIN
orderSellers as cte_os 
ON osd.seller_id = cte_os.seller_id