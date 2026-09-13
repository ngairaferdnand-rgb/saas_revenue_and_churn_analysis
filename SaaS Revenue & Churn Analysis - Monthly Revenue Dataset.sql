



----
----
## EXPLORATORY DATA ANALYSIS (EDA) FOR MONTHLY REVENUE DATASET
-- Cumulative MRR, Average MRR, Average Churn Rate, and Average CAC
SELECT 
    MIN(date) as start_date,
    MAX(date) as end_date,
    ROUND(SUM(total_mrr), 2) AS cumulative_mrr,
    ROUND(AVG(total_mrr), 2) AS avg_monthly_mrr,
    ROUND(AVG(monthly_churn_rate_pct), 2) AS avg_churn_rate,
    ROUND(AVG(customer_acquisition_cost), 2) AS avg_cac
FROM monthly_revenue_staging;

----
-- Month-over-Month (MoM) MRR Growth
SELECT 
    date,
    total_mrr,
    LAG(total_mrr) OVER (ORDER BY date) AS previous_month_mrr,
    ROUND(((total_mrr - LAG(total_mrr) OVER (ORDER BY date)) / 
           NULLIF(LAG(total_mrr) OVER (ORDER BY date), 0)) * 100, 2) AS mom_growth_pct
FROM monthly_revenue_staging;

----
-- CAC Payback Period 
SELECT 
    date,
    customer_acquisition_cost AS cac,
    avg_revenue_per_customer AS arpu,
    ROUND(customer_acquisition_cost / NULLIF(avg_revenue_per_customer, 0), 1) AS months_to_payback
FROM monthly_revenue_staging
WHERE avg_revenue_per_customer > 0
ORDER BY date DESC;

----
-- CAC Payback Period by Customer: To determine how many months of revenue from a single customer it takes to "pay back" the cost of acquiring them.
SELECT 
    s.customer_id,
    s.signup_date,
    s.monthly_revenue AS customer_mrr,
    m.customer_acquisition_cost AS cac_at_signup,
    -- Individual Payback Period calculation
    ROUND(m.customer_acquisition_cost / NULLIF(s.monthly_revenue, 0), 1) AS payback_months
FROM subscriptions_staging AS s
LEFT JOIN monthly_revenue_staging AS m 
  -- This creates the "Key" by making both dates look like 'YYYY-MM-01'
  ON DATE_FORMAT(s.signup_date, '%Y-%m-01') = m.date
ORDER BY signup_date DESC;


select *
from monthly_revenue_staging;