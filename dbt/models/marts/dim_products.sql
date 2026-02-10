

with products as (

select
product_id,
product_title,
brand,
main_category, 
price
from {{ ref('stg_meta') }}

)

select *
from products

