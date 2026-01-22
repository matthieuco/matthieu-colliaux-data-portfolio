SELECT 
	order_id,
	order_date,
	customers.customer_unique_id,
	delivered_date,
	estimated_delivery_date,
	DATE_DIFF(delivered_date, estimated_delivery_date, DAY) as delay_days,
	CASE
		WHEN DATE_DIFF(delivered_date, estimated_delivery_date, DAY) <= 0 THEN FALSE
		WHEN DATE_DIFF(delivered_date, estimated_delivery_date, DAY) > 0 THEN TRUE
	END as is_delayed
FROM {{ ref('stg_orders') }} AS orders JOIN {{ ref('stg_customers') }} AS customers
ON orders.customer_id = customers.customer_id
WHERE order_status = 'delivered'    