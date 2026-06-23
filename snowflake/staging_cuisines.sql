-- 1. Explicitly select your database and schema context
USE DATABASE zomato_db;
USE SCHEMA raw;

-- 2. Ensure the staging table is physically created
CREATE OR REPLACE TABLE zomato_db.raw.staging_cuisines (
    raw_json VARIANT,
    ingested_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Copy from Amazon s3 bucket into the staging tables in zomato db raw schema staging_cuisines table
COPY INTO zomato_db.raw.staging_cuisines(raw_json)
FROM @zomato_db.raw.s3_stage;

-- Verifying to inspect the data
SELECT * FROM zomato_db.raw.staging_cuisines LIMIT 5;

-- Flattening the Staging Views
CREATE OR REPLACE VIEW zomato_db.raw.vw_flattened_cuisines AS
SELECT
    -- Extract core primitive fields directly using colon notation
    f.value:restaurant:id::INT as restaurant_id,
    f.value:restaurant:name::STRING as restaurant_name,
    f.value:restaurant:location:city::STRING as city,
    f.value:restaurant:location:country_id::INT as country_id,
    TRIM(c.value::STRING) AS cuisine_name,
    

    -- Keep the rest of the nested restaurant object intact for dbt analysis
    f.value:restaurant as restaurant_metadata_json,
    ingested_at
FROM zomato_db.raw.staging_cuisines,
LATERAL FLATTEN(input => raw_json:restaurants) f,
LATERAL SPLIT_TO_TABLE(f.value:restaurant:cuisines::STRING, ',') c;

-- Verifiying the Flattened Staging views created
SELECT * FROM zomato_db.raw.vw_flattened_cuisines LIMIT 5;
