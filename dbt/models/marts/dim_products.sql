

with products as (

select
product_id,
product_title,
brand,
category,
price
from {{ ref('stg_meta') }}

)

select *
from products

