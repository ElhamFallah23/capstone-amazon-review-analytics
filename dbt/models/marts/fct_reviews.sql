

with reviews as (

select
review_id,
product_id,
rating,
review_timestamp
from {{ ref('stg_reviews') }}

),

aggregated as (

select
product_id,
count(*) as review_count,
avg(rating) as avg_rating
from reviews
group by product_id

)

select *
from aggregated
