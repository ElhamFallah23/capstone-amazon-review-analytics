select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select avg_rating
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_product_kpi
where avg_rating is null



      
    ) dbt_internal_test