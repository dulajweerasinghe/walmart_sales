select * from walmart;

drop table walmart;

-- drop table walmart 

---------------------------------------------------------
select * from walmart;

-- how many payment methods

select distinct payment_method
from walmart;

-- how many branches 

select count(distinct branch)
from walmart;

select distinct branch, count(*)
from walmart
group by branch;

-- Number of payment methods

select distinct payment_method
from walmart;

select payment_method, count(*)
from walmart
group by payment_method;

-- Business Data Analsys Part --

select max(quantity) 
from walmart;

select min(quantity) 
from walmart;

-- Business Problems --

-- Q1. What are the different payment methods, and how many transactions and items were sold with each method?

select payment_method, count(*) as no_payments, sum(quantity) as no_quantity_sold
from walmart
group by payment_method;

-- Q2. Which category received the highest average rating in each branch?
--     Display the Branch, Category, AVG Rating

select *
from walmart;

select branch, category, avg(rating) as avg_rating
from walmart
group by 1, 2
order by 1, 3 desc;


SELECT 
    branch, 
    category, 
    AVG(rating) AS avg_rating, 
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank` 
FROM 
    walmart 
GROUP BY 
    branch, category;
    
-- select which category highest in each branch --

SELECT *
FROM (
    SELECT 
        branch, 
        category, 
        AVG(rating) AS avg_rating, 
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank` 
    FROM 
        walmart 
    GROUP BY 
        branch, category
) AS ranked_categories  
WHERE `rank` = 1;  

-- Q3. What is the busiest day of the week for each branch based on transaction volume?

select *
from walmart;

-- Formatting date --
SELECT
    date,
    STR_TO_DATE(date, '%d/%m/%Y') AS formatted_date
FROM
    walmart;

-- Find a day --
SELECT
    date,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS day_name
FROM
    walmart;
    
-- Find week day and no of sales --
SELECT
    branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS day_name,
	count(*) as no_transaction
FROM
    walmart
group by 1,2
order by 1,3 desc;

-- Make it desc order--
SELECT
    branch,
    DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS day_name,
    COUNT(*) AS no_transaction,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
FROM
    walmart
GROUP BY
    branch, day_name
ORDER BY
    branch, no_transaction DESC;

-- group by each branch and find highest rank --

SELECT *
FROM (
    SELECT 
        branch, 
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%Y'), '%W') AS day_name, 
        COUNT(*) AS no_transaction, 
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank` 
    FROM 
        walmart 
    GROUP BY 
        branch, day_name
) AS ranked_transactions  
WHERE `rank` = 1;  

-- Q4. Calculate the Total quantity of the items sold per payment method.
--     List payment methods and total quantity

-- find no of quantity sold --

select payment_method, 
	count(*) as no_payments,
	sum(quantity) as no_quantity_sold
from walmart
group by payment_method;

-- find payment method vs total quantity

select payment_method, 
	sum(quantity) as no_quantity_sold
from walmart
group by payment_method;

-- Q5. What are the average, minimum, and maximum ratings for each category in each city?
-- 	   Determine the average, minimum and maximum rating of products for each city.
--     List the City, average_rating, min_rating and max_rating

select *
from walmart;

select 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by city, category;

-- Q6. What is the total profit for each category, ranked from highest to lowest ranking?
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit --

select *
from walmart;

SELECT
    category,
    SUM(total) as total_revenue,
    SUM(total + profit_margin) AS total_profit
FROM
    walmart
GROUP BY
    category;
    
-- Q7. What is the most frequently used payment method in each branch? --
--     Display Branch and the preferred payment method

select *
from walmart;

-- Group all and Ranking every Payment methods --
select 
	branch,
    payment_method,
    count(*) over(partition by branch order by count(*) desc) as 'rank'
FROM walmart
GROUP BY branch, payment_method;

-- Display highest payment methods with in branches --

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS transaction_count,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
    FROM 
        walmart
    GROUP BY 
        branch, payment_method
)
SELECT *
FROM cte
WHERE `rank` = 1;

-- Q8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
-- Find out each of the shift and number of invoices

select *
from walmart;

-- Format the time type to time --

SELECT 
	*,
    CAST(time AS TIME) AS formatted_time
FROM 
    walmart;

-- select day time --

SELECT 
    *,
    CASE 
        WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time
FROM 
    walmart;

-- Grouping and final answer --
SELECT 
	branch,
    CASE 
        WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*)
FROM 
    walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Q9. Which branches experienced the largest decrease in revenue compared to the previous year? --
-- 	   revenue campare to last year (2023 and 2022)

-- Formatting YEAR --
SELECT 
    *,
    EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) AS formatted_year
FROM 
    walmart;

-- Grouping 2022 & 2023 --

-- 2022-2023 Sales--


WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS revenue_2022,
    r2023.revenue AS revenue_2023,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

