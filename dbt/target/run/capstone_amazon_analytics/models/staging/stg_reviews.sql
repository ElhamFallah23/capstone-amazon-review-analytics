
  create or replace   view AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_reviews
  
   as (
    with source as (

select *
from AMAZON_REVIEW_ANALYTICS_DEV.RAW.CAPSTONE_AMAZON_REVIEW_RAW_TABLE

),

renamed as (

select



product_id as product_id,
reviewer_id as reviewer_id,

cast(rating as integer) as rating,
review_text as review_text,
  
    -- keep raw string
    review_time as review_time,
    -- parse date safely (force string!)
    coalesce(
      try_to_date(review_time::string, 'MM DD, YYYY'),
      try_to_date(review_time::string, 'MM D, YYYY')
    ) as review_date,
    year(
      coalesce(
        try_to_date(review_time::string, 'MM DD, YYYY'),
        try_to_date(review_time::string, 'MM D, YYYY')
      )
    ) as review_year

from source
--where review_id is not null

)

select *
from renamed
  );

