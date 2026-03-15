# SQL Data Analytics Project

## 📊 Project Overview
This project covers end-to-end SQL-based data analytics —
from exploratory data analysis through to advanced analytics
and business reporting using a structured gold layer data warehouse.

---

## 🗺️ Analytics Roadmap

### Phase 1 — Exploratory Data Analysis (EDA)
> *"Understand the Data"*

| # | Analysis Type | Purpose |
|---|---|---|
| 1 | **Database Exploration** | Understand tables, columns, relationships |
| 2 | **Dimensions Exploration** | Explore categorical fields — countries, categories, gender |
| 3 | **Date Exploration** | Understand time range — earliest to latest dates |
| 4 | **Measures Exploration** | Calculate big numbers — total sales, total customers |
| 5 | **Magnitude Analysis** | Compare sizes across dimensions |
| 6 | **Ranking Analysis** | Identify Top N and Bottom N performers |

---

### Phase 2 — Advanced Analytics
> *"Answer Business Questions"*

| # | Analysis Type | Purpose |
|---|---|---|
| 7 | **Change-Over-Time** | Identify trends and patterns across periods |
| 8 | **Cumulative Analysis** | Running totals and growth tracking |
| 9 | **Performance Analysis** | Benchmark actual vs target vs average |
| 10 | **Part-to-Whole** | Proportional contribution of each segment |
| 11 | **Data Segmentation** | Group customers and products by behaviour |
| 12 | **Reporting** | Final business-ready dashboards and reports |

---

## 🛠️ SQL Skills Used

### EDA Phase
- Basic Queries
- Data Profiling
- Simple Aggregations
- Subqueries

### Advanced Analytics Phase
- Complex Queries
- Window Functions (ROW_NUMBER, RANK, SUM OVER)
- CTEs (Common Table Expressions)
- Subqueries
- Business Reports

---

## ✅ Why This Project

- **Real-world datasets** — gold layer data warehouse structure
- **Progressive complexity** — starts simple, builds to advanced
- **Business-focused** — every query answers a real business question
- **Interview-ready** — covers all core SQL concepts tested in data roles
- **Reusable patterns** — templates applicable across any industry dataset

---

## 📁 Project Structure
```
├── 1_exploratory_analysis/
│   ├── 01_database_exploration.sql
│   ├── 02_dimensions_exploration.sql
│   ├── 03_date_exploration.sql
│   ├── 04_measures_exploration.sql
│   ├── 05_magnitude_analysis.sql
│   └── 06_ranking_analysis.sql
│
├── 2_advanced_analytics/
│   ├── 07_change_over_time.sql
│   ├── 08_cumulative_analysis.sql
│   ├── 09_performance_analysis.sql
│   ├── 10_part_to_whole.sql
│   ├── 11_data_segmentation.sql
│   └── 12_reporting.sql
│
└── README.md
```

---

## 🗄️ Data Structure
```sql
gold.fact_sales        -- Sales transactions
gold.dim_customers     -- Customer master data
gold.dim_products      -- Product master data
```

---

## 💡 Key Concepts Demonstrated

- **EDA before analysis** — always understand your data first
- **Layered complexity** — simple aggregations → window functions → CTEs
- **Business storytelling** — translating SQL outputs into actionable insights
- **Gold layer architecture** — working with a structured data warehouse

---

## 🔧 Tools Used

- SQL Server / Azure SQL
- Jupyter Notebook
- Git & GitHub

---

## 👤 Author
**Praveen C**
MSc Data Science & AI — Sheffield Hallam University
[GitHub](https://github.com/) | [LinkedIn](https://linkedin.com/)
