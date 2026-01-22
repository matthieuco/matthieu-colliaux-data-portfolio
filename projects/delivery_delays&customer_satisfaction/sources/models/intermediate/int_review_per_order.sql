WITH rankedreviews AS (
	select 
	order_id,
	review_score,
	review_date,
	row_number() over(
	partition by order_id order by review_date desc
	) as last_review
	from {{ ref('stg_reviews') }}
)
SELECT 
    order_id,
	review_score,
	review_date
from rankedreviews 
where last_review = 1