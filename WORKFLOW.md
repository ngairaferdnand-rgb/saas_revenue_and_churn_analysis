## 📌 Project Overview
This repository contains an end-to-end data analytics project analyzing a SaaS company's customer data. The project aims to engineer a clean data pipeline that transforms raw, unstandardized data into an interactive executive dashboard and visualizations that answer the following management questions:

1️⃣ What is the overall churn rate, and how has the monthly churn rate trended over the past 4 years? Is churn improving or getting worse? <br>
2️⃣ Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does the billing cycle (monthly vs. annual) significantly impact retention? <br>
3️⃣ What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size? <br>
4️⃣ Calculate the average Customer Lifetime Value (CLV) by plan. Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable? <br>

The dataset includes customer ID, billing cycle, subscription plan, industry, signup date, churn date, acquisition channel, churn reason, and so on. 

##

**🚗 Data Cleaning and Imputation Pipeline:**
 *   [SQL Data Cleaning Script](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/SaaS%20Revenue%20%26%20Churn%20Analysis.sql) — *The complete automated data pipeline used for checking data structure, cleaning empty strings, modifying column types, creating a new column with descriptive labels like "Small," "Mid-sized," or "Enterprise"; checking if the data is truncated; converting date columns to DATE type; Checking for NULL and MISSING values; Finding "Hidden" Missing Values (Zeros); standardizing the dataset.*

##

**📊 Exploratory Data Analysis (EDA):**  
 *   [SQL EDA Script](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/SaaS%20Revenue%20%26%20Churn%20Analysis%20-%20Denormalized%20Dataset.sql) — *Repository of structured queries used to perform EDA, that is,  to identify patterns in the revenue, churn, and customer behavior:*  
		- **High-Level Customer Distribution:** This helps us understand where the business stands. Which plans or regions are the most popular?
		- **Revenue Deep Dive (MRR and ARPU):** Average Revenue Per User (ARPU) helps  identify which segments are the "High Value" segments. Monthly Recurring Revenue (MRR) measures the predictable and recurring revenue components of the subscription business.
		- **Churn Drivers Analysis:** To find the "Why" behind the "Who."
		- **Product Health and NPS Analysis:** This query looks at "Customer Health" metrics. We want to see if customers with high feature usage are actually less likely to churn.
		- **Identifying the Ideal Customer Profile (ICP):** This final EDA step identifies the segment with the lowest churn and highest revenue.

## 
**💻 Data Analysis**
*   [SQL](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/SaaS%20Revenue%20%26%20Churn%20Analysis%20-%20Denormalized%20Dataset.sql) — *The repository of structured queries used to calculate churn rate percentage, total  number of churned customers, carry out Year-over-Year (YoY) analysis, impact of billing cycle on retention, and so on. Using SELECT statements, JOINS, GROUP BY & ORDER BY functions, WHERE filter, Common Table Expression (CTE), etc.*

## 
**🗒️ Executive Summary and Reports:**
*   [Executive Summary](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/EXECUTIVESUMMARY.md) — *Summary of the main findings and numbers, conclusion, and recommendations for the CFO's office.*
*    [Report](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/Report.pdf) — *The background, management task, executive summary, and questions addressed by the analysis.*
*   [Churn Analysis GitHub Report](https://github.com/ngairaferdnand-rgb/saas_revenue_and_churn_analysis/blob/main/README.md)
