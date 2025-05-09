🧮 RFM Segmentation with MySQL
This project demonstrates how to perform RFM (Recency, Frequency, Monetary) segmentation using MySQL based on a transactional sales dataset. RFM analysis is a powerful marketing technique that helps businesses segment customers based on purchasing behavior.

📊 What is RFM?
Recency (R) – How recently a customer made a purchase.

Frequency (F) – How often a customer makes a purchase.

Monetary (M) – How much money a customer spends.

These three metrics are used to group customers into segments like Champions, Loyal Customers, Promising Customers, and others, which can then inform marketing strategies.

🛠️ Project Overview
1. Database Setup
Dropped the existing rfm_sales database (if any).

Created a new database rfm_sales.

Imported transactional sales data (sample_sales_data) from a CSV file using MySQL's Table Data Import Wizard.

2. Data Exploration
Previewed and counted total rows and unique orders.

Performed year-wise and month-wise aggregations on sales and order counts.

Used CASE WHEN to pivot year-based sales and orders by month.

3. Date Handling
Converted orderdate strings into proper DATE format using STR_TO_DATE.

Extracted the first and last transaction dates.

4. RFM Segmentation Logic
Created a customer summary table with:

R_value: Days since last purchase

F_value: Total distinct orders

M_value: Total revenue per customer

Calculated RFM scores using NTILE(5) for ranking.

Created a combined RFM score and classified customers into meaningful segments.

5. Customer Segments Defined
Segments include:

🏆 Champions

💛 Loyal Customers

🌱 Potential Loyalists

🌟 Promising Customers

🛎️ Need Attention

⚠️ Others

These segments were assigned using specific RFM score combinations via CASE statements.

📂 Output
The final view rfm contains:

Each customer's R, F, M scores

Total RFM score

RFM combination

Assigned segment label

🧠 Skills Demonstrated
SQL Aggregation and Window Functions (NTILE, CASE)

Data transformation and pivoting

Customer behavior analysis using RFM

MySQL view creation and optimization

📬 Contact
If you have any questions or feedback, feel free to reach out or open an issue.
