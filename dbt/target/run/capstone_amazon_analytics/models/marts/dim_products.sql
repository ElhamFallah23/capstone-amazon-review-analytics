
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_products
         as
        (with products as (

select *,
row_number() over (
partition by product_id
order by product_id
) as rn
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_meta

)

select
product_id,
product_title,
brand,
price
from products
where rn = 1
        );
      
  