
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select avg_rating
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews
where avg_rating is null



  
  
      
    ) dbt_internal_test