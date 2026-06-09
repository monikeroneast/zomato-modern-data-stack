with raw_source as (
    select *, 'Airflow was here' AS orchestration_check from {{ source('snowflake_raw', 'vw_flattened_cuisines') }}
)

select
    restaurant_id,
    restaurant_name,
    city,
    country_id,
    cuisine_name,
    restaurant_metadata_json,
    ingested_at as row_ingested_at,
    orchestration_check
from raw_source