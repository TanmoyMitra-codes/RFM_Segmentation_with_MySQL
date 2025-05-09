
-- -----------------------------------------------------
-- Project: RFM Segmentation using MySQL
-- Author: [Tanmoy Mitra]
-- Description: This script performs data import, exploration,
--              and RFM segmentation on sales data.
-- -----------------------------------------------------

-- Drop existing database if it exists
DROP DATABASE IF EXISTS rfm_sales;

-- Create a new database
CREATE DATABASE rfm_sales;
USE rfm_sales;

-- -----------------------------------------------------
-- STEP 1: Data Import (performed via MySQL Import Wizard)
-- Table: sample_sales_data
-- -----------------------------------------------------

-- Preview data
SELECT * FROM sample_sales_data LIMIT 10;

-- Total rows in the dataset
SELECT COUNT(*) FROM sample_sales_data;

-- Total unique orders
SELECT COUNT(DISTINCT ordernumber) AS total_unique_orders FROM sample_sales_data;

-- View data ordered by order and line number
SELECT
    ordernumber,
    orderlinenumber,
    *
FROM sample_sales_data
ORDER BY ordernumber, orderlinenumber;

-- -----------------------------------------------------
-- STEP 2: Sales Aggregation
-- -----------------------------------------------------

-- Year and month wise aggregation
SELECT 
    year_id AS year,
    month_id AS month,
    COUNT(DISTINCT ordernumber) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT ordernumber), 2) AS avg_sales_per_order
FROM sample_sales_data
GROUP BY year, month
ORDER BY year DESC, month;

-- Pivot sales and order counts by year
SELECT 
    month_id AS month,
    COUNT(DISTINCT CASE WHEN year_id = 2003 THEN ordernumber END) AS total_orders_2003,
    COUNT(DISTINCT CASE WHEN year_id = 2004 THEN ordernumber END) AS total_orders_2004,
    COUNT(DISTINCT CASE WHEN year_id = 2005 THEN ordernumber END) AS total_orders_2005,
    ROUND(SUM(CASE WHEN year_id = 2003 THEN sales ELSE 0 END), 2) AS total_sales_2003,
    ROUND(SUM(CASE WHEN year_id = 2004 THEN sales ELSE 0 END), 2) AS total_sales_2004,
    ROUND(SUM(CASE WHEN year_id = 2005 THEN sales ELSE 0 END), 2) AS total_sales_2005
FROM sample_sales_data
GROUP BY month_id;

-- -----------------------------------------------------
-- STEP 3: Date Handling
-- -----------------------------------------------------

-- Convert string to date and get min/max order dates
SELECT MIN(STR_TO_DATE(orderdate, '%d/%m/%y')) AS first_business_day FROM sample_sales_data;
SELECT MAX(STR_TO_DATE(orderdate, '%d/%m/%y')) AS last_business_day FROM sample_sales_data;

-- -----------------------------------------------------
-- STEP 4: RFM Segmentation
-- -----------------------------------------------------

-- Create RFM View for segmentation
CREATE OR REPLACE VIEW rfm AS
WITH customer_summary AS (
    SELECT
        customername,
        DATEDIFF(
            (SELECT MAX(STR_TO_DATE(orderdate, '%d/%m/%y')) FROM sample_sales_data),
            MAX(STR_TO_DATE(orderdate, '%d/%m/%y'))
        ) AS R_value,
        COUNT(DISTINCT ordernumber) AS F_value,
        ROUND(SUM(sales), 0) AS M_value
    FROM sample_sales_data
    GROUP BY customername
),
rfm_score AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY R_value DESC) AS R_score,
        NTILE(5) OVER (ORDER BY F_value) AS F_score,
        NTILE(5) OVER (ORDER BY M_value) AS M_score
    FROM customer_summary
),
rfm_combined AS (
    SELECT
        *,
        (R_score + F_score + M_score) AS total_score,
        CONCAT(R_score, F_score, M_score) AS RFM_combination
    FROM rfm_score
)
SELECT
    *,
    CASE
        WHEN RFM_combination IN ('455','515','542','544','552','553','452','545','551','554','555') THEN 'Champion'
        WHEN RFM_combination IN ('344','345','353','354','355','414','415','443','451','342','351','352','441','442','444','445','453','454','541','543') THEN 'Loyal Customer'
        WHEN RFM_combination IN ('513','413','511','411','512','341','412','343','514') THEN 'Potential Loyalist'
        WHEN RFM_combination IN ('214','211','212','213','241','251','312','314','311','313','315','243','245','252','253','255','242','244','254') THEN 'Promising Customer'
        WHEN RFM_combination IN ('141','142','143','144','151','152','155','145','153','154','215') THEN 'Need Attention'
        WHEN RFM_combination IN ('113','111','112','114','115') THEN 'Need Attention'
        ELSE 'Others'
    END AS customer_segment
FROM rfm_combined;

-- Preview final RFM output
SELECT * FROM rfm;
