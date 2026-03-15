----— Advanced Analytics
---*"Answer Business Questions"*

-- 7.Analyze Sales Performance Over Time
use DataWarehouseAnalytics;
select 
YEAR(order_date) as order_year,
Month(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date),Month(order_date)
order by year(order_date),Month(order_date);

--DATE TRUNC

select 
DATETRUNC(month,order_date) as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
order by DATETRUNC(month,order_date);

--FROMTE (SORTING ISUUE)

select 
FORMAT(order_date,'yyy-MMMMM') as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by FORMAT(order_date,'yyy-MMMMM')
order by FORMAT(order_date,'yyy-MMMMM');

--2.sales_amount and price same ?

SELECT 
    COUNT(*)                                        AS total_rows,
    SUM(CASE WHEN price = sales_amount THEN 1 ELSE 0 END) AS matching_rows,
    SUM(CASE WHEN price != sales_amount THEN 1 ELSE 0 END) AS mismatching_rows
FROM gold.fact_sales;

----8 . Cumulative analysis [ Cummulative aggregate fuctions ]
--( calculate the total sales per month and te running total of sales over time)

--normal total (no cummulative)
select 
DATETRUNC(month,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)

--Cumulative total(month wise)

select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sal
FROM (
select 
DATETRUNC(month,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
) t

--Cumulative total(year wise)
select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sal
FROM (
select 
DATETRUNC(year,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year,order_date)
) t


--cummulative  average 
select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sal,
avg(avg_price) over (order by order_date) as moving_avearge_price
FROM (
select 
DATETRUNC(year,order_date) as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year,order_date)
) t


--moving average 
select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sal,
AVG(avg_price) OVER (
    ORDER BY order_date 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  -- 3-period moving avg
) AS moving_average_price FROM (
select 
DATETRUNC(year,order_date) as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year,order_date)
) t


----9. Perfomance analysis (current value vs target value)

--Performance = Current [Measure] - Target [Measure]
--Performance analysis is always Current minus Target — the target changes depending on the business question. 
--Window functions make all three targets easy to compute in one query.


/*Task
Analyze the yearly performance of products by comparing their 
sales to both the average sales performance of the product and the previous year's sales.*/

--SOLVED -the yearly performance of products
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where f.order_date is not null
group by year(f.order_date),
p.product_name;

--CTE _FINAL RESULT 
with yearly_product_sales AS (
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where f.order_date is not null
group by year(f.order_date),
p.product_name)

select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) as avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
CASE WHEN current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above avg'
    when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below avg'
    else 'Avg'
end avg_change,
--year over year analysis 
LAG(current_sales) over (partition by product_name order by order_year) prev_year_sales,
current_sales - LAG(current_sales) over (partition by product_name order by order_year) as diff_prev_year,
CASE WHEN current_sales - LAG(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
    when current_sales - LAG(current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
    else 'No change'
END as py_chnage
from yearly_product_sales
order by product_name,order_year;

----10. PART TO WHOLE ANALYSIS 

/* which category contribute the most to overall sales ?*/
with category_sales as(
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.category)

select 
category,
total_sales,
sum(total_sales) over () overall_sales,
concat(round((cast(total_sales as float)/sum(total_sales) over ())*100,2),'%') as sales_percentage
from category_sales
order by sales_percentage desc;


----11.DATA SEGMENTATION 

/*Segmentation = CASE WHEN to label rows + GROUP BY to count them. Always think in terms of "how many X fall into each bucket?"*/

/*TASK -1
segment products into cost ranges and count how many products fallinto each segemnst*/

with product_segments as (
select 
product_key,
product_name,
cost ,
CASE WHEN cost < 100 THEN 'Below 100'
    WHEN cost BETWEEN 100 AND 500 THEN '100-500'
    WHEN cost BETWEEN 500 AND 1000THEN '500-1000'
    ELSE 'Above 1000'
END cost_range
from gold.dim_products)

select 
cost_range,
count(product_name) as total_product
from product_segments
group by cost_range
order by total_product desc;



/* TASK -2 
Group customers into three segments based on their spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than €5,000.
    - Regular: Customers with at least 12 months of history but spending €5,000 or less.
    - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
--CTE
with customer_spending as(
select 
c.customer_key,
sum(f.sales_amount) as total_spendings,
max(order_date) as first_order,
min(order_date) as last_order,
DATEDIFF(month,min(order_date),max(order_date)) as life_span
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key)

--subquery 

select 
customer_segment,
count(customer_key) total_customers
from(select 
    customer_key,
    CASE 
        WHEN life_span >=12 AND total_spendings > 5000   then 'VIP'
        WHEN life_span >=12 AND total_spendings <= 5000  then 'Regular'
        ELSE 'New'
    end as customer_segment
    from customer_spending
    ) t
group by customer_segment
order by total_customers desc;



/*===========================================================================
----12.Product Report - 1
=============================================================================*/
/*
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
===========================================================================
*/
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
--
--create view gold.report_customer as
with base_query  as (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)


, 
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
customer_aggregation AS (
SELECT  
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
group by 
    customer_key,
    customer_number,
    customer_name,
    age)

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE
    WHEN age < 20 THEN 'Under 20'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50 and above'
END AS age_group,
CASE
    WHEN lifespan >= 12 AND total_sales > 5000  THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(month ,last_order_date,GETDATE()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
lifespan,
-- Compute average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
    ELSE total_sales / total_orders
END AS avg_order_value,
-- Compute average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation;


/*
===========================================================================
Product Report - 2
===========================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
===========================================================================
*/


WITH base_query AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        f.order_number,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        f.order_date
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
),

product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number)   AS total_orders,
        SUM(sales_amount)              AS total_sales,
        SUM(quantity)                  AS total_quantity,
        COUNT(DISTINCT customer_key)   AS total_customers,
        MAX(order_date)                AS last_order_date,
        MIN(order_date)                AS first_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    last_order_date,
    first_order_date,
    lifespan,

    -- Recency: months since last sale
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Revenue Segmentation
    CASE
        WHEN total_sales >= 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS revenue_segment,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations
ORDER BY total_sales DESC;