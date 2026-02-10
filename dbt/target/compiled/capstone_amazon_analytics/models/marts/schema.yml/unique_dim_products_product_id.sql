
    
    

select
    product_id as unique_field,
    count(*) as n_records

from AMAZON_REVIEW_ANALYTICS_DEV.STAGE_MART.dim_products
where product_id is not null
group by product_id
having count(*) > 1


