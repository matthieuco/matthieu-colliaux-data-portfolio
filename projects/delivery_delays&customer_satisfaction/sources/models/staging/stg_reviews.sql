SELECT
    order_id,
	review_id,
    CAST(review_score AS INT64) AS review_score,
    CAST(review_creation_date AS DATE) AS review_date
FROM {{ source('olist_raw_dataset', 'olist_order_reviews') }}