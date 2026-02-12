select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select review_year
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_avg_rating_by_year_brand
where review_year is null



      
    ) dbt_internal_test