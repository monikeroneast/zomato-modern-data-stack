with raw_source as (
    select *, 'Airflow was here' AS orchestration_check from {{ source('snowflake_raw', 'vw_flattened_orders') }}
)

select
    restaurant_id,
    restaurant_name,
    city,
    country_id,
    restaurant_metadata_json:location:address::string as restaurant_address,
    restaurant_metadata_json:average_cost_for_two::int as average_cost_for_two,
    restaurant_metadata_json:currency::string as transaction_currency,
    restaurant_metadata_json:user_rating:aggregate_rating::float as customer_rating,
    restaurant_metadata_json:user_rating:rating_text::string as customer_rating_review,
    restaurant_metadata_json:user_rating:votes::int as total_votes,
    price_range,
    ingested_at as row_ingested_at,
    orchestration_check
from raw_source