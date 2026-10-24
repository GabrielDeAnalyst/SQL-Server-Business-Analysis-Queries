# SQL Server Business Analysis Queries

A collection of SQL Server (T-SQL) queries that answer more than 50 business questions on a sales database, arranged from beginner to advanced. The questions cover sales, customers, products, payments, employees, customer support and marketing.

## Database

The queries run against a database with 10 tables:

| Table | What it holds |
|---|---|
| `Customers` | customer details, city, state, segment and signup date |
| `Products` | product name, category, supplier and unit price |
| `Orders` | orders, status, sales channel, shipping city and handling employee |
| `OrderItems` | line items with quantity, unit price and discount |
| `Payments` | payment amount, method and status for each order |
| `Employees` | employee details, job title, salary, department and manager |
| `Departments` | department names and locations |
| `SupportTickets` | support tickets with priority, status and satisfaction score |
| `MarketingCampaigns` | campaigns with target segment, channel and budget |
| `CampaignResponses` | customer responses to campaigns and converted orders |

The sample data has 15 customers, 12 products, 55 orders (January 2024 to February 2025) with 143 order items, 46 payments, 12 employees in 6 departments, 35 support tickets, and 6 marketing campaigns with 65 responses.

**Data source:** The data is a sample dataset used for practice. It does not contain confidential information.

## What the queries cover

**Beginner:** filtering with `WHERE`, sorting, `COUNT`, `SUM`, `AVG`, `MIN` and `MAX`, and grouping with `GROUP BY`.

**Intermediate:** `INNER JOIN` and `LEFT JOIN` across several tables, self joins for employees and their managers, finding records with no match (customers who never ordered, products never sold), revenue by customer, category and month, and `TOP` queries.

**Advanced:** common table expressions (CTEs), `RANK()`, running totals with `SUM() OVER`, month-over-month change with `LAG()`, `CASE`-based customer segmentation, and comparing each employee's salary with their department average.

## Example business questions

- Which customers have never placed an order?
- What is the total revenue by product category?
- Which paid orders have a payment lower than the calculated order value?
- How does monthly revenue change from one month to the next?
- Who are the top 5 customers by total order value?
- Which employees earn more than the average in their department?

## Repository structure

```
├── database_setup.sql        # creates the 10 tables and loads the data
├── practice_queries.sql      # all queries, grouped by difficulty, each with a comment
└── README.md
```

## How to run

1. Open SQL Server Management Studio (SSMS), connect to your server, and create an empty database, for example `CREATE DATABASE SalesAnalysis;`.
2. Select that database, open `database_setup.sql`, and press **F5**. This creates the 10 tables and fills them with data.
3. Open `practice_queries.sql` and read the assumptions at the top of the file.
4. Select a query and press **F5** to run it.

Each query starts with an ID (B01 for beginner, I01 for intermediate, A01 for advanced) and a comment that says what it does.

## Skills demonstrated

T-SQL, joins, aggregation, subqueries and CTEs, window functions, date handling, `CASE` logic, and translating business questions into queries.

## Author

**Olaogun Gabriel Olatunji**
CS graduate and Research Assistant, LAUTECH
[GitHub](https://github.com/GabrielDeAnalyst)
