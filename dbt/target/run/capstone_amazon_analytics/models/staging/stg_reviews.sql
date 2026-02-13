
  create or replace   view AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_reviews
  
   as (
    with source as (

select *
from AMAZON_REVIEW_ANALYTICS_DEV.RAW.CAPSTONE_AMAZON_REVIEW_RAW_TABLE

),

renamed as (

select
md5(cast(coalesce(cast(reviewer_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(product_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(review_time as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as review_id,
product_id as product_id,
reviewer_id as reviewer_id,
cast(rating as integer) as rating,
review_text as review_text,
cast(review_time as timestamp) as review_timestamp
from source
where review_id is not null

)

select *
from renamed
  );

