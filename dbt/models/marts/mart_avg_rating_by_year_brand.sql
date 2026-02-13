with reviews_enriched as (
select
r.product_id,
r.rating,
r.review_time,
r.review_year,
p.brand
from {{ ref('fct_reviews_granular') }} r
left join {{ ref('dim_products') }} p
on r.product_id = p.product_id

),

aggregated as (

select
brand,
--extract(year from review_timestamp) as review_year,
review_year,
count(*) as review_count,
avg(rating) as avg_rating
from reviews_enriched
where brand is not null
group by
brand,
review_year

)

select *
from aggregated

