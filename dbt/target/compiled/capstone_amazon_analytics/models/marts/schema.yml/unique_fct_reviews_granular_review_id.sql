
    
    

select
    review_id as unique_field,
    count(*) as n_records

from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.fct_reviews_granular
where review_id is not null
group by review_id
having count(*) > 1


