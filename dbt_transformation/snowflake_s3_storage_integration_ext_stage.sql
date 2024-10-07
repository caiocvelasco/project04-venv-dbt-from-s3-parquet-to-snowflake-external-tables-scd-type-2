-- Setting Up Storage Integration with S3 and External Stage in Snowflake
-- References: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration

-- Setting up S3 and Snowflake

-- ### Transformation Step

-- 1) Ensure your **AWS** environment is ready.
--   * I created a bucket called: `dbt-duckdb-ingestion-s3-parquet` where the Parquet Files will be stored following some kind of folder structure that is still to be defined

-- 2) Ensure your **Snowflake** environment is ready.
--   * In this project, we read from my S3 Bucket and write into Snowflake. The way I chose to do this is called Snowflake **Storage Integration**, which opens a secure connection between the Snowflake AWS Role and the AWS S3 Role.
--   * The next step after `Storage Integration` is to create an `External Stage` in Snowflake.
--     * **NOTE**: Whenever you create a new External Stage, you need to update the `ExternalID` policy of the AWS role, in the "Trusted entities" part.
--   * Follow this (https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration) and it will guide you through the following:
--     * Create an IAM Policy (done in AWS).
--     * Create an IAM Role (done in AWS).
--   * **Note**: 
--     * The **External Tables** will be created by dbt.

-- 3) Executing commands in order

CREATE DATABASE IF NOT EXISTS MY_DBT_DATABASE;       -- CREATE DATABASE

USE DATABASE MY_DBT_DATABASE;                        -- Use Database (Set it for the user session)
CREATE SCHEMA IF NOT EXISTS MY_DBT_DATABASE.BRONZE;  -- CREATE SCHEMA    
USE SCHEMA MY_DBT_DATABASE.BRONZE;                   -- Use Bronze Schema (Set it for the user session

CREATE ROLE IF NOT EXISTS STORAGE_ADMIN;                                         -- CREATE ROLE
GRANT USAGE ON WAREHOUSE MY_DBT_WAREHOUSE TO ROLE STORAGE_ADMIN;                 -- Grant Usage privilege on Warehouse TO ROLE storage_admin
GRANT USAGE ON DATABASE MY_DBT_DATABASE TO ROLE STORAGE_ADMIN;                   -- Grant Usage privilege on Database TO ROLE storage_admin
GRANT USAGE ON SCHEMA MY_DBT_DATABASE.BRONZE TO ROLE STORAGE_ADMIN;              -- Grant Usage privilege on Schema TO ROLE storage_admin
GRANT CREATE TABLE ON SCHEMA MY_DBT_DATABASE.BRONZE TO ROLE STORAGE_ADMIN;       -- Grant Create Table on Schema TO ROLE storage_admin
GRANT CREATE FILE FORMAT ON SCHEMA MY_DBT_DATABASE.BRONZE TO ROLE STORAGE_ADMIN; -- Grant Create File Format privilege on Schema TO ROLE storage_admin
GRANT CREATE STAGE ON SCHEMA MY_DBT_DATABASE.BRONZE TO ROLE STORAGE_ADMIN;       -- Grant Create Stage privilege on Schema TO ROLE storage_admin

--CREATE USER IF NOT EXISTS my_user               -- CREATE USER
--CURRENT_DATE    PASSWORD = 'my_password'
--    DEFAULT_ROLE = 'STORAGE_ADMIN'
--    DEFAULT_WAREHOUSE = 'MY_DBT_WAREHOUSE';
GRANT ROLE STORAGE_ADMIN TO USER DBT_USER;  -- Grant Role to the 'cvconsulting' user

GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE STORAGE_ADMIN;           -- Grant CREATE STORAGE INTEGRATION TO ROLE storage_admin     


CREATE STORAGE INTEGRATION IF NOT EXISTS MY_S3_INTEGRATION           -- CREATE STORAGE INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::171447222387:role/feng-bi-bucket-access'
    STORAGE_ALLOWED_LOCATIONS = ('s3://feng-bi');
GRANT USAGE ON INTEGRATION MY_S3_INTEGRATION TO ROLE STORAGE_ADMIN;  -- Grant Usage privilege on Integration TO ROLE storage_admin
SHOW STORAGE INTEGRATIONS LIKE 'MY_S3_INTEGRATION';                   -- Storage Integration details (just to check if it worked)
DESC INTEGRATION MY_S3_INTEGRATION;                                   -- Storage Integration details for AWS (get the values for STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_ROLE_ARN)

GRANT USAGE ON INTEGRATION MY_S3_INTEGRATION TO ROLE STORAGE_ADMIN;

CREATE FILE FORMAT IF NOT EXISTS MY_PARQUET_FORMAT                    -- CREATE NAMED FILE FORMAT FOR EXTERNAL STAGE
    TYPE = 'PARQUET'
    COMPRESSION = 'SNAPPY';  
GRANT USAGE ON FILE FORMAT MY_PARQUET_FORMAT TO ROLE STORAGE_ADMIN;    -- Grant Usage on File Format to ROKE storage_admin      

CREATE STAGE IF NOT EXISTS MY_S3_STAGE                                         -- CREATE EXTERNAL STAGE 
    STORAGE_INTEGRATION = MY_S3_INTEGRATION
    URL='s3://dbt-duckdb-ingestion-s3-parquet'
    FILE_FORMAT = MY_PARQUET_FORMAT;      
GRANT USAGE ON STAGE MY_DBT_DATABASE.BRONZE.MY_S3_STAGE TO ROLE STORAGE_ADMIN; -- Grant USAGE privilege on the External Stage TO ROLE storage_admin
SHOW STAGES LIKE 'MY_S3_STAGE' IN DATABASE MY_DBT_DATABASE;                    -- Show External Stage Details (just to check if it worked)


LIST @MY_S3_STAGE;
