# Plants Co. SQL Performance & Profitability Analysis
## Analyzing revenue, profit trends, and customer churn

This repository contains SQL queries for an in-depth EDA and business performance analysis using a sales dataset. The queries cover profitability analysis, customer churn, product performance, and account insights to optimize business decisions.

---

## Key Analyses Included

### Profitability & Performance
- **Top 10 Products by Profit Margin**: Identifies the most profitable products.
- **Monthly Profit Trends**: Tracks profitability over time.
- **Rolling Profit Calculation**: Cumulative profit trend across months.
- **Top Profitable Products & Product Types**: Ranks products and product families based on total profit.
 ![Screenshot 2025-02-22 152006](https://github.com/user-attachments/assets/c265041d-baba-482a-a571-49ee3472524b)


### Account & Sales Insights
- **Top 10 Accounts by Revenue & Profit**: Highlights high-value customers.
- **Potential Accounts with High Frequency & Low Sales**: Identifies accounts that buy frequently but generate low revenue (good targets for upselling).
  ![Screenshot 2025-02-22 152238](https://github.com/user-attachments/assets/fc9a38b7-f2f0-4252-a939-749b62821933)

  ![Screenshot 2025-02-22 152306](https://github.com/user-attachments/assets/10e5dc91-16b0-46c4-9ec3-59bb47841ba2)



### Churn & Retention Analysis
- **Churned Customers & Churn Rate per Country**: Finds customers who haven't purchased in over two years and calculates country-level churn rates.
- **Retention Strategies**: Identifies potential strategies like discounts for churned customers.

### Product Performance
- **Top 10 Product Categories by Sales**: Identifies high-demand categories.
- **Underperforming Products in High-Demand Categories**: Highlights products that need improvement or better marketing strategies.

---

## Technologies Used
- SQL (MySQL / PostgreSQL compatible syntax)
- Common Table Expressions (CTEs)
- Window Functions (`RANK()`, `DENSE_RANK()`, `SUM() OVER()`)
- Joins & Aggregations (`GROUP BY`, `AVG()`, `COUNT()`)

---



## Insights & Recommendations
- **Retention Strategies:** Implement loyalty programs for high-churn countries.
- **Upselling Opportunities:** Target accounts with frequent orders but low sales.
- **Product Pricing Optimization:** Adjust pricing for underperforming products in high-demand categories.
