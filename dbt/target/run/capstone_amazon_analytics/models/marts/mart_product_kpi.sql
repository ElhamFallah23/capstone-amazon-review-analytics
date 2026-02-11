
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_product_kpi
         as
        (-- Presentation layer model
-- This model is designed specifically for QuickSight dashboards
-- Aggregations are isolated here

with reviews as (

select *
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular

),

aggregated as (

select
product_id,
count(*) as review_count,
avg(rating) as avg_rating,
min(review_timestamp) as first_review_date,
max(review_timestamp) as last_review_date
from reviews
group by product_id

),

final as (

select
p.product_id,
p.product_title,
p.brand,
p.categories,
p.price,
a.review_count,
a.avg_rating,
a.first_review_date,
a.last_review_date
from aggregated a
left join AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_products p
on a.product_id = p.product_id

)

select *
from final
        );
      
  