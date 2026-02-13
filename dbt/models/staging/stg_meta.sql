
with source as (

select *
from {{ source('amazon_raw', 'CAPSTONE_AMAZON_META_RAW_TABLE') }}     

),

renamed as (

select
product_id as product_id,
title as product_title,
brand as brand,
--categories as categories,
cast(price as float) as price
from source
where product_id is not null

)

select *
from renamed


