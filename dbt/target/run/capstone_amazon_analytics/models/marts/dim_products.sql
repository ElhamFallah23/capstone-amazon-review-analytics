
  
    

        create or replace transient table AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_products
         as
        (with products as (

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
        );
      
  