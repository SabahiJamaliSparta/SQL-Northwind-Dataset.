# Northwind SQL: JOINs and Aggregation

**Author:** Sabahi Jamali  
**Database:** Northwind | **DBMS:** Microsoft SQL Server |

## Project overview

This second task builds on basic querying by combining related Northwind tables and summarising order activity. Fifteen exercises explore customer orders, product sales, employee workload, shipping companies and customer spending.

This document provides SQL solutions and their interpretation. It does not report unverified numerical findings; result counts, rankings and monetary totals should be confirmed against the local database.

## 1. What is a JOIN?

A **JOIN** combines rows from two tables using a matching condition, usually between a primary key and a foreign key. It allows related information stored separately to be retrieved together.

For example, Customers holds company names while Orders holds order dates. Matching CustomerID brings these attributes into the same result. A JOIN reads related data; it does not merge or modify the source tables.

### JOIN types and their uses

| Type | Behaviour | Typical use |
|---|---|---|
| INNER JOIN | Returns matching combinations from both tables | Orders with known customer records |
| LEFT JOIN | Keeps every left-side row; supplies NULLs for unmatched right-side fields | All customers, including those without orders |
| RIGHT JOIN | Keeps every right-side row; supplies NULLs for unmatched left-side fields | The same preservation pattern with tables reversed |
| FULL OUTER JOIN | Keeps matches and unmatched rows from both tables | Comparing datasets to identify gaps on either side |
| CROSS JOIN | Returns every possible pair of rows | Generating combinations |
| Self-join | Joins a table to itself using different aliases | Employees and their managers |

A self-join is a usage pattern, rather than a separate SQL JOIN keyword. These exercises primarily use INNER JOIN and LEFT JOIN because they answer the specified questions directly.

### Key Northwind relationships

| Relationship | Matching columns |
|---|---|
| Customers → Orders | Customers.CustomerID = Orders.CustomerID |
| Orders → Order Details | Orders.OrderID = Order Details.OrderID |
| Products → Order Details | Products.ProductID = Order Details.ProductID |
| Employees → Orders | Employees.EmployeeID = Orders.EmployeeID |
| Categories → Products | Categories.CategoryID = Products.CategoryID |
| Shippers → Orders | Shippers.ShipperID = Orders.ShipVia |

`[Order Details]` is the junction table between Orders and Products. Its composite primary key is OrderID + ProductID. Brackets are required around its name because it contains a space.

### Basic JOIN structure

```sql
SELECT c.CompanyName, o.OrderID
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON o.CustomerID = c.CustomerID;
```

`AS` introduces an alias; `ON` defines the matching condition. Prefixing columns with aliases makes their source clear and avoids ambiguity.

## 2. Aggregation and calculation rules

| Feature | Purpose |
|---|---|
| SUM | Add values, such as quantities or line amounts |
| COUNT(column) | Count non-NULL values |
| AVG | Calculate the mean of non-NULL values |
| GROUP BY | Create one result per group |
| COALESCE | Supply a fallback for NULL |
| TOP (5) | Return five rows when combined with the intended ordering |
| CTE: WITH … AS | Define a named query result for the following statement |

**Grain** means what one row represents. Orders has one row per order; joining it to Order Details produces one row per order line. Count orders before this expansion, use COUNT(DISTINCT OrderID), or aggregate back to order level.

### Order value and customer spend

The calculations use:

**Line value = UnitPrice × Quantity × (1 − Discount)**

- UnitPrice comes from **Order Details**, preserving the historical selling price.
- Discount is a fraction: 0.10 represents 10%.
- Spend and revenue mean discounted merchandise order value, excluding freight and tax. They do not establish payments received or recognised accounting revenue.
- Discount is stored as REAL in the supplied schema; DECIMAL conversion avoids floating-point arithmetic in the calculations. Totals are displayed to two decimal places after aggregation.
- No currency symbol is assumed.

For example, a line priced at 20 with quantity 3 and a 10% discount has a value of **54.00**. This is an illustrative calculation, not a Northwind finding.

## 3. Fifteen JOIN and aggregation exercises

Use the existing Northwind connection and select the database:

```sql
USE Northwind;
GO
```

Run each complete query separately. For CTEs, include the WITH clause and its following SELECT. The examples below are read-only.

### 1. Customers and their order IDs

**Task:** Show every customer and any orders they have placed.

```sql
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
ORDER BY c.CustomerID, o.OrderID;
```

**Explanation:** LEFT JOIN retains every customer. Customers with several orders appear several times; customers without orders have a NULL OrderID.

### 2. Orders with customer names

**Task:** Show OrderID, OrderDate and CompanyName.

```sql
SELECT o.OrderID, o.OrderDate, c.CompanyName
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
ORDER BY o.OrderID;
```

**Explanation:** INNER JOIN returns orders with matching customer records. The output contains one row per matched order.

### 3. Orders with product names

**Task:** Show OrderID, ProductName and Quantity.

```sql
SELECT od.OrderID, p.ProductName, od.Quantity
FROM dbo.[Order Details] AS od
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
ORDER BY od.OrderID, p.ProductID;
```

**Explanation:** Order Details connects products to orders. Each output row represents a product line within an order.

### 4. Order totals

**Task:** Calculate the discounted merchandise value of each order.

```sql
SELECT o.OrderID,
       CAST(COALESCE(SUM(
           CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))
       ), 0) AS decimal(19,2)) AS OrderTotal
FROM dbo.Orders AS o
LEFT JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
GROUP BY o.OrderID
ORDER BY o.OrderID;
```

**Explanation:** GROUP BY combines the lines into one total per order. Starting from Orders also retains orders without lines, assigning a total of zero.

### 5. Total spend per customer

**Task:** Show every customer and their total discounted merchandise spend.

```sql
SELECT c.CustomerID, c.CompanyName,
       COALESCE(CAST(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))) AS decimal(19,2)), 0) AS TotalSpend
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
LEFT JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC, c.CustomerID;
```

**Explanation:** Two LEFT JOINs retain every customer, including those without orders. COALESCE displays a missing total as zero.

### 6. Customers with no orders

**Task:** Find customers who have never placed an order.

```sql
SELECT c.CustomerID, c.CompanyName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.CustomerID;
```

**Explanation:** The LEFT JOIN preserves customers; testing the right-side primary key for NULL identifies those without a matching order.

### 7. Products never ordered

**Task:** Find products that have never appeared on an order.

```sql
SELECT p.ProductID, p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
WHERE od.OrderID IS NULL
ORDER BY p.ProductID;
```

**Explanation:** An unmatched order-line key identifies products with no order history. An empty result is valid if every product has been ordered.

### 8. Orders per employee

**Task:** Count the orders handled by each employee, including zero.

```sql
SELECT e.EmployeeID, e.FirstName, e.LastName,
       COUNT(o.OrderID) AS NumberOfOrders
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY NumberOfOrders DESC, e.EmployeeID;
```

**Explanation:** COUNT(o.OrderID) counts actual orders and ignores unmatched NULL values. COUNT(*) would incorrectly return one for an employee without orders.

### 9. Top five customers by spend

**Task:** Return five customers with the highest total spend.

```sql
SELECT TOP 5 c.CompanyName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpend
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC, c.CustomerID;
```

**Explanation:** TOP (5) selects five customers after sorting by spend. CustomerID breaks ties consistently; tied customers beyond the fifth row are excluded.

### 10. Revenue by category

**Task:** Calculate discounted merchandise revenue for every category.

```sql
SELECT cat.CategoryID, cat.CategoryName,
       COALESCE(CAST(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))) AS decimal(19,2)), 0) AS CategoryRevenue
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p ON p.CategoryID = cat.CategoryID
LEFT JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY CategoryRevenue DESC, cat.CategoryID;
```

**Explanation:** Products connect categories to order lines. LEFT JOIN retains categories without sales. Products with a NULL CategoryID are not included in these category totals.

### 11. Full order breakdown

**Task:** Show OrderID, customer name, product name, quantity and historical unit price.

```sql
SELECT o.OrderID, c.CompanyName AS CustomerName,
       p.ProductName, od.Quantity, od.UnitPrice
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
INNER JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
ORDER BY o.OrderID, p.ProductID;
```

**Explanation:** The four tables create one row per order line. CompanyName is the customer organisation; od.UnitPrice is the historical selling price.

### 12. Average order value per customer

**Task:** Show each customer, number of orders, total spend and average order value.

```sql
WITH OrderTotals AS (
    SELECT o.OrderID, o.CustomerID,
           COALESCE(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))), 0) AS OrderTotal
    FROM dbo.Orders AS o
    LEFT JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
    GROUP BY o.OrderID, o.CustomerID
)
SELECT c.CustomerID, c.CompanyName,
       COUNT(ot.OrderID) AS NumberOfOrders,
       CAST(COALESCE(SUM(ot.OrderTotal), 0) AS decimal(19,2)) AS TotalSpend,
       CAST(AVG(ot.OrderTotal) AS decimal(19,2)) AS AverageOrderValue
FROM dbo.Customers AS c
LEFT JOIN OrderTotals AS ot ON ot.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC, c.CustomerID;
```

**Explanation:** The CTE first creates one row per order. This prevents multiple order lines from inflating the order count or producing an average line value. Customers without orders have a zero count and spend, and a NULL average; orders without lines count as zero-value orders.

### 13. Employees with no orders

**Task:** Find employees who have not handled any orders.

```sql
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
WHERE o.OrderID IS NULL
ORDER BY e.EmployeeID;
```

**Explanation:** This repeats the no-match pattern used for customers. No rows means every employee has handled at least one order in the queried data.

### 14. Most popular product by quantity

**Task:** Return the product or products with the highest total units ordered.

```sql
WITH ProductQuantities AS (
    SELECT p.ProductID, p.ProductName, SUM(od.Quantity) AS TotalQuantity
    FROM dbo.Products AS p
    INNER JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
    GROUP BY p.ProductID, p.ProductName
)
SELECT ProductID, ProductName, TotalQuantity
FROM ProductQuantities
WHERE TotalQuantity = (SELECT MAX(TotalQuantity) FROM ProductQuantities)
ORDER BY ProductID;
```

**Explanation:** SUM(Quantity) measures total units ordered, rather than order frequency or revenue. The outer query returns every product tied for the highest quantity.

### 15. Orders with shipping companies

**Task:** Show every order and its associated shipper name.

```sql
SELECT o.OrderID, s.CompanyName AS ShippingCompany
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s ON s.ShipperID = o.ShipVia
ORDER BY o.OrderID;
```

**Explanation:** Orders.ShipVia references Shippers.ShipperID. LEFT JOIN retains orders without a recorded shipper, displaying NULL for the shipping company.

## 4. Common mistakes and validation

- **Incorrect matching conditions:** join the intended keys; names are not reliable identifiers.
- **Overcounting orders:** joining to order lines expands rows. Check the grain before using COUNT or AVG.
- **Losing unmatched records:** a WHERE condition on the right-side table can remove the NULL rows retained by a LEFT JOIN. Place match restrictions in ON when all left-side records must remain.
- **Incorrect no-match checks:** use a right-side key that cannot be NULL in a genuine match, such as OrderID.
- **Repeated freight:** Freight belongs to an order. Adding it once per order line inflates the total.

```sql
-- Keep every customer, but match only their orders from 1997.
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON o.CustomerID = c.CustomerID
   AND o.OrderDate >= '19970101'
   AND o.OrderDate < '19980101';
```

Validate that overall order-level totals reconcile with order-line totals before final rounding. Customer or category totals may differ from the overall total where relevant foreign keys are NULL. An empty result from a no-orders query is a valid finding, not necessarily an error.

## 5. Learning outcomes

This task develops the ability to select an appropriate JOIN, interpret unmatched records, combine multiple tables and summarise data at the correct level. The advanced exercises demonstrate customer ranking, product popularity and average order value without confusing orders with order lines.

## References

- [Microsoft Learn: JOINs in SQL Server](https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins)
- [Microsoft Learn: GROUP BY](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql)
- [Microsoft Learn: Common Table Expressions](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql)
- [Microsoft: Northwind installation script](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd.sql)
