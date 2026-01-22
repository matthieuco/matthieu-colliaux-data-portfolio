SELECT
    dd_v.order_id,
    dim_customer.customer_unique_id,
    spo.seller_id,

    CAST(FORMAT_DATE('%Y%m%d', dd_v.order_date) AS INT64)
        AS order_date_key,

    CAST(FORMAT_DATE('%Y%m%d', dd_v.delivered_date) AS INT64)
        AS delivery_date_key,

    CAST(FORMAT_DATE('%Y%m%d', dd_v.estimated_delivery_date) AS INT64)
        AS estimated_delivery_date_key,
		
	dd_v.delay_days,	
	dd_v.is_delayed,
	rpov.review_score,
    nvp.nb_items_order,
	nvp.order_value

from {{ ref('int_delivery_delay') }} as dd_v
JOIN {{ ref('dim_customers') }} as dim_customer ON dd_v.customer_unique_id = dim_customer.customer_unique_id
JOIN {{ ref('int_seller_per_order') }} as spo ON dd_v.order_id = spo.order_id
JOIN {{ ref('int_items_per_order') }} as nvp ON dd_v.order_id = nvp.order_id
JOIN {{ ref('int_review_per_order') }} as rpov ON dd_v.order_id = rpov.order_id