WITH revenue_per_seller AS (
	select order_id, seller_id, 
    SUM(price+freight_value) as revenueOrderxSellers
	from {{ ref('stg_order_items') }}
    group by order_id,seller_id
),

rankSellerOrder AS (
	select
	order_id,
	seller_id, 
	revenueOrderxSellers,
	row_number() over(
	partition by order_id order by revenueOrderxSellers desc
	) as rnSeller
	from revenue_per_seller
)

SELECT 
    order_id, 
    seller_id, 
    revenueOrderxSellers 
from rankSellerOrder 
WHERE rnSeller = 1