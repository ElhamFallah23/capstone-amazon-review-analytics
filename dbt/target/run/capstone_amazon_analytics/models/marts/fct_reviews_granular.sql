
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular
         as
        (-- This model preserves the lowest level of granularity
-- Each row represents one review event
-- No aggregation is performed here

with reviews as (

select
reviewer_id,
product_id,
rating,
review_time,
review_year

from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_reviews

)

select *
from reviews
        );
      
  