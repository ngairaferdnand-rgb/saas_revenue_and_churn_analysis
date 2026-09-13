## 📌 Project Overview
This repository contains an end-to-end data analytics project analyzing a SaaS company's customer data. The project aims to engineer a clean data pipeline that transforms raw, unstandardized data into an interactive executive dashboard and visualizations that answer the following management questions:

	1️⃣ What is the overall churn rate, and how has the monthly churn rate trended over the past 4 years? Is churn improving or getting worse?
	2️⃣ Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does the billing cycle (monthly vs. annual) significantly impact retention?
	3️⃣ What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size?
	4️⃣ Calculate the average Customer Lifetime Value (CLV) by plan. Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable?

The dataset includes customer ID, billing cycle, subscription plan, industry, signup date, churn date, acquisition channel, churn reason, and so on. 

##
🚗 **Data Cleaning and Imputation Pipeline**

**Data Engineering and Pipelines:**

SQL Data Cleaning Script — The complete automated data pipeline used for checking data structure, cleaning empty strings, modifying column types, creating a new column with descriptive labels like "Small," "Mid-sized," or "Enterprise"; checking if the data is truncated; converting date columnd to DATE type; Checking for NULL and MISSING values; Finding "Hidden" Missing Values (Zeros); standardizing the dataset.

##

📊 **Exploratory Data Analysis (EDA):**

SQL — Repository of structured queries used to perform EDA, that is,  to identify patterns in the revenue, churn, and customer behavior:
1. **High-Level Customer Distribution:** This helps us understand where the business stands. Which plans or regions are the most popular?
2. **Revenue Deep Dive (MRR and ARPU):** Average Revenue Per User (ARPU) helps  identify which segments are the "High Value" segments. Monthly Recurring Revenue (MRR) measures the predictable and recurring revenue components of the subscription business.
3. **Churn Drivers Analysis:** To find the "Why" behind the "Who."
4. **Product Health and NPS Analysis:** This query looks at "Customer Health" metrics. We want to see if customers with high feature usage are actually less likely to churn.
5. **Identifying the Ideal Customer Profile (ICP):** This final EDA step identifies the segment with the lowest churn and highest revenue.

**Data Analysis:**


