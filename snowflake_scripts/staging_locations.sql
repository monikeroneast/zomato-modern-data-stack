-- 1. Explicitly select your database and schema context
USE DATABASE zomato_db;
USE SCHEMA raw;

-- 2. Ensure the staging table is physically created
CREATE OR REPLACE TABLE zomato_db.raw.staging_locations (
    raw_json VARIANT,
    ingested_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Copy from Amazon s3 bucket into the staging tables in zomato db raw schema staging_locations table
COPY INTO zomato_db.raw.staging_locations(raw_json)
FROM @zomato_db.raw.s3_stage;

-- Verifying to inspect the data
SELECT * FROM zomato_db.raw.staging_locations LIMIT 5;

-- Flattening the Staging Views
CREATE OR REPLACE VIEW zomato_db.raw.vw_flattened_locations AS
SELECT
    -- Extract core primitive fields directly using colon notation
    f.value:restaurant:id::INT as restaurant_id,
    f.value:restaurant:name::STRING as restaurant_name,
    f.value:restaurant:location:city::STRING as city,
    f.value:restaurant:location:country_id::INT as country_id,
    f.value:restaurant:location:address::STRING as restaurant_address,
    f.value:restaurant:location:locality::STRING as restaurant_locality,
    f.value:restaurant:location:zipcode::STRING as zipcode,
    f.value:restaurant:location:latitude::FLOAT as latitude,
    f.value:restaurant:location:longitude::FLOAT as longitude,
    f.value:restaurant:location:locality_verbose::STRING as locality_description,


    -- Keep the rest of the nested restaurant object intact for dbt analysis
    f.value:restaurant as restaurant_metadata_json,
    ingested_at
FROM zomato_db.raw.staging_locations,
LATERAL FLATTEN(input => raw_json:restaurants) f;

-- Verifiying the Flattened Staging views created
SELECT * FROM zomato_db.raw.vw_flattened_locations LIMIT 5;
