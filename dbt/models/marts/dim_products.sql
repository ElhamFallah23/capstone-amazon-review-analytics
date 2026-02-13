

with products as (

select
product_id,
product_title,
brand,
--categories, 
price
from {{ ref('stg_meta') }}

)

select *
from products

