
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select review_id
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular
where review_id is null



  
  
      
    ) dbt_internal_test