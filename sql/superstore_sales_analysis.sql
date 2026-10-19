CREATE DATABASE Superstore;
GO
/* 
   Superstore Sales Analysis
   Data exploration & cleaning
   Source table : dbo.sales_raw   (imported train.csv, 9,800 rows)
   Output table : dbo.sales_clean
    */

USE Superstore;
GO

----First check: number of rows (9,800)
SELECT COUNT(*) AS total_rows FROM dbo.train;

----Rename the imported table
EXEC sp_rename 'dbo.train', 'sales_raw';
GO

----PART A DATA QUALITY CHECKS
----A1.Missing values per important column
SELECT
    SUM(CASE WHEN Order_ID     IS NULL OR Order_ID     = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN Order_Date   IS NULL                       THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN Ship_Date    IS NULL                       THEN 1 ELSE 0 END) AS missing_ship_date,
    SUM(CASE WHEN Customer_ID  IS NULL OR Customer_ID  = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Postal_Code  IS NULL OR Postal_Code  = '' THEN 1 ELSE 0 END) AS missing_postal_code,
    SUM(CASE WHEN Product_ID   IS NULL OR Product_ID   = '' THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN Sales        IS NULL                       THEN 1 ELSE 0 END) AS missing_sales
FROM dbo.sales_raw;
 
----A2. Which rows have no Postal Code
SELECT City, State, COUNT(*) AS rows_without_postal_code
FROM dbo.sales_raw
WHERE Postal_Code IS NULL OR Postal_Code = ''
GROUP BY City, State;

----A3. Duplicate rows  
SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Product_ID, Sales,
       COUNT(*) AS times_found
FROM dbo.sales_raw
GROUP BY Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name,
         Segment, Country, City, State, Postal_Code, Region, Product_ID,
         Category, Sub_Category, Product_Name, Sales
HAVING COUNT(*) > 1;

----A4. Dates that cannot be converted 
SELECT Order_Date, Ship_Date
FROM dbo.sales_raw
WHERE TRY_CONVERT(DATE, Order_Date, 103) IS NULL
   OR TRY_CONVERT(DATE, Ship_Date, 103)  IS NULL;
 
----A5. Sales values that are not valid numbers or are <= 0
SELECT Sales
FROM dbo.sales_raw
WHERE TRY_CONVERT(DECIMAL(12,4), Sales) IS NULL
   OR TRY_CONVERT(DECIMAL(12,4), Sales) <= 0;

----A6. Check the categories for spelling problems / extra spaces
SELECT DISTINCT Segment   FROM dbo.sales_raw;
SELECT DISTINCT Region    FROM dbo.sales_raw;
SELECT DISTINCT Ship_Mode FROM dbo.sales_raw;
SELECT DISTINCT Category, Sub_Category FROM dbo.sales_raw ORDER BY Category, Sub_Category;
GO
 
----PART B CREATE THE CLEAN TABLE
DROP TABLE IF EXISTS dbo.sales_clean;
GO
 
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID,
                            Customer_Name, Segment, Country, City, State, Postal_Code,
                            Region, Product_ID, Category, Sub_Category, Product_Name, Sales
               ORDER BY TRY_CONVERT(INT, Row_ID)
           ) AS rn
    FROM dbo.sales_raw
)
SELECT
    TRY_CONVERT(INT, Row_ID)                    AS row_id,
    TRIM(Order_ID)                              AS order_id,
    TRY_CONVERT(DATE, Order_Date, 103)          AS order_date,
    TRY_CONVERT(DATE, Ship_Date, 103)           AS ship_date,
    TRIM(Ship_Mode)                             AS ship_mode,
    TRIM(Customer_ID)                           AS customer_id,
    TRIM(Customer_Name)                         AS customer_name,
    TRIM(Segment)                               AS segment,
    TRIM(Country)                               AS country,
    TRIM(City)                                  AS city,
    TRIM(State)                                 AS state,
    NULLIF(TRIM(CAST(Postal_Code AS NVARCHAR(20))), '') AS postal_code,
    TRIM(Region)                                AS region,
    TRIM(Product_ID)                            AS product_id,
    TRIM(Category)                              AS category,
    TRIM(Sub_Category)                          AS sub_category,
    TRIM(Product_Name)                          AS product_name,
    TRY_CONVERT(DECIMAL(12,4), Sales)           AS sales
INTO dbo.sales_clean
FROM ranked
WHERE rn = 1;          
GO

---- PART C FIX MISSING POSTAL CODES

UPDATE dbo.sales_clean
SET postal_code = '05401'
WHERE postal_code IS NULL
  AND city  = 'Burlington'
  AND state = 'Vermont';
GO

----(11 rows affected) missing postal codes (Burlington, Vermont) filled with 05401

----PART D VALIDATION OF THE CLEAN TABLE

----D1. Row count before vs after cleaning
SELECT
    (SELECT COUNT(*) FROM dbo.sales_raw)   AS raw_rows,
    (SELECT COUNT(*) FROM dbo.sales_clean) AS clean_rows;
----raw_rows=9800
----clean_rows=9799

----D2. No missing values left in key columns
SELECT
    SUM(CASE WHEN order_date  IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN ship_date   IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS null_postal_code,
    SUM(CASE WHEN sales       IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM dbo.sales_clean;

----D3. Logical check: ship date must not be before order date
SELECT COUNT(*) AS ship_before_order
FROM dbo.sales_clean
WHERE ship_date < order_date;

----D4. Date range of the data
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM dbo.sales_clean;
GO

----First_order = 2015-01-03
----last_order = 2018-12-30



----Analysis queries (KPIs + business questions)

----Create KPIs
SELECT
    ROUND(SUM(sales), 2)                                          AS total_sales,
    COUNT(DISTINCT order_id)                                      AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)               AS avg_order_value,
    COUNT(DISTINCT customer_id)                                   AS total_customers
FROM sales_clean;


----FOR Q1 

----Sales per year + growth vs previous year
WITH yearly AS (
    SELECT YEAR(order_date) AS order_year,
           SUM(sales)       AS total_sales
    FROM dbo.sales_clean
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY order_year))
        / LAG(total_sales) OVER (ORDER BY order_year) * 100, 1
    ) AS yoy_growth_pct
FROM yearly
ORDER BY order_year;

----Sales per month 
SELECT
    MONTH(order_date)           AS month_number,
    DATENAME(MONTH, order_date) AS month_name,
    ROUND(SUM(sales), 2)        AS total_sales
FROM dbo.sales_clean
GROUP BY MONTH(order_date), DATENAME(MONTH, order_date)
ORDER BY month_number;

----FOR Q2

----Sales and share (%) per category
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 1) AS pct_of_total
FROM dbo.sales_clean
GROUP BY category
ORDER BY total_sales DESC;

----Top 10 sub-categories
SELECT TOP 10
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM dbo.sales_clean
GROUP BY category, sub_category
ORDER BY total_sales DESC;

----FOR Q3

----Sales per region
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 1) AS pct_of_total,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.sales_clean
GROUP BY region
ORDER BY total_sales DESC;

----Sales per segment   
SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 1) AS pct_of_total,
    COUNT(DISTINCT customer_id) AS total_customers
FROM dbo.sales_clean
GROUP BY segment
ORDER BY total_sales DESC;


 
