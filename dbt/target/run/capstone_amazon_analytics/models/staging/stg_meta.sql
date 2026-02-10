
  create or replace   view AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_meta
  
  
  
  
  as (
    with source as (

select *
from AMAZON_REVIEW_ANALYTICS_DEV.RAW.CAPSTONE_AMAZON_META_RAW_TABLE     

),

renamed as (

select
product_id as product_id,
title as product_title,
brand as brand,
categories as categories,
cast(price as float) as price
from source

)

select *
from renamed
  );

