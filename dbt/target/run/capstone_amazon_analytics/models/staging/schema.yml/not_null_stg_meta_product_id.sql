select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select product_id
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_STAGE.stg_meta
where product_id is null



      
    ) dbt_internal_test