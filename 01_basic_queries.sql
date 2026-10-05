/* Northwind learning exercises — SQL Server / T-SQL.
   Read-only queries. Execute individually to inspect each result. */
USE Northwind;
GO

-- 1. Customers from Germany
-- List all customers based in Germany.
SELECT *
FROM dbo.Customers
WHERE Country = 'Germany';

-- 2. Products costing more than 20
-- Show products with a unit price greater than 20.
SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products
WHERE UnitPrice > 20
ORDER BY UnitPrice DESC, ProductID;

-- 3. Employee names and cities
-- Display the first name, last name and city of every employee.
SELECT FirstName, LastName, City
FROM dbo.Employees
ORDER BY LastName, FirstName;

-- 4. Out-of-stock products
-- List products with no units in stock.
SELECT ProductID, ProductName, UnitsInStock, Discontinued
FROM dbo.Products
WHERE UnitsInStock = 0;

-- 5. Orders shipped to France
-- Show orders whose shipping destination is France.
SELECT OrderID, OrderDate, ShippedDate, ShipCountry
FROM dbo.Orders
WHERE ShipCountry = 'France'
  AND ShippedDate IS NOT NULL;

-- 6. Customer cities beginning with B
-- List customers whose city starts with B.
SELECT CustomerID, CompanyName, City
FROM dbo.Customers
WHERE City LIKE 'B%'
ORDER BY City, CustomerID;

-- 7. Products in jars or bottles
-- Find products whose packaging description mentions jars or bottles.
SELECT ProductID, ProductName, QuantityPerUnit
FROM dbo.Products
WHERE QuantityPerUnit LIKE '%jars%'
   OR QuantityPerUnit LIKE '%bottles%';

-- 8. Employees born after 1960
-- Show employees born from 1 January 1961 onwards.
SELECT EmployeeID, FirstName, LastName, BirthDate
FROM dbo.Employees
WHERE BirthDate >= '19610101'
ORDER BY BirthDate;

-- 9. Products by descending price
-- List every product from highest to lowest unit price.
SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products
ORDER BY UnitPrice DESC, ProductID;

-- 10. Customers in London or Madrid
-- Display company and contact names for customers in either city.
SELECT CompanyName, ContactName
FROM dbo.Customers
WHERE City IN ('London', 'Madrid')
ORDER BY CompanyName;
