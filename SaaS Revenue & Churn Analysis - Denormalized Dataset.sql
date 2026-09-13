## CREATING 
CREATE TABLE customer_unit_economics AS
SELECT 
    s.customer_id,
    s.billing_cycle,
    s.plan,
    s.industry,
    s.region,
    s.signup_date,
    s.churned,
    s.churn_date,
    s.acquisition_channel,
    s.churn_reason,
    s.support_tickets_12mo,
    s.nps_score,
    s.feature_usage_pct,
    s.company_category,
    s.monthly_revenue AS customer_mrr,
    m.new_customers,
    m.total_mrr,
    m.avg_revenue_per_customer,
    m.customer_acquisition_cost AS cohort_cac,
    -- Calculate individual Payback Period
    ROUND(m.customer_acquisition_cost / NULLIF(s.monthly_revenue, 0), 1) AS payback_months,
    -- Calculate estimated Lifetime Value (LTV) for that segment at that time
    ROUND(s.monthly_revenue / (NULLIF(m.monthly_churn_rate_pct, 0) / 100), 2) AS estimated_ltv,
    -- Check if they are already profitable
    CASE 
        WHEN s.churned = 'No' THEN 'Active'
        WHEN DATEDIFF(s.churn_date, s.signup_date) / 30.44 >= (m.customer_acquisition_cost / s.monthly_revenue) THEN 'Profitable Churn'
        ELSE 'Loss-Making Churn'
    END AS profitability_status
FROM subscriptions_staging AS s
LEFT JOIN monthly_revenue_staging AS m 
  ON DATE_FORMAT(s.signup_date, '%Y-%m-01') = m.date;
  
-----
-----
-- Adding a primary key column
-- 1. Change the column type and make it 'NOT NULL' (required for Primary Keys)
ALTER TABLE customer_unit_economics 
MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;

-- 2. Now add the Primary Key
ALTER TABLE customer_unit_economics 
ADD PRIMARY KEY (customer_id);


-----
-----
-- Calculating Net Revenue Retention (NRR)
SELECT 
    date,
    total_mrr AS current_month_mrr,
    -- Calculating new business MRR
    (new_customers * avg_revenue_per_customer) AS new_business_mrr,
    -- Get previous month's MRR
    LAG(total_mrr) OVER (ORDER BY date) AS starting_mrr,
    -- NRR Formula: (Current MRR - New MRR) / Starting MRR
    ROUND(
        (total_mrr - (new_customers * avg_revenue_per_customer)) / 
        NULLIF(LAG(total_mrr) OVER (ORDER BY date), 0) * 100, 
    2) AS nrr_percentage
FROM monthly_revenue_staging
ORDER BY date DESC;

----
----
-- Customer Segments with Highest LTV:CAC ratio
SELECT 
    industry,
    plan,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(estimated_ltv), 2) AS avg_ltv,
    ROUND(AVG(cohort_cac), 2) AS avg_cac,
    -- Calculating ROI (LTV to CAC Ratio)
    ROUND(AVG(estimated_ltv) / NULLIF(AVG(cohort_cac), 0), 2) AS ltv_cac_ratio
FROM customer_unit_economics
GROUP BY industry, plan
HAVING total_customers > 5
ORDER BY ltv_cac_ratio DESC;

----
----
-- Payback Period by Segment
SELECT 
    industry,
    plan,
    ROUND(AVG(customer_mrr), 2) AS avg_monthly_rev,
    ROUND(AVG(cohort_cac), 2) AS avg_cac,
    -- Average the individual payback months we stored earlier
    ROUND(AVG(payback_months), 2) AS avg_payback_months
FROM customer_unit_economics
GROUP BY industry, plan
ORDER BY avg_payback_months ASC;

-----
-----
-- Acquisition Channel Efficiency: This analysis identifies which acquisition channels have the fastest payback period
SELECT 
    acquisition_channel,
    plan,
    COUNT(customer_id) AS total_customers,
    -- The speed at which you get your money back
    ROUND(AVG(payback_months), 2) AS avg_payback_months
FROM customer_unit_economics
GROUP BY acquisition_channel, plan
ORDER BY plan, avg_payback_months ASC;


select *
from customer_unit_economics;