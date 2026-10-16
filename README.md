# Superstore-Sales-Analysis-
Sales analysis of Superstore data using SQL Server and Power BI 
## PROJECT OVERVIEW
This project analyzes the sales performance of a US-based retail store (Superstore) between 2015 and 2018. The goal is to identify sales trends over time, the best-performing product categories, and the most valuable regions and customer segments, and to present the results in an interactive Power BI dashboard.
## DATASET OVERVIEW
Source: Superstore Sales Dataset – Kaggle
File: train.csv
Size: ~9,800 rows, 18 columns
Key columns: Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Segment, Region, State, City, Category, Sub-Category, Product Name, Sales
## QUESTIONS
How do sales change over time (yearly and monthly)? Is there seasonality?
Which product categories and sub-categories generate the most sales?
Which regions and customer segments generate the most sales?
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

## DASHBOARD

## KEY INSIGHTS
