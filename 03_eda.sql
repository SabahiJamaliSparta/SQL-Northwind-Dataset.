/* Northwind learning exercises — SQL Server / T-SQL.
*/
USE Northwind;
GO

-- 1. Table sizes
-- Establish the size and grain of the main tables.
SELECT 'Customers' AS TableName, COUNT(*) AS [RowCount] FROM dbo.Customers
UNION ALL SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'Order Details', COUNT(*) FROM dbo.[Order Details]
UNION ALL SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Employees', COUNT(*) FROM dbo.Employees;

-- 2. Order date coverage and missingness
-- Check the historical period and missing order fields.
SELECT MIN(OrderDate) AS FirstOrderDate, MAX(OrderDate) AS LastOrderDate,
       SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END) AS MissingOrderDates,
       SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS MissingCustomerIDs,
       SUM(CASE WHEN ShippedDate IS NULL THEN 1 ELSE 0 END) AS UnshippedOrUnknown
FROM dbo.Orders;

-- 3. Customer distribution
-- Count customers by country.
SELECT Country, COUNT(*) AS CustomerCount
FROM dbo.Customers
GROUP BY Country
ORDER BY CustomerCount DESC, Country;

-- 4. Product price profile
-- Summarise current product prices.
SELECT MIN(UnitPrice) AS MinimumPrice,
       MAX(UnitPrice) AS MaximumPrice,
       CAST(AVG(CAST(UnitPrice AS decimal(19,4))) AS decimal(19,2)) AS AveragePrice,
       SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS MissingPrices
FROM dbo.Products;

-- 5. Monthly orders and revenue
-- Compare order volume and discounted merchandise revenue over time.
WITH OrderTotals AS (
    SELECT o.OrderID, o.OrderDate,
           COALESCE(SUM(CAST(od.UnitPrice AS decimal(19,4)) * od.Quantity
           * (1 - CAST(od.Discount AS decimal(9,6)))), 0) AS OrderTotal
    FROM dbo.Orders AS o
    LEFT JOIN dbo.[Order Details] AS od ON od.OrderID = o.OrderID
    GROUP BY o.OrderID, o.OrderDate
)
SELECT DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS OrderMonth,
       COUNT(*) AS NumberOfOrders,
       CAST(SUM(OrderTotal) AS decimal(19,2)) AS MerchandiseRevenue
FROM OrderTotals
WHERE OrderDate IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
ORDER BY OrderMonth;

-- 6. Order-line key check
-- Check for duplicate OrderID–ProductID pairs.
SELECT OrderID, ProductID, COUNT(*) AS DuplicateCount
FROM dbo.[Order Details]
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;

-- 7. Order-line relationship check
-- Look for missing parent orders or products.
SELECT od.OrderID, od.ProductID
FROM dbo.[Order Details] AS od
LEFT JOIN dbo.Orders AS o ON o.OrderID = od.OrderID
LEFT JOIN dbo.Products AS p ON p.ProductID = od.ProductID
WHERE o.OrderID IS NULL OR p.ProductID IS NULL;
