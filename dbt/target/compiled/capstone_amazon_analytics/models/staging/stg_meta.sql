with source as (

select *
from AMAZON_REVIEW_ANALYTICS_DEV.RAW.CAPSTONE_AMAZON_META_RAW_TABLE     

),

renamed as (

select
product_id as product_id,
title as product_title,
brand as brand,
main_category as categories,
cast(price as float) as price
from source

)

select *
from renamed