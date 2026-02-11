
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    review_id as unique_field,
    count(*) as n_records

from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews
where review_id is not null
group by review_id
having count(*) > 1



  
  
      
    ) dbt_internal_test