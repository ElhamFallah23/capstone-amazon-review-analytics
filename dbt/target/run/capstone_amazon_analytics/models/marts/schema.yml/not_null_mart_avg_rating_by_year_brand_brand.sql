select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select brand
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_avg_rating_by_year_brand
where brand is null



      
    ) dbt_internal_test