# Walmart Data Analysis: End-to-End SQL + Python Project 

## Project Overview
![Project Pipeline](https://github.com/dulajweerasinghe/walmart_sales/blob/main/Designer%20(1).jpeg)

This project presents a comprehensive end-to-end data analysis solution, focused on deriving critical business insights from Walmart sales data. By leveraging Python for robust data processing and analysis, alongside SQL for sophisticated querying, the project applies structured problem-solving methodologies to address key business challenges. Designed for data analysts, this project offers an opportunity to enhance expertise in data manipulation, SQL querying, and the development of data pipelines, fostering the skills needed for advanced data-driven decision-making.

---

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, mySQL 
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas numpy sqlalchemy mysql-connector-python psycopg2
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into MySQL and PostgreSQL
   - **Set Up Connections**: Connect to MySQL and PostgreSQL using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up tables in both MySQL and PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
   ### Q1. What are the different payment methods, and how many transactions and items were sold with each method?

```sql
SELECT 
    payment_method, 
    COUNT(*) AS no_payments, 
    SUM(quantity) AS no_quantity_sold 
FROM walmart 
GROUP BY payment_method;
```
   ### Q2. Which category received the highest average rating in each branch?
```sql
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
```
   ### Q3. What is the busiest day of the week for each branch based on transaction volume?
```sql
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
```
   ### Q4. Calculate the Total quantity of the items sold per payment method.
```sql
select payment_method, 
	sum(quantity) as no_quantity_sold
from walmart
group by payment_method;
```
   ### Q5. What are the average, minimum, and maximum ratings for each category in each city?
```sql
select 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by city, category;
```
   ### Q6. What is the total profit for each category, ranked from highest to lowest ranking?
```sql
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
```
   ### Q8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
```sql
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
```
### Q9. Which branches experienced the largest decrease in revenue compared to the previous year's?
```sql
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

```
### 10. Project Publishing and Documentation
   - **Documentation**: Maintain well-structured documentation of the entire process in Markdown or a Jupyter Notebook.
   - **Project Publishing**: Publish the completed project on GitHub or any other version control platform, including:
     - The `README.md` file (this document).
     - Jupyter Notebooks (if applicable).
     - SQL query scripts.
     - Data files (if possible) or steps to access them.

---

## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** (for data downloading)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.

---

## Project Structure

```plaintext
|-- data/                     # Raw data and transformed data
|-- sql_queries/              # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
|-- requirements.txt          # List of required Python libraries
|-- main.py                   # Main script for loading, cleaning, and processing data
```
---

## Results and Insights

This section will include your analysis findings:
- **Sales Insights**: Key categories, branches with highest sales, and preferred payment methods.
- **Profitability**: Insights into the most profitable product categories and locations.
- **Customer Behavior**: Trends in ratings, payment preferences, and peak shopping hours.

## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.

---

## License

This project is licensed under the MIT License. 

---

## Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.

---
