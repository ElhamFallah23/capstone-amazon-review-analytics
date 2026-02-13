
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_date
         as
        (-- Date dimension built from review timestamps
-- This enables time-based analysis in BI tools

with dates as (

select distinct
--cast(review_time as date) as date_day

review_time as review_time,

-- parse date safely (force string!)
    coalesce(
      try_to_date(review_time::string, 'MM DD, YYYY'),
      try_to_date(review_time::string, 'MM D, YYYY')
    ) as date_day,
   

from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular

),

date_enriched as (

select
date_day,
year(date_day) as year,
month(date_day) as month,
day(date_day) as day,
week(date_day) as week,
quarter(date_day) as quarter,
dayofweek(date_day) as day_of_week
from dates

)

select *
from date_enriched
        );
      
  