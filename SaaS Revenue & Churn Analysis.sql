## SaaS Revenue & Churn Analysis
/* 
Questions to Answer
1.	What is the overall churn rate, and how has the monthly churn rate trended over the past 4 years? Is churn improving or getting worse?
2.	Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does billing cycle (monthly vs. annual) significantly impact retention?
3.	What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size?
4.	Calculate the average Customer Lifetime Value (CLV) by plan. Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable?

*/

/* 
Workflow:
1. Creating and updating staging tables
2. Understanding the structure, checking for missing values, and getting familiar with the fields.
	a. Fixing data type structure issues in both staging datasets
	b. Renaming columns
	c. Checking and addressing missing and null values
	d. Creating a new descriptive column





*/
-----
-----
## CREATING AND UPDATING STAGING TABLES

CREATE TABLE monthly_revenue_staging 
LIKE monthly_revenue;

INSERT monthly_revenue_staging 
SELECT *
FROM monthly_revenue;

##
CREATE TABLE subscriptions_staging 
LIKE subscriptions;

INSERT subscriptions_staging  
SELECT *
FROM subscriptions;


-----
-----
## UNDERSTANDING THE STRUCTURE, CHECKING FOR MISSING VALUES, AND GETTING FAMILIAR WITH THE FIELDS
## UNDERSTANDING THE STRUCTURE

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'subscriptions_staging';

----
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'monthly_revenue_staging';

----
# Fixing the date columns in the subscriptions_staging dataset
-- Step 1: Cleaning the empty strings
SET SQL_SAFE_UPDATES = 0; -- Disabling safe updates to allow for bulk update

UPDATE subscriptions_staging SET signup_date = NULL WHERE signup_date = '';
UPDATE subscriptions_staging SET churn_date = NULL WHERE churn_date = '';

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;


-- Step 2: Modifying the date and monthly revenue column types
ALTER TABLE subscriptions_staging 
MODIFY COLUMN signup_date DATE,
MODIFY COLUMN churn_date DATE,
MODIFY COLUMN monthly_revenue DECIMAL(10,2);


----
# Modifying columns in the monthly_revenue_staging dataset
ALTER TABLE monthly_revenue_staging 
MODIFY COLUMN month DATE,
MODIFY COLUMN monthly_churn_rate_pct DECIMAL(10,2),
MODIFY COLUMN total_mrr DECIMAL(10,2),
MODIFY COLUMN avg_revenue_per_customer DECIMAL(10,2),
MODIFY COLUMN customer_acquisition_cost DECIMAL(10,2);

----
--- Fixing date issue in the month column:
SET SQL_SAFE_UPDATES = 0;

-- Only append '-01' if the length is 7 characters (YYYY-MM)
UPDATE monthly_revenue_staging 
SET month = CONCAT(month, '-01') 
WHERE LENGTH(month) = 7;

SET SQL_SAFE_UPDATES = 1;

-- Renaming the month column:
ALTER TABLE monthly_revenue_staging
RENAME COLUMN month TO date;

----
## CHECKING AND ADDRESSING NULL AND MISSING VALUES
-- monthly revenue staging table:
SELECT 
    COUNT(*) AS total_records,
    -- Date and Numeric columns only use IS NULL
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN total_active_customers IS NULL THEN 1 ELSE 0 END) AS missing_active_customers,
    SUM(CASE WHEN new_customers IS NULL THEN 1 ELSE 0 END) AS missing_customers,
    SUM(CASE WHEN churned_customers IS NULL THEN 1 ELSE 0 END) AS missing_churned,
    SUM(CASE WHEN monthly_churn_rate_pct IS NULL THEN 1 ELSE 0 END) AS missing_churned_pct,
    SUM(CASE WHEN total_mrr IS NULL THEN 1 ELSE 0 END) AS missing_mrr,
    SUM(CASE WHEN avg_revenue_per_customer IS NULL THEN 1 ELSE 0 END) AS missing_revenue,
    SUM(CASE WHEN customer_acquisition_cost IS NULL THEN 1 ELSE 0 END) AS missing_cost
FROM monthly_revenue_staging;

---
-- subscriptions staging table:
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN plan IS NULL OR plan = '' THEN 1 ELSE 0 END) AS missing_plan,
    SUM(CASE WHEN billing_cycle IS NULL OR billing_cycle = '' THEN 1 ELSE 0 END) AS missing_billing,
    SUM(CASE WHEN industry IS NULL OR industry = '' THEN 1 ELSE 0 END) AS missing_industry,
    SUM(CASE WHEN company_size IS NULL OR company_size = '' THEN 1 ELSE 0 END) AS missing_size,
    SUM(CASE WHEN seats IS NULL THEN 1 ELSE 0 END) AS missing_seats,
    SUM(CASE WHEN monthly_revenue IS NULL THEN 1 ELSE 0 END) AS missing_revenue,
    SUM(CASE WHEN acquisition_channel IS NULL OR acquisition_channel = '' THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN region IS NULL OR region = '' THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS missing_signup,
    SUM(CASE WHEN churned IS NULL OR churned = '' THEN 1 ELSE 0 END) AS missing_churn,
    SUM(CASE WHEN churn_date IS NULL THEN 1 ELSE 0 END) AS missing_churn_date,
    SUM(CASE WHEN churn_reason IS NULL OR churn_reason = '' THEN 1 ELSE 0 END) AS missing_reason,
    SUM(CASE WHEN support_tickets_12mo IS NULL OR support_tickets_12mo = '' THEN 1 ELSE 0 END) AS missing_ticket,
    SUM(CASE WHEN nps_score IS NULL THEN 1 ELSE 0 END) AS missing_score,
    SUM(CASE WHEN feature_usage_pct IS NULL THEN 1 ELSE 0 END) AS missing_feature,
    SUM(CASE WHEN upgraded IS NULL OR upgraded = '' THEN 1 ELSE 0 END) AS missing_upgrade,
	SUM(CASE WHEN company_category IS NULL OR company_category = '' THEN 1 ELSE 0 END) AS missing_category
FROM subscriptions_staging;



-- Addressing null and missing values in the churn reason column:
SET SQL_SAFE_UPDATES = 0;

UPDATE subscriptions_staging
SET churn_reason = 'Not Applicable (Active)'
WHERE churned = 'No' 
  AND (churn_reason IS NULL OR TRIM(churn_reason) = '');

SET SQL_SAFE_UPDATES = 1;


-- Addressing null and missing values in the support ticket column:
SET SQL_SAFE_UPDATES = 0;

UPDATE subscriptions_staging
SET support_tickets_12mo = 0
WHERE support_tickets_12mo IS NULL;

SET SQL_SAFE_UPDATES = 1;


----
## CREATING A NEW COLUMN WITH DESCRIPTIVE LABELS 
-- Step 1: Adding the new column
ALTER TABLE subscriptions_staging 
ADD COLUMN company_category VARCHAR(50);


-- Step 2: Populating the labels
SET SQL_SAFE_UPDATES = 0; 

UPDATE subscriptions_staging
SET company_category = CASE 
    WHEN company_size = '1-10'   THEN 'Micro'
    WHEN company_size = '11-50'  THEN 'Small-sized'
    WHEN company_size = '51-200' THEN 'Mid-sized'
	WHEN company_size = '201-500' THEN 'Large'
	ELSE 'Enterprise'
END;

SET SQL_SAFE_UPDATES = 1;


-----
-----
## EXPLORATORY DATA ANALYSIS (EDA) - Subscriptions
-- Customer distribution: Which plans or regions are the most popular?
SELECT 
    region, 
    plan, 
    COUNT(customer_id) AS total_customers,
    ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(*) FROM subscriptions_staging), 2) AS pct_of_base
FROM subscriptions_staging
GROUP BY plan, region
ORDER BY total_customers DESC;

----
-- Average Revenue Per User (ARPU): To identify which company categories are high value 
SELECT 
    company_category,
    COUNT(customer_id) AS customer_count,
    SUM(monthly_revenue) AS total_mrr,
    ROUND(AVG(monthly_revenue), 2) AS arpu
FROM subscriptions_staging
GROUP BY company_category
ORDER BY arpu DESC;

----
-- Churn drivers analyis: To identify WHY customers stopped doing business with the saas company
SELECT 
    churn_reason,
    COUNT(*) AS count,
    ROUND(AVG(monthly_revenue), 2) AS avg_lost_revenue,
    ROUND(AVG(support_tickets_12mo), 1) AS avg_tickets_before_churn
FROM subscriptions_staging
WHERE churned = 'Yes'
GROUP BY churn_reason
ORDER BY count DESC;


----
--  NPS, Feature usage and churn analysis: To determine whether customers with high feature usage are less likely to churn
SELECT 
    CASE 
        WHEN feature_usage_pct > 70 THEN 'Power User'
        WHEN feature_usage_pct BETWEEN 40 AND 70 THEN 'Active User'
        ELSE 'At Risk / Low Usage'
    END AS usage_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(nps_score), 2) AS avg_nps,
    ROUND(SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM subscriptions_staging
GROUP BY usage_tier
ORDER BY usage_tier;

----
-- NPS (Net Promoter Score) and Churn analyis: To determine the correlation between NPS and Churn 
SELECT 

    CASE 
        WHEN nps_score >= 9 THEN 'Promoter'
        WHEN nps_score >= 7 THEN 'Passive'
        ELSE 'Detractor'
    END AS nps_category,
    COUNT(*) AS total_customers,
    ROUND(AVG(feature_usage_pct), 2) AS avg_feature_usage,
    ROUND(SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM subscriptions_staging
GROUP BY nps_category
ORDER BY AVG(nps_score) DESC;



----
-- Ideal Customer Profile (ICP): To identify the segment with the lowest churn and highest revenue
SELECT 
    industry,
    acquisition_channel,
    COUNT(*) AS total_customers,
    ROUND(AVG(monthly_revenue), 2) AS avg_revenue,
    ROUND(SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM subscriptions_staging
GROUP BY industry, acquisition_channel
HAVING total_customers > 5  -- Filters out small sample sizes
ORDER BY churn_rate_pct ASC, avg_revenue DESC;


----
-- Ticket volume and churn: To determine whetehr a high ticket volume is a sign of impending churn
SELECT 
    CASE 
        WHEN support_tickets_12mo = 0 THEN '0 Tickets'
        WHEN support_tickets_12mo BETWEEN 1 AND 5 THEN 'Low Volume (1-5)'
        ELSE 'High Volume (5+)'
    END AS ticket_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(nps_score), 2) AS avg_nps,
    ROUND(SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM subscriptions_staging
GROUP BY ticket_tier
ORDER BY churn_rate_pct DESC;

----
-- Regional revenue performance
SELECT 
    region,
    SUM(monthly_revenue) AS total_mrr,
    ROUND(AVG(monthly_revenue), 2) AS average_deal_size,
    SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS total_churned
FROM subscriptions_staging
GROUP BY region
ORDER BY total_mrr DESC;


----
-- Low usage customers: To find active customers who aren't using the product (Usage < 50%) but haven't left yet - these are prime targets for a "re-engagement" campaign.
SELECT 
    customer_id, 
    plan, 
    feature_usage_pct, 
    monthly_revenue
FROM subscriptions_staging
WHERE churned = 'No' AND feature_usage_pct < 50
ORDER BY monthly_revenue DESC;

----
-- Which plan has the highest number of at-risk customers and the total revenue at risk?
SELECT 
    plan, 
    COUNT(customer_id) AS at_risk_customer_count,
    ROUND(SUM(monthly_revenue), 2) AS total_at_risk_revenue,
    ROUND(AVG(feature_usage_pct), 2) AS avg_usage_pct
FROM subscriptions_staging
WHERE churned = 'No' AND feature_usage_pct < 50
GROUP BY plan
ORDER BY at_risk_customer_count DESC;

----
-- At-risk concentration by plan
SELECT 
    customer_id, 
    plan, 
    feature_usage_pct, 
    monthly_revenue,
    COUNT(*) OVER(PARTITION BY plan) AS total_at_risk_in_plan
FROM subscriptions_staging
WHERE churned = 'No' AND feature_usage_pct < 50
ORDER BY plan, monthly_revenue DESC;

----
----

select *
from subscriptions_staging;
