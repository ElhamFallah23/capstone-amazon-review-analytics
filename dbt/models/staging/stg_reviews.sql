with source as (

select *
from {{ source('amazon_raw', 'CAPSTONE_AMAZON_REVIEW_RAW_TABLE') }}

),

renamed as (

select
review_id as review_id,
product_id as product_id,
reviewer_id as reviewer_id,
cast(rating as integer) as rating,
review_text as review_text,
cast(review_time as timestamp) as review_timestamp
from source

)

select *
from renamed



