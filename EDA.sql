UPDATE Fact_sales
Set date_time =  str_to_date(date_time, '%Y-%m-%d');

-- Project Overview: Sales and Profitability Analysis

-- 1) Profit Margin Calculation for each Product (Top 10 Products by Profit Margin) 
WITH cte as(
SELECT p.Product_Name, ROUND(SUM(s.Sales_USD)) as Sales, ROUND(SUM(s.COGS_USD)) as Cost
FROM fact_sales s
INNER JOIN dim_product p ON
s.Product_id = p.Product_Name_id
GROUP BY 1
)
SELECT RANK()OVER(ORDER BY Round(((Sales-Cost)/ sales) * 100,2)  DESC ) as Ranks,
Product_name, Sales,Cost,Round(((Sales-Cost)/ sales) * 100,2) AS Profit_Margin
FROM cte
LIMIT 10;



-- DQL
Alter Table fact_sales
add column COGS_per_unit double;

update fact_sales
Set COGS_per_unit = (cogs_USD / quantity);

SELECT Distinct DENSE_RANK() OVER(ORDER BY ROUND(((Price_USD-COGs_per_unit)/Price_USD)*100,2) DESC) as RANKS,
p.Product_Name, ROUND(Price_USD,2) as Price_USD,ROUND(COGS_per_unit,2) as COGS_per_unit, 
ROUND(((Price_USD-COGs_per_unit)/Price_USD)*100,2) as Profit_Margin
FROM fact_sales s
INNER JOIN dim_product p 
ON s.Product_id = p.Product_Name_id
LIMIT 10;


-- Monthly Trends
-- what are the monthly Profit Trends

Alter table fact_sales
add column profit double;

UPDATE fact_sales
set profit = sales_usd - cogs_usd;

SELECt RANK() OVER(PARTITION BY year(date_time) ORDER BY sum(profit) DESC) as Ranks
,year(date_time) as Year,
month(date_time) as Month,monthname(date_time) as Monthday, Round(sum(profit),2) as Profit
FROM fact_sales
GROUP BY 2,3,4;

-- Monthly profit rolling count
with cte as(
SELECT year(date_time) Year,month(date_time) as month, monthname(date_time) AS monthname, ROUND(sum(profit),0) as Profit
FROM fact_sales
GROUP BY 1,2,3)

SELECT *, ROUND(sum(profit) over(PARTITION BY year ORDER BY month
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) as Rolling_Profit
FROM CTE 	
group by 1,2,3;

-- Top 10 Profitable Products
SELECT RANK()OVER(ORDER BY ROUND(SUM(Profit)) DESC) as Ranks,P.Product_Name,ROUND(SUM(Profit)) as Profit
FROM fact_sales s 
INNER JOIN dim_product p
ON s.Product_id = p.Product_Name_id 
GROUP BY 2
LIMIT 10;

-- Top 10 product Types in profit
SELECT RANK()OVER(ORDER BY ROUND(SUM(Profit)) DESC) as Ranks,p.product_family
,ROUND(SUM(Profit)) as Profit
FROM fact_sales s 
INNER JOIN dim_product p
ON s.Product_id = p.Product_Name_id 
GROUP BY 2
LIMIT 10;

-- Customer and account performances
-- Top 10 accounts by Revenue and Profits

SELECT RANK()OVER(ORDER BY ROUND(SUM(sales_USD)) DESC) as Ranks,a.Account,ROUND(SUM(Profit)) as Profit
,ROUND(SUM(Sales_USD)) as Sales
FROM fact_sales s 
INNER JOIN dim_accounts a
ON s.Account_id = a.Account_id 
GROUP BY 2
LIMIT 10;

-- Identify accounts with frequent sales but not large sums (Accounts wtih potential but low sales)
-- benchmarks are country average sales frequency and country avg sales
-- to be a potential account it must have more than avg sales count and less than avg ordder value per country

-- First CTE with the account sales info 
  WITH Account_sales as( SELECT 
        a.Account_id,
        a.Account,
        a.Country2 as Country,
        COUNT(f.Product_id) AS Total_Orders,
        SUM(f.Sales_USD) AS Total_Sales,
        AVG(f.Sales_USD) AS Avg_Order_Value
	FROM fact_sales f
    INNER JOIN dim_accounts a ON f.Account_id = a.Account_id
    GROUP BY 1,2,3)

-- Country benchmarks to compare
, Country_benchm as(
SELECT  country, ROUND(avg(Total_orders)) as avg_country_orders, 
ROUND(Avg(Total_sales))AS avg_country_sales
FROM account_sales
GROUP BY 1)

SELECT s.account_id, s.account, s.country, s.Total_Orders as Order_count, ROUND(Total_sales)as Total_Sales,c.avg_country_orders,c.avg_country_sales	
FROM account_sales s
INNER JOIN country_benchm c
ON c.country = s.country
WHERE s.Total_orders > c.avg_country_orders
AND s.Total_sales < c.avg_country_sales;

-- what we can do with this is implement discount strategies or upsell to those accounts 
-- as they are purchasing frequently but not gerenating lots of sales

-- Identifying Underperforming products in high demand categories (TOP 10 categories by sales)
WITH Products as (
Select p.Product_Name,Product_Family,ROUND(SUM(sales_usd)) as Sales
FROM Fact_sales s
INNER JOIN 
dim_product p
ON s.product_id = p.Product_Name_id
GROUP BY 1,2
ORDER BY 3 desc
)
,Family as(
SELECT Product_family, Sum(Sales) as Family_Sales, ROUND(AVG(Sales)) as Avg_sale_per_Product
FROM products
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
)

SELECT product_name,f.Product_family, p.Sales,f.Avg_sale_per_Product
FROM Products p
INNER JOIN Family f on p.product_family = f.product_family
WHERE p.sales < f.Avg_sale_per_Product ;

-- What we can do for these products is maybe provide discounts on the products or consider using different 
-- strategies as their respected categories are successfull which means they have higher chances of success


-- Customer and country churn analysis
-- identify customers who made a purchase in the past but haven't returned and countries with more churn%
-- (Benchmark for churn is that customers  havent purchased since 2 years)
WITH cte AS(
SELECT s.Account_id, a.Account,a.country2 as Country, max(s.Date_Time) as Last_sale
FROM fact_sales s
INNER JOIN dim_accounts a ON s.account_id = a.Account_id
GROUP BY 1,2,3
)
-- Can use this to offer dicounts to induce those customers to return to us
, churned_customers as(
SELECT * 
FROM CTE
WHERE last_sale <= curdate() - Interval 2 Year
Order by last_sale Desc )
, churn_country as(
Select Country, count(*) AS churned_count
FROM churned_customers
GROUP BY 1
ORDER BY 2 DESC)
, country_counts as(
SELECT Country2 as country, count(*) as total_count
FROM dim_accounts
GROUP BY 1
ORDER BY 2 DESC)
-- Countries and their total users and churned and churn percentage
-- can use this to focus or implement retention strategies for different countries
SELECT ch.country, ch.churned_count, co.total_count, ROUND((churned_count / total_count) * 100,2) 
as churn_percentage
FROM Churn_country ch
INNER JOIN country_counts co on ch.country = co.country
ORDER BY Total_count DESC




