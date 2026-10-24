/* ============================================================================
   SQL SERVER BUSINESS ANALYSIS QUERIES
   Author   : Olaogun Gabriel Olatunji
   Database : Sales database with 10 tables (Customers, Products, Orders,
              OrderItems, Payments, Employees, Departments, SupportTickets,
              MarketingCampaigns, CampaignResponses)
   Levels   : Beginner (B01-B25), Intermediate (I01-I22), Advanced (A01-A05),
              Extra (X01-X02)

   NOTES
   1. Set up the database first by running database_setup.sql.
   2. DiscountPercent is a whole-number percentage (the data holds 0, 5, 10
      and 15, so 10 means 10%). If you use other data where it is stored as a
      decimal (0.10 means 10%), replace "DiscountPercent / 100.0" with
      "DiscountPercent" in every query.
   3. Revenue queries count orders of every status (Completed, Pending,
      Cancelled and Returned). To count completed sales only, add
      o.OrderStatus = 'Completed' to the WHERE clause.

   Line total used in all revenue queries:
      Quantity * UnitPrice * (1 - DiscountPercent / 100.0)
   ============================================================================ */


/* ============================================================================
   BEGINNER QUERIES
   ============================================================================ */

-- B01 | Customer location and segment
-- Lists the city, state and segment of every customer.
SELECT City, State, Segment
FROM Customers;

-- B02 | Product catalogue
-- Lists every product with its name, category, supplier and unit price.
SELECT ProductName, Category, SupplierName, UnitPrice
FROM Products;

-- B03 | Customers located in Lagos
-- Returns all customer records where the city is Lagos.
SELECT *
FROM Customers
WHERE City = 'Lagos';

-- B04 | Orders placed through the Website channel
-- Returns all orders whose sales channel is Website.
SELECT *
FROM Orders
WHERE SalesChannel = 'Website';

-- B04b | Bonus: number of orders per sales channel
-- Counts the orders in each sales channel, largest channel first.
SELECT SalesChannel, COUNT(*) AS TotalOrders
FROM Orders
GROUP BY SalesChannel
ORDER BY TotalOrders DESC;

-- B05 | Products priced above 50,000
-- Returns the products whose unit price is greater than 50,000.
SELECT *
FROM Products
WHERE UnitPrice > 50000;

-- B06 | Completed orders, newest first
-- Returns all completed orders sorted from the latest order date to the earliest.
SELECT *
FROM Orders
WHERE OrderStatus = 'Completed'
ORDER BY OrderDate DESC;

-- B07 | Customers who signed up in 2024
-- Uses a date range (not YEAR()) so SQL Server can use an index on SignupDate.
SELECT *
FROM Customers
WHERE SignupDate >= '2024-01-01'
  AND SignupDate <  '2025-01-01';

-- B08 | Employees and their job titles
-- Shows each employee's full name with their job title.
SELECT FirstName + ' ' + LastName AS FullName, JobTitle
FROM Employees;

-- B09 | Departments and their locations
-- Lists every department with its location.
SELECT DepartmentName, Location
FROM Departments;

-- B10 | High and urgent support tickets
-- Returns the support tickets whose priority is High or Urgent.
SELECT *
FROM SupportTickets
WHERE Priority IN ('High', 'Urgent');

-- B11 | Payments with status Paid
-- Returns all payment records that have been paid.
SELECT *
FROM Payments
WHERE PaymentStatus = 'Paid';

-- B12 | Marketing campaigns targeting Retail customers
-- Returns the campaigns whose target segment is Retail.
SELECT *
FROM MarketingCampaigns
WHERE TargetSegment = 'Retail';

-- B13 | Products in the Electronics category
-- Returns all products in the Electronics category.
SELECT *
FROM Products
WHERE Category = 'Electronics';

-- B14 | Pending or cancelled orders
-- Returns the orders whose status is Pending or Cancelled.
SELECT *
FROM Orders
WHERE OrderStatus IN ('Pending', 'Cancelled');

-- B15 | Payments made by bank transfer
-- Returns the payment records where the method is Bank Transfer.
SELECT *
FROM Payments
WHERE PaymentMethod = 'Bank Transfer';

-- B16 | Total number of customers
-- Counts all rows in the Customers table.
SELECT COUNT(*) AS TotalCustomers
FROM Customers;

-- B17 | Number of products per category
-- Counts the products in each category.
SELECT Category, COUNT(*) AS TotalProducts
FROM Products
GROUP BY Category
ORDER BY TotalProducts DESC;

-- B18 | Average product price by category
-- Calculates the average unit price in each category, highest first.
SELECT Category, CAST(AVG(UnitPrice) AS DECIMAL(18, 2)) AS AvgUnitPrice
FROM Products
GROUP BY Category
ORDER BY AvgUnitPrice DESC;

-- B19 | Total campaign budget by marketing channel
-- Adds up the budgets of all campaigns in each marketing channel.
-- Assumes the column is called Channel (see assumption 3 at the top).
SELECT Channel, SUM(Budget) AS TotalBudget
FROM MarketingCampaigns
GROUP BY Channel
ORDER BY TotalBudget DESC;

-- B20 | Support tickets by status
-- Counts the support tickets in each ticket status.
SELECT TicketStatus, COUNT(*) AS TotalTickets
FROM SupportTickets
GROUP BY TicketStatus
ORDER BY TotalTickets DESC;

-- B21 | Lowest and highest monthly salary
-- Returns the smallest and largest monthly salary among employees.
SELECT MIN(MonthlySalary) AS LowestMonthlySalary,
       MAX(MonthlySalary) AS HighestMonthlySalary
FROM Employees;

-- B22 | Products supplied by VisionHub
-- Lists the products whose supplier is VisionHub.
SELECT ProductName
FROM Products
WHERE SupplierName = 'VisionHub';

-- B23 | Orders shipped to Lagos
-- Returns the orders whose shipping city is Lagos.
SELECT *
FROM Orders
WHERE ShippingCity = 'Lagos';

-- B24 | Campaign responses that led to a purchase
-- Returns the campaign responses whose response type is Purchased.
SELECT *
FROM CampaignResponses
WHERE ResponseType = 'Purchased';

-- B25 | Orders placed after 1 January 2025
-- Returns orders from 2 January 2025 onward. Using >= '2025-01-02' also
-- works if OrderDate stores a time, because every time on 1 January is excluded.
SELECT *
FROM Orders
WHERE OrderDate >= '2025-01-02';


/* ============================================================================
   INTERMEDIATE QUERIES
   ============================================================================ */

-- I01 | Orders with customer name, date, status and channel
-- Joins Orders to Customers to show who placed each order.
SELECT o.OrderID,
       c.CustomerID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       o.OrderDate,
       o.OrderStatus,
       o.SalesChannel
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC;

-- I02 | Order items with order date, product, quantity, price and discount
-- Joins OrderItems to Orders (for the date) and Products (for the name).
SELECT oi.OrderItemID,
       o.OrderDate,
       p.ProductName,
       oi.Quantity,
       oi.UnitPrice,
       oi.DiscountPercent
FROM OrderItems AS oi
INNER JOIN Orders AS o
    ON oi.OrderID = o.OrderID
INNER JOIN Products AS p
    ON oi.ProductID = p.ProductID
ORDER BY o.OrderDate, oi.OrderItemID;

-- I03 | Line total for every order item after discount
-- Line total = quantity x unit price, reduced by the discount percentage.
SELECT oi.OrderItemID,
       oi.OrderID,
       p.ProductName,
       oi.Quantity,
       oi.UnitPrice,
       oi.DiscountPercent,
       oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0) AS LineTotal
FROM OrderItems AS oi
INNER JOIN Products AS p
    ON oi.ProductID = p.ProductID;

-- I04 | Total order value for each order
-- Adds up the discounted line totals of each order, largest orders first.
SELECT o.OrderID,
       o.CustomerID,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS TotalOrderValue
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.CustomerID
ORDER BY TotalOrderValue DESC;

-- I05 | Total revenue by customer
-- Adds up the discounted line totals for each customer who has placed orders.
SELECT c.CustomerID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS TotalRevenue
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalRevenue DESC;

-- I06 | Total revenue by product category
-- Adds up the discounted line totals for each product category.
SELECT p.Category,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS TotalRevenue
FROM Products AS p
INNER JOIN OrderItems AS oi
    ON p.ProductID = oi.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

-- I07 | Number of orders handled by each employee
-- LEFT JOIN keeps employees who have handled no orders (they show 0).
SELECT e.EmployeeID,
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       COUNT(o.OrderID) AS TotalOrders
FROM Employees AS e
LEFT JOIN Orders AS o
    ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY TotalOrders DESC;

-- I08 | Customers who have never placed an order
-- LEFT JOIN plus IS NULL finds customers with no matching order.
SELECT c.CustomerID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       c.City,
       c.Segment
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- I09 | Products that have never been ordered
-- LEFT JOIN plus IS NULL finds products with no matching order item.
-- In the sample data every product has been ordered, so this returns no rows.
SELECT p.ProductID, p.ProductName, p.Category
FROM Products AS p
LEFT JOIN OrderItems AS oi
    ON p.ProductID = oi.ProductID
WHERE oi.OrderItemID IS NULL;

-- I10 | Customers and their support tickets, including customers without tickets
-- Customers with no tickets appear once, with empty ticket columns.
SELECT c.CustomerID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       t.TicketID,
       t.Priority,
       t.TicketStatus
FROM Customers AS c
LEFT JOIN SupportTickets AS t
    ON c.CustomerID = t.CustomerID
ORDER BY c.CustomerID, t.TicketID;

-- I11 | Average satisfaction score by support employee
-- The score is cast to DECIMAL first, because AVG on whole numbers rounds down.
-- Tickets without a score are ignored by AVG; RatedTickets shows how many were scored.
SELECT e.EmployeeID,
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       COUNT(t.SatisfactionScore) AS RatedTickets,
       CAST(AVG(CAST(t.SatisfactionScore AS DECIMAL(5, 2))) AS DECIMAL(5, 2)) AS AvgSatisfactionScore
FROM SupportTickets AS t
INNER JOIN Employees AS e
    ON t.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY AvgSatisfactionScore DESC;

-- I12 | Payment amount by order, flagging orders without a payment record
-- LEFT JOIN keeps every order; the flag column marks orders with no payment.
SELECT o.OrderID,
       o.OrderDate,
       p.PaymentID,
       p.Amount,
       p.PaymentStatus,
       CASE WHEN p.PaymentID IS NULL THEN 'No payment record'
            ELSE 'Has payment record'
       END AS PaymentRecord
FROM Orders AS o
LEFT JOIN Payments AS p
    ON o.OrderID = p.OrderID
ORDER BY PaymentRecord DESC, o.OrderID;

-- I13 | Paid orders where the amount paid is lower than the calculated order value
-- Step 1 works out each order's value; step 2 adds up its payments with status Paid;
-- the final query keeps orders where the paid total is below the order value.
-- The difference can also come from taxes or shipping if Amount includes them.
-- In the sample data every paid payment equals its order value exactly,
-- so this returns no rows.
WITH OrderValue AS (
    SELECT OrderID,
           SUM(Quantity * UnitPrice * (1 - DiscountPercent / 100.0)) AS CalculatedOrderValue
    FROM OrderItems
    GROUP BY OrderID
),
PaidAmount AS (
    SELECT OrderID,
           SUM(Amount) AS TotalPaid
    FROM Payments
    WHERE PaymentStatus = 'Paid'
    GROUP BY OrderID
)
SELECT ov.OrderID,
       pa.TotalPaid,
       CAST(ov.CalculatedOrderValue AS DECIMAL(18, 2)) AS CalculatedOrderValue,
       CAST(ov.CalculatedOrderValue - pa.TotalPaid AS DECIMAL(18, 2)) AS ShortfallAmount
FROM OrderValue AS ov
INNER JOIN PaidAmount AS pa
    ON ov.OrderID = pa.OrderID
WHERE pa.TotalPaid < ROUND(ov.CalculatedOrderValue, 2)
ORDER BY ShortfallAmount DESC;

-- I14 | Monthly revenue based on order date
-- Groups by year and month so the same month in different years stays separate,
-- and sorts in calendar order.
SELECT YEAR(o.OrderDate)  AS OrderYear,
       MONTH(o.OrderDate) AS MonthNumber,
       DATENAME(MONTH, o.OrderDate) AS MonthName,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS TotalRevenue
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), DATENAME(MONTH, o.OrderDate)
ORDER BY OrderYear, MonthNumber;

-- I15 | Monthly number of orders by sales channel
-- Counts orders for each year, month and sales channel in calendar order.
SELECT YEAR(OrderDate)  AS OrderYear,
       MONTH(OrderDate) AS MonthNumber,
       DATENAME(MONTH, OrderDate) AS MonthName,
       SalesChannel,
       COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate), SalesChannel
ORDER BY OrderYear, MonthNumber, SalesChannel;

-- I16 | Employees with their department names
-- Joins Employees to Departments.
SELECT e.EmployeeID,
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       d.DepartmentName
FROM Employees AS e
INNER JOIN Departments AS d
    ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, EmployeeName;

-- I17 | Employees and their manager names
-- Self join: the Employees table is joined to itself through ManagerID.
-- LEFT JOIN keeps employees without a manager (such as the top of the company).
SELECT e.EmployeeID,
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       COALESCE(m.FirstName + ' ' + m.LastName, 'No manager') AS ManagerName
FROM Employees AS e
LEFT JOIN Employees AS m
    ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;

-- I18 | Response count by campaign and response type
-- Counts the responses of each type for every campaign.
SELECT CampaignID, ResponseType, COUNT(*) AS ResponseCount
FROM CampaignResponses
GROUP BY CampaignID, ResponseType
ORDER BY CampaignID, ResponseType;

-- I19 | Conversion count by campaign
-- Counts responses that ended in a purchase and have a linked converted order.
SELECT CampaignID, COUNT(ConvertedOrderID) AS ConversionCount
FROM CampaignResponses
WHERE ResponseType = 'Purchased'
  AND ConvertedOrderID IS NOT NULL
GROUP BY CampaignID
ORDER BY ConversionCount DESC;

-- I20 | Top 5 customers by total order value
-- TOP 5 returns the five customers with the highest discounted spending.
SELECT TOP 5
       c.CustomerID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS TotalOrderValue
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalOrderValue DESC;

-- I21 | Orders with customer name, employee name and payment status
-- LEFT JOINs keep orders that have no employee or no payment record.
-- An order with more than one payment appears once per payment.
SELECT o.OrderID,
       c.FirstName + ' ' + c.LastName AS CustomerName,
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       p.PaymentStatus
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
LEFT JOIN Employees AS e
    ON o.EmployeeID = e.EmployeeID
LEFT JOIN Payments AS p
    ON o.OrderID = p.OrderID
ORDER BY o.OrderID;

-- I22 | Returned or cancelled orders by city
-- Counts orders with status Returned or Cancelled, grouped by the customer's city.
SELECT c.City, COUNT(o.OrderID) AS ReturnedOrCancelledOrders
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus IN ('Returned', 'Cancelled')
GROUP BY c.City
ORDER BY ReturnedOrCancelledOrders DESC;


/* ============================================================================
   ADVANCED QUERIES
   ============================================================================ */

-- A01 | Rank customers by total revenue (window function)
-- The CTE totals each customer's revenue (0 for customers with no orders);
-- RANK() then numbers customers from highest to lowest, giving ties the same rank.
WITH CustomerRevenue AS (
    SELECT c.CustomerID,
           c.FirstName,
           c.LastName,
           COALESCE(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)), 0) AS TotalRevenue
    FROM Customers AS c
    LEFT JOIN Orders AS o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderItems AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
)
SELECT CustomerID,
       FirstName,
       LastName,
       TotalRevenue,
       RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM CustomerRevenue
ORDER BY RevenueRank;

-- A02 | Running monthly revenue across all orders
-- The CTE totals revenue for each calendar month (year and month together);
-- SUM() OVER adds each month to all earlier months to give a running total.
WITH MonthlySales AS (
    SELECT DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS MonthStart,
           SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS MonthlyRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
SELECT MonthStart,
       MonthlyRevenue,
       SUM(MonthlyRevenue) OVER (
           ORDER BY MonthStart
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS RunningTotalRevenue
FROM MonthlySales
ORDER BY MonthStart;

-- A03 | Month-over-month revenue difference
-- LAG() fetches the previous month's revenue so the change can be calculated.
-- The first month has no previous month, so its change is empty (NULL).
WITH MonthlySales AS (
    SELECT DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS MonthStart,
           SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)) AS MonthlyRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
SELECT MonthStart,
       MonthlyRevenue,
       LAG(MonthlyRevenue) OVER (ORDER BY MonthStart) AS PreviousMonthRevenue,
       MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY MonthStart) AS MonthOverMonthChange,
       CAST(
           (MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY MonthStart)) * 100.0
           / NULLIF(LAG(MonthlyRevenue) OVER (ORDER BY MonthStart), 0)
           AS DECIMAL(10, 2)
       ) AS PercentChange
FROM MonthlySales
ORDER BY MonthStart;

-- A04 | Segment customers into High, Medium and Low value by total spending
-- The CTE totals each customer's spending; CASE then assigns the segment.
-- The thresholds (3,000,000 and 1,000,000) come from the spread of spending in
-- the sample data (about 0.3 million to 5.7 million per customer), which gives
-- 4 High, 6 Medium and 5 Low customers. Adjust them for different data.
-- Customers with no orders have zero spending and count as Low.
WITH CustomerSpending AS (
    SELECT c.CustomerID,
           c.FirstName + ' ' + c.LastName AS CustomerName,
           COALESCE(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPercent / 100.0)), 0) AS TotalSpending
    FROM Customers AS c
    LEFT JOIN Orders AS o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN OrderItems AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
)
SELECT CustomerID,
       CustomerName,
       TotalSpending,
       CASE WHEN TotalSpending >= 3000000 THEN 'High'
            WHEN TotalSpending >= 1000000 THEN 'Medium'
            ELSE 'Low'
       END AS ValueSegment
FROM CustomerSpending
ORDER BY TotalSpending DESC;

-- A05 | Employees earning above the average salary of their department
-- AVG() OVER (PARTITION BY ...) puts each department's average salary next to
-- every employee in it; the final filter keeps only employees paid above it.
WITH DepartmentSalary AS (
    SELECT e.EmployeeID,
           e.FirstName,
           e.LastName,
           d.DepartmentName,
           e.MonthlySalary,
           AVG(CAST(e.MonthlySalary AS DECIMAL(18, 2)))
               OVER (PARTITION BY e.DepartmentID) AS DepartmentAvgSalary
    FROM Employees AS e
    INNER JOIN Departments AS d
        ON e.DepartmentID = d.DepartmentID
)
SELECT EmployeeID,
       FirstName,
       LastName,
       DepartmentName,
       MonthlySalary,
       CAST(DepartmentAvgSalary AS DECIMAL(18, 2)) AS DepartmentAvgSalary
FROM DepartmentSalary
WHERE MonthlySalary > DepartmentAvgSalary
ORDER BY DepartmentName, MonthlySalary DESC;


/* ============================================================================
   EXTRA PRACTICE
   ============================================================================ */

-- X01 | High-priority support tickets
-- Returns all support tickets whose priority is High.
SELECT *
FROM SupportTickets
WHERE Priority = 'High';

-- X02 | Number of high-priority support tickets
-- Counts the support tickets whose priority is High.
SELECT COUNT(*) AS TotalHighPriorityTickets
FROM SupportTickets
WHERE Priority = 'High';
