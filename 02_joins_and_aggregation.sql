/* Northwind learning exercises — SQL Server / T-SQL.
 */
USE Northwind;
GO

-- 1. Customers and their order IDs
-- Show every customer and any orders they have placed.
SELECT c.CustomerID, c.CompanyName, o.OrderID
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- 2. Orders with customer names
-- Show OrderID, OrderDate and CompanyName.
SELECT o.OrderID, o.OrderDate, c.CompanyName
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
ORDER BY o.OrderID;

-- 3. Orders with product names
-- Show OrderID, ProductName and Quantity.
SELECT od.OrderID, p.ProductName, od.Quantity
FROM dbo.[Order Details] AS od
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
ORDER BY od.OrderID, p.ProductID;

-- 4. Order totals
-- Calculate the discounted merchandise value of each order.
SELECT od.OrderID,
       CAST(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))) AS decimal(19,2)) AS OrderTotal
FROM dbo.[Order Details] AS od
GROUP BY od.OrderID
ORDER BY od.OrderID;

-- 5. Total spend per customer
-- Show every customer and their total discounted merchandise spend.
SELECT TOP 5 c.CustomerID, c.CompanyName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpend
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC, c.CustomerID;

-- 6. Customers with no orders
-- Find customers who have never placed an order.
SELECT c.CustomerID, c.CompanyName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.CustomerID;

-- 7. Products never ordered
-- Find products that have never appeared on an order.
SELECT p.ProductID, p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
WHERE od.OrderID IS NULL
ORDER BY p.ProductID;

-- 8. Orders per employee
-- Count the orders handled by each employee, including zero.
SELECT e.EmployeeID, e.FirstName, e.LastName,
       COUNT(o.OrderID) AS NumberOfOrders
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY NumberOfOrders DESC, e.EmployeeID;

-- 9. Top five customers by spend
-- Return five customers with the highest total spend.
SELECT TOP (5) c.CustomerID, c.CompanyName,
       CAST(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))) AS decimal(19,2)) AS TotalSpend
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
INNER JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC, c.CustomerID;

-- 10. Revenue by category
-- Calculate discounted merchandise revenue for every category.
SELECT cat.CategoryID, cat.CategoryName,
       COALESCE(CAST(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))) AS decimal(19,2)), 0) AS CategoryRevenue
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p ON p.CategoryID = cat.CategoryID
LEFT JOIN dbo.[Order Details] AS od ON od.ProductID = p.ProductID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY CategoryRevenue DESC, cat.CategoryID;

-- 11. Full order breakdown
-- Show OrderID, customer name, product name, quantity and historical unit price.
SELECT o.OrderID, c.CompanyName AS CustomerName,
       p.ProductName, od.Quantity, od.UnitPrice
FROM dbo.Orders AS o
INNER JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
INNER JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
INNER JOIN dbo.Products AS p ON p.ProductID = od.ProductID
ORDER BY o.OrderID, p.ProductID;

-- 12. Average order value per customer
-- Show each customer, number of orders, total spend and average order value.
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

-- 13. Employees with no orders
-- Find employees who have not handled any orders.
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
WHERE o.OrderID IS NULL
ORDER BY e.EmployeeID;

-- 14. Most popular product by quantity
-- Return the product or products with the highest total units ordered.
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

-- 15. Orders with shipping companies
-- Show every order and its associated shipper name.
SELECT o.OrderID, s.CompanyName AS ShippingCompany
FROM dbo.Orders AS o
LEFT JOIN dbo.Shippers AS s ON s.ShipperID = o.ShipVia
ORDER BY o.OrderID;
