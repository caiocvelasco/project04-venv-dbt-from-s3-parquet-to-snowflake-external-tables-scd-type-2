-- models/silver/stg_scd2_dim_customers.sql
-- Transformations:
    -- Ensuring a date format to signup_date

select
    customer_id,
    name,
    age,
    gender,
    signup_date,  -- Convert to date format
    -- extracted_at,
    current_timestamp as inserted_at  -- -- Overwrite with current timestamp
from {{ source('bronze','customers') }}  -- References the bronze.customers external table
