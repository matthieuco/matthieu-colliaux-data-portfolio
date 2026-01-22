SELECT 
	order_id,
	SUM(price+freight_value) as order_value,
	COUNT(order_item_id) as nb_items_order
FROM {{ ref('stg_order_items') }} group by order_id