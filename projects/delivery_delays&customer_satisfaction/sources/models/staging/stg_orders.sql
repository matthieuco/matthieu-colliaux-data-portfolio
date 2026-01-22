SELECT *
FROM {{ ref('stg_orders_raw') }}
WHERE order_status NOT IN ('canceled', 'unavailable')