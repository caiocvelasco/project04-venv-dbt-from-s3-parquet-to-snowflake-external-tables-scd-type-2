-- models/gold/churn_customers.sql

WITH dim_customers AS (
    SELECT *
    FROM {{ ref('dim_customers') }}
),
fact_subscriptions AS (
    SELECT *
    FROM {{ ref('fact_subscriptions') }}
)

SELECT 
    dim_c.customer_id,
    dim_c.name,
    dim_c.age,
    dim_c.gender,
    dim_c.signup_date,
    fc_s.subscription_id,
    fc_s.type AS subscription_type,
    fc_s.start_date,
    fc_s.end_date,
    CASE
        WHEN fc_s.end_date IS NOT NULL AND fc_s.end_date < CURRENT_DATE THEN 1
        ELSE 0
    END AS is_churned
FROM dim_customers dim_c
LEFT JOIN fact_subscriptions fc_s ON dim_c.customer_id = fc_s.customer_id