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
    FROM {{ ref('stg_customers') }}
    GROUP BY
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
) t
WHERE rn = 1