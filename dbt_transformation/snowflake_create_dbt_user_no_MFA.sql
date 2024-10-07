-- Step 1: Create the User
CREATE USER DBT_USER
  PASSWORD = '|'  -- This will prompt you for the password when executed in SnowSQL or Snowflake Web UI
  DEFAULT_ROLE = DBT_ROLE
  DEFAULT_NAMESPACE = MY_DBT_DATABASE.BRONZE
  MUST_CHANGE_PASSWORD = FALSE;

-- Step 2: Create the Role
CREATE ROLE DBT_ROLE;

-- Step 3: Grant the Role to the User
GRANT ROLE DBT_ROLE TO USER DBT_USER;

-- Step 4: Grant Privileges to the Role at the Database Level

-- Grant usage on the entire database
GRANT USAGE ON DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;

-- Grant all privileges on all existing and future objects within the database
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE SEQUENCES IN DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE STAGES IN DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;

-- Allow the role to create objects in any schema within the database
GRANT CREATE SCHEMA ON DATABASE MY_DBT_DATABASE TO ROLE DBT_ROLE;

-- Step 5: Set the Role as the Default Role for the User
ALTER USER DBT_USER SET DEFAULT_ROLE = DBT_ROLE;

-- Step 6: Test the Setup
-- (This step is performed manually by logging in as DBT_USER and verifying the access.)