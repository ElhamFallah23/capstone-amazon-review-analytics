with products as (

select
product_id,
product_title,
brand,
categories, 
price
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_meta

)

select *
from products