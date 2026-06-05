with raw_source as (
    select * from {{ source('snowflake_raw', 'vw_flattened_cuisines') }}
)

select
    restaurant_id,
    restaurant_name,
    city,
    country_id,
    cuisine_name,
    restaurant_metadata_json,
    ingested_at as row_ingested_at
from raw_source