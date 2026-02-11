

-- This model preserves the lowest level of granularity
-- Each row represents one review event
-- No aggregation is performed here

with reviews as (

select
review_id,
product_id,
rating,
review_timestamp

from {{ ref('stg_reviews') }}

)

select *
from reviews



