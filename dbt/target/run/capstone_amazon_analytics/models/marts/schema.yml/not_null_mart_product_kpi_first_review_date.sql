select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select first_review_date
from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.mart_product_kpi
where first_review_date is null



      
    ) dbt_internal_test