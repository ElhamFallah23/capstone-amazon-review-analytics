-- Date dimension built from review timestamps
-- This enables time-based analysis in BI tools

with dates as (

select distinct
cast(review_timestamp as date) as date_day
from {{ ref('fct_reviews_granular') }}

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


