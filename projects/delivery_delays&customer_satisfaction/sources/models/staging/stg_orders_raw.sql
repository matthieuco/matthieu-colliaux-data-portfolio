SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    CAST(order_delivered_customer_date AS DATE) AS delivered_date,
    CAST(order_estimated_delivery_date AS DATE) AS estimated_delivery_date
FROM {{ source('olist_raw_dataset', 'olist_orders') }}
