-- Creating Storage integration with Amazon s3 Bucket
CREATE OR REPLACE STORAGE INTEGRATION zomato_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::513616570516:role/zomato_snowflake_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://amaz-s3-zomato-raw-data-landing/raw_landing/zomato_historical/');


DESCRIBE STORAGE INTEGRATION zomato_s3_integration;

-- Creating a db for zomato-modern-data-stack
CREATE OR REPLACE DATABASE zomato_db;

-- Creating a new schema 
CREATE OR REPLACE SCHEMA raw;

-- Creating file format to read json files from the Amazon s3 bucket in zomato db raw schema
CREATE OR REPLACE FILE FORMAT zomato_db.raw.json_format
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;

-- Creating the Staging tables
CREATE OR REPLACE STAGE zomato_db.raw.s3_stage
  STORAGE_INTEGRATION = zomato_s3_integration
  URL = 's3://amaz-s3-zomato-raw-data-landing/raw_landing/zomato_historical/'
  FILE_FORMAT = zomato_db.raw.json_format;

-- Verifying storage integration
LIST @zomato_db.raw.s3_stage;







