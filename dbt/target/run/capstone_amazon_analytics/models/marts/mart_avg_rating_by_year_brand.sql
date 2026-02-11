
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_avg_rating_by_year_brand
         as
        (with reviews_enriched as (
select
r.product_id,
r.rating,
r.review_timestamp,
p.brand
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular r
left join AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_products p
on r.product_id = p.product_id

),

aggregated as (

select
brand,
extract(year from review_timestamp) as review_year,
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
        );
      
  