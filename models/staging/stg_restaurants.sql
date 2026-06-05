with raw_source as (
    select * from {{ source('snowflake_raw', 'vw_flattened_restaurants') }}
)

select
    restaurant_id,
    restaurant_name,
    has_online_delivery,
    is_delivering_now,
    has_table_booking,
    city,
    country_id,
    restaurant_metadata_json:location:address::string as restaurant_address,
    restaurant_metadata_json:location:locality::string as restaurant_locality,
    restaurant_metadata_json:location:latitude::float as latitude,
    restaurant_metadata_json:location:longitude::float as longitude,
    restaurant_metadata_json:location:zipcode::string as zipcode,
    price_range,
    transaction_currency,
    ingested_at as row_ingested_at
from raw_source