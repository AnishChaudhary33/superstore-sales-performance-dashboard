SELECT * from superstore

--create a table 
	CREATE TABLE superstore (
    row_id INTEGER,
    order_id TEXT,
    order_date DATE,
    ship_date DATE,
    ship_mode TEXT,
    customer_id TEXT,
    customer_name TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales NUMERIC
);

--. BASIC
--1. How many total records are present in the dataset?
SELECT COUNT(row_id) from superstore
-- SELECT COUNT(*) AS total_records
-- FROM superstore;


--2.What is the total sales value?
SELECT ROUND(SUM(sales),2)as total_sales
from superstore

--3.What is the average sales amount per order?
SELECT ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) as average_order_value
from superstore

--4.How many unique orders are there?
SELECT COUNT(DISTINCT order_id) from superstore

--5.How many unique customers are in the dataset?
SELECT COUNT(DISTINCT customer_id) from superstore

--TIME BASED ANALYSIS 
--1.What are the total sales for each year?
SELECT EXTRACT(YEAR from order_date) as year,
ROUND(SUM(sales),2) as total_sales
from superstore
GROUP BY year
ORDER by year;


-- 2.What are the monthly sales trends over time?
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales), 2) AS monthly_sales
FROM superstore
GROUP BY month
ORDER BY month;

--3. Which month has the highest total sales?
SELECT
	DATE_TRUNC('month', order_date) AS month,
	ROUND(SUM(sales),2) as highest_sales
FROM superstore
GROUP BY month
ORDER BY highest_sales DESC
LIMIT 1;

--4.How many orders were placed each month?
-- SELECT DATE_TRUNC('month', order_date) AS month,
-- 	COUNT(order_id) as total_orders
-- from superstore
-- GROUP BY month
-- ORDER BY month wrong

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY month
ORDER BY month;


--5. What is the average monthly sales value?
SELECT 
    ROUND(AVG(monthly_sales), 2) AS avg_monthly_sales
FROM (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM superstore
    GROUP BY DATE_TRUNC('month', order_date)
)


-- 🔹 CUSTOMER ANALYSIS

-- Who are the top 10 customers by total sales?
SELECT customer_name,
ROUND(SUM(sales),2) as total_sales
from superstore
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- What is the average sales per customer?
SELECT 
	ROUND(SUM(sales)/COUNT(DISTINCT customer_id),2) as avg_sales_per_customer
from superstore


-- Which customer segment generates the highest sales?
SELECT segment,
ROUND(SUM(sales),2) as total_sales
from superstore
GROUP by segment
ORDER by total_sales DESC

-- How many orders does each customer place?
SELECT customer_name,
COUNT(DISTINCT order_id) as total_order
from superstore
GROUP by customer_name
ORDER BY total_order


-- Which customers have placed the most orders?
SELECT customer_name,
COUNT(DISTINCT order_id) as total_orders
from superstore
GROUP BY customer_name
ORDER BY total_orders DESC 
LIMIT 1;

-- 🔹 ADVANCED (OPTIONAL – Bonus)

-- What percentage of total sales does each category contribute?

SELECT 
    category,
    ROUND(SUM(sales) * 100.0 / (SELECT SUM(sales) FROM superstore), 2) 
        AS sales_percentage
FROM superstore
GROUP BY category
ORDER BY sales_percentage DESC;


-- Rank products based on total sales within each category.
SELECT product_name,
ROUND(SUM(sales),2),
RANK() OVER (ORDER BY sum(sales) DESC) as sales_rank
from superstore
GROUP BY product_name

-- Identify repeat customers (customers with more than one order).
SELECT customer_name,
COUNT(DISTINCT order_id) as count_orders
from superstore
GROUP BY customer_name
HAVING COUNT(DISTINCT order_id)>1 
ORDER BY count_orders DESC


-- Create a running total of monthly sales.
SELECT 
	month,
	ROUND(monthly_sales,2) as monthly_sales,
	ROUND(SUM(monthly_sales) OVER (ORDER by month),2) as running_total
	from(
		SELECT DATE_TRUNC('month', order_date) as month,	
		SUM(sales) as monthly_sales
		from superstore
		GROUP BY month
	)t;


-- Identify top 3 products per category based on sales.
SELECT*FROM(
	SELECT
		product_name,
		category,
			ROUND(SUM(sales),2) as total_sales,
            RANK()OVER(PARTITION BY category   
				ORDER BY SUM(sales)DESC
		) As rank
from superstore
GROUP BY product_name,category) rank_pro
	WHERE rank<=3;


-- Data Quality Check (Duplicates)
SELECT
	order_id,
	COUNT(*)
from superstore
GROUP BY order_id
HAVING COUNT(*)>1



--Repeat customers
SELECT customer_name,
COUNT(order_id) as total_orders
from superstore 
GROUP BY customer_name
HAVING COUNT(order_id)>1
ORDER BY total_orders DESC