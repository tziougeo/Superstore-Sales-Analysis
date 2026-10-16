# Superstore-Sales-Analysis-
Sales analysis of Superstore data using SQL Server and Power BI 
## PROJECT OVERVIEW
This project analyzes the sales performance of a US-based retail store (Superstore) between 2015 and 2018. The goal is to identify sales trends over time, the best-performing product categories, and the most valuable regions and customer segments, and to present the results in an interactive Power BI dashboard.
## DATASET OVERVIEW
Source: Superstore Sales Dataset – Kaggle  
File: train.csv  
Size: 9,800 rows, 18 columns  
Key columns: Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Segment, Region, State, City, Category, Sub-Category, Product Name, Sales
## QUESTIONS
Q1:How do sales change over time (yearly and monthly)? Is there seasonality?  
Q2:Which product categories and sub-categories generate the most sales?  
Q3Which regions and customer segments generate the most sales?
## KPIs
| KPI | Description |
|---|---|
| Total Sales | Sum of all sales |
| Total Orders | Number of unique orders |
| Average Order Value | Total Sales / Total Orders |
| Total Customers | Number of unique customers |

## DATA IMPORT & TOOLS
SQL Server (SSMS): data import, cleaning, and analysis queries  
Power BI: data modeling, DAX measures, and dashboard  
GitHub: version control and documentation

## PROJECT STRUCTURE
```
superstore-sales-analysis/
├── README.md
├── data/
│   ├── raw/train.csv
│   └── clean/superstore_clean.csv
├── sql/
│   ├── 01_create_and_import.sql
│   ├── 02_data_cleaning.sql
│   └── 03_analysis_queries.sql
├── powerbi/
│   └── Superstore_Sales.pbix
└── images/
    └── dashboard.png
```
## DATA CLEANING
Data was imported into SQL Server as a raw table (`sales_raw`) and cleaned into a new table (`sales_clean`) using `sql/02_data_cleaning.sql`.

| Check | Finding | Action |
|---|---|---|
| Missing values | 11 missing postal codes, all for Burlington, Vermont | Filled with Burlington's postal code (05401) |
| Duplicates | 1 duplicate row (order US-2015-150119) | Removed, kept one copy |
| Dates | Stored as text in dd/mm/yyyy format | Converted to `DATE` |
| Sales | Stored as text | Converted to `DECIMAL`; no invalid or negative values found |
| Text columns | Possible extra spaces | Trimmed |
| Logic check | Ship date before order date | None found |

**Result:** 9,800 raw rows → 9,799 clean rows.
## Analysis
The analysis was performed in SQL Server using `sql/03_analysis_queries.sql`, based on the clean table (`sales_clean`).

### KPIs
Calculated Total Sales, Total Orders, Average Order Value and Total Customers to give an overall view of the business.

### Q1. Sales over time
- Total sales per year, with year-over-year growth (%) using the `LAG()` window function
- Total sales per month across all years, to identify seasonality

### Q2. Product performance
- Total sales and share (%) of total sales per category
- Top 10 sub-categories by sales

### Q3. Regions and customer segments
- Total sales, share (%) and number of orders per region
- Total sales, share (%) and number of customers per segment

**SQL techniques used:** aggregate functions (`SUM`, `COUNT DISTINCT`), `GROUP BY`, CTEs, window functions (`LAG`, `SUM() OVER()`), date functions (`YEAR`, `MONTH`, `DATENAME`).
## DASHBOARD

## KEY INSIGHTS
