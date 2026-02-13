
with source as (

select *
from {{ source('amazon_raw', 'CAPSTONE_AMAZON_META_RAW_TABLE') }}     

),

renamed as (

select
product_id as product_id,
title as product_title,
brand as brand,
try_to_number(regexp_replace(price, '[^0-9.]', '')) as price
from source
where product_id is not null

)

select *
from renamed


