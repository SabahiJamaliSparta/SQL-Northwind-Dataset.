# Northwind SQL: Database Fundamentals and Basic Queries

**Author:** Sabahi Jamali  
**Database:** Northwind | **DBMS:** Microsoft SQL Server | 

## Project overview

This project explores relational database principles and basic SQL querying through Northwind, a sample database representing a trading business. Its tables store customers, products, orders, employees, suppliers and shipping information.

The first stage consolidates database fundamentals and answers ten practical questions using filtering, column selection, text matching and sorting. The queries were successfully executed in the local Northwind database, as confirmed by the author. Numerical findings and full result tables are not included in this initial README.

## Project files

| File | Purpose |
|---|---|
| `README.md` | Database learning notes and ten basic query solutions |
| `01_basic_queries.sql` | Basic query exercises |
| `02_joins_and_aggregation.sql` | Further practice with JOINs and grouped calculations |
| `03_eda.sql` | Further exploratory data analysis |
| `instnwnd.sql` | Northwind installation script |

**Scope:** this README covers fundamentals and basic queries. JOIN analysis and EDA findings will be documented separately. The installation script recreates database objects; it is not required to run the exercises against an existing database.

## 1. Database fundamentals

A **database** is an organised collection of data. A **Database Management System (DBMS)** is software that stores, retrieves and manages that data, including access permissions, integrity constraints and transactions.

Databases address the limitations of disconnected files by supporting consistent records, efficient retrieval, controlled access and simultaneous users.

| Flat-file database | Relational database |
|---|---|
| Usually stores records in a single file or table, such as a CSV | Stores data in related tables |
| Related facts may be repeated across records | Keys connect records across tables |
| A CSV does not itself enforce relationships or transactions | A relational DBMS can enforce constraints and manage transactions |
| Suitable for simple storage and data exchange | Suitable for connected business processes |

Examples of relational DBMSs include **SQL Server, MySQL, PostgreSQL and Oracle Database**. Their SQL dialects and features differ.

## 2. Relational database concepts

The relational model represents data as relations, commonly implemented as **tables**. Key values allow records in different tables to be associated.

| Concept | Meaning | Northwind example |
|---|---|---|
| Table | Records about a subject | `Customers` |
| Row | One record | One customer organisation |
| Column | A named field with a defined data type | `CompanyName` |
| Entity | A business object or concept | Customer, Product, Order |
| Attribute | A property of an entity | `ProductName`, `OrderDate` |

Relational databases are widely used because they support flexible queries, integrity rules and reliable transactions. Separating entities into tables reduces unnecessary duplication: a customer's details can be stored once and referenced by many orders.

### Core Northwind tables

| Table | What one row represents | Primary key |
|---|---|---|
| `Customers` | One customer organisation | `CustomerID` |
| `Orders` | One order | `OrderID` |
| `[Order Details]` | One product line within an order | `OrderID` + `ProductID` |
| `Products` | One product | `ProductID` |
| `Employees` | One employee | `EmployeeID` |
| `Categories` | One product category | `CategoryID` |
| `Suppliers` | One supplier | `SupplierID` |
| `Shippers` | One shipping company | `ShipperID` |

Understanding what one row represents—its **grain**—is essential when counting or combining records.

## 3. Keys and relationships

### Primary keys

A **primary key** uniquely identifies each row. It must be unique and cannot contain NULL values. A table has one primary-key constraint, which can contain one column or multiple columns (a **composite key**).

Stable identifiers such as `EmployeeID` are good choices. Names and cities are poor choices because they can repeat or change. In `[Order Details]`, the combination of `OrderID` and `ProductID` uniquely identifies an order line.

### Foreign keys

A **foreign key** references a primary or unique key in another table—or the same table. It maintains **referential integrity** by requiring non-NULL values to match an existing referenced key.

For example, `Orders.CustomerID` references `Customers.CustomerID`. This links orders to customer records without repeating the customer's details. Foreign-key values may repeat and can be NULL where the schema permits it.

### Relationship types

| Type | Meaning | Example |
|---|---|---|
| One-to-one | A record relates to at most one record on the other side | Hypothetical employee and employee profile, enforced with a unique foreign key |
| One-to-many | One parent record can relate to many child records | One customer can place many orders |
| Many-to-many | Multiple records on both sides can relate | Orders contain many products; products appear in many orders |

A **junction/link table** resolves a many-to-many relationship into two one-to-many relationships. Northwind uses `[Order Details]` to connect Orders and Products, with additional attributes such as Quantity, UnitPrice and Discount.

## 4. Database design

**Data modelling** identifies the entities, attributes, keys and relationships needed to represent a business process. An **Entity Relationship Diagram (ERD)** visualises this structure.

Planning a database before building it helps establish consistent definitions, appropriate relationships and integrity rules. For a trading business, candidate entities include Customer, Order and Product; business rules explain how they relate.

| Business rule | Database relationship |
|---|---|
| A customer can place several orders | Customers → Orders: one-to-many |
| An order can contain several product lines | Orders → Order Details: one-to-many |
| A product can appear in several order lines | Products → Order Details: one-to-many |
| A category can contain several products | Categories → Products: one-to-many |

These relationships form the basis of an ERD. Required and optional relationships must also be considered: some Northwind foreign-key columns allow NULL values.

## 5. Data normalisation

**Data redundancy** is unnecessary repetition of the same fact. It can create update inconsistencies, prevent a fact being inserted independently, or cause useful information to be lost when another record is deleted.

**Normalisation** organises tables according to dependencies between attributes.

| Form | Principle | Example |
|---|---|---|
| First Normal Form (1NF) | Store one value per field; avoid repeating column groups | Store products as separate order lines instead of `Product1`, `Product2` columns |
| Second Normal Form (2NF) | Meet 1NF; non-key attributes depend on the whole of each candidate key, not only part of a composite key | Store ProductName in Products rather than a table keyed by OrderID + ProductID |
| Third Normal Form (3NF) | Meet 2NF; remove transitive dependencies between non-key attributes in the usual introductory model | Store CompanyName under CustomerID rather than repeating it under OrderID |

### Poorly designed versus normalised structure

| Poor design | Normalised alternative |
|---|---|
| One order row contains a comma-separated list of products | `[Order Details]` stores one product line per row |
| Customer name and address repeat on every order line | `Customers` stores customer attributes; orders reference CustomerID |
| Product descriptions repeat across order lines | `Products` stores product attributes; lines reference ProductID |

Normalisation improves consistency and reduces duplication, but may require more JOINs and make reporting queries more complex. Deliberate denormalisation can support reporting performance when managed carefully.

Historical transaction facts are distinct from current attributes: `[Order Details].UnitPrice` records the sale price, while `Products.UnitPrice` records the current catalogue price.

## 6. Core SQL concepts

**SQL (Structured Query Language)** defines, retrieves and changes relational data. **SQL Server** is the DBMS; **T-SQL** is its SQL dialect.

| Category | Purpose | Commands |
|---|---|---|
| DDL: Data Definition Language | Define or change structures | `CREATE`, `ALTER`, `DROP` |
| DML: Data Manipulation Language | Retrieve or change records | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| DCL: Data Control Language | Manage access | `GRANT`, `REVOKE`, `DENY` |
| TCL: Transaction Control Language | Manage transactions | `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK` |

Some teaching materials classify SELECT separately as **DQL (Data Query Language)**.

## 7. Basic SQL commands

The following examples demonstrate structure and data changes in a separate practice database. They are not part of the read-only Northwind exercises. Run them in sequence only when practising these commands; database creation requires appropriate permissions.

```sql
-- CREATE DATABASE: create a separate practice database (first run only).
USE master;
GO
CREATE DATABASE SQLPractice;
GO
USE SQLPractice;
GO

-- CREATE TABLE: define columns and a primary key.
CREATE TABLE dbo.PracticeCustomers (
    CustomerID int NOT NULL PRIMARY KEY,
    CompanyName nvarchar(100) NOT NULL
);

-- ALTER TABLE: add a column.
ALTER TABLE dbo.PracticeCustomers ADD City nvarchar(50) NULL;

-- INSERT INTO: add a record.
INSERT INTO dbo.PracticeCustomers (CustomerID, CompanyName, City)
VALUES (1, N'Example Retail', N'London');

-- SELECT: retrieve records.
SELECT CustomerID, CompanyName, City FROM dbo.PracticeCustomers;

-- UPDATE: change a selected record, then undo the practice change.
BEGIN TRANSACTION;
UPDATE dbo.PracticeCustomers SET City = N'Madrid' WHERE CustomerID = 1;
ROLLBACK TRANSACTION;

-- DELETE: remove a selected record while retaining the table.
DELETE FROM dbo.PracticeCustomers WHERE CustomerID = 1;

-- DROP TABLE: remove the practice table and its structure.
DROP TABLE dbo.PracticeCustomers;
```

`COMMIT` makes transaction changes permanent; `ROLLBACK` undoes uncommitted changes. Omitting WHERE from UPDATE or DELETE affects every row.

## 8. Querying data

| Feature | Purpose / behaviour |
|---|---|
| `SELECT` | Choose the data to retrieve |
| Named columns | Keep the output focused and predictable |
| `SELECT *` | Return every column; useful for initial inspection |
| `WHERE` | Filter rows using a condition |
| `=`, `>`, `<`, `>=`, `<=`, `<>` | Compare values; `<>` means not equal |
| `AND` / `OR` | Require both conditions / at least one condition; use parentheses for combined rules |
| `LIKE` | Match text patterns; `%` means zero or more characters, `_` means one character |
| `ORDER BY` | Sort results; `ASC` is ascending, `DESC` is descending |
| `DISTINCT` | Remove duplicate combinations of selected values |
| `IS NULL` / `IS NOT NULL` | Test for missing or unknown values |

NULL is different from zero or an empty string. Use `IS NULL`, rather than `= NULL`. Comparisons involving NULL normally evaluate to unknown, and WHERE retains only true conditions. Text matching depends on the database collation. Without ORDER BY, row order is not guaranteed.

```sql
-- Return unique countries in alphabetical order.
SELECT DISTINCT Country FROM dbo.Customers ORDER BY Country;

-- Combine conditions explicitly.
SELECT ProductName, UnitPrice
FROM dbo.Products
WHERE UnitPrice >= 20 AND Discontinued = 0;

-- Identify missing regional information.
SELECT CustomerID, CompanyName FROM dbo.Customers WHERE Region IS NULL;
```

## 9. Ten basic Northwind queries

Select Northwind before executing these queries:

```sql
USE Northwind;
GO
```

`GO` is a batch separator recognised by the SQL client. The following solutions answer the ten assignment questions.

### 1. List all customers from Germany

```sql
SELECT *
FROM dbo.Customers
WHERE Country = 'Germany';
```

**Explanation:** filters customer records to those whose country is Germany.

### 2. Show all products that cost more than 20

```sql
SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products
WHERE UnitPrice > 20
ORDER BY UnitPrice DESC, ProductID;
```

**Explanation:** returns products above the threshold; a price of exactly 20 is excluded.

### 3. Display the first name, last name and city of all employees

```sql
SELECT FirstName, LastName, City
FROM dbo.Employees
ORDER BY LastName, FirstName;
```

**Explanation:** selects only the requested employee attributes.

### 4. List all products that are out of stock

```sql
SELECT ProductID, ProductName, UnitsInStock, Discontinued
FROM dbo.Products
WHERE UnitsInStock = 0;
```

**Explanation:** identifies zero-stock products. Out of stock and discontinued are separate conditions.

### 5. Show all orders shipped to France

```sql
SELECT OrderID, OrderDate, ShippedDate, ShipCountry
FROM dbo.Orders
WHERE ShipCountry = 'France'
  AND ShippedDate IS NOT NULL;
```

**Explanation:** returns orders addressed to France with a recorded shipping date. To include orders awaiting shipment, omit the ShippedDate condition.

### 6. List all customers whose city starts with B

```sql
SELECT CustomerID, CompanyName, City
FROM dbo.Customers
WHERE City LIKE 'B%'
ORDER BY City, CustomerID;
```

**Explanation:** the wildcard allows any characters after the initial B.

### 7. Display all products stored in jars or bottles

```sql
SELECT ProductID, ProductName, QuantityPerUnit
FROM dbo.Products
WHERE QuantityPerUnit LIKE '%jars%'
   OR QuantityPerUnit LIKE '%bottles%';
```

**Explanation:** searches the packaging description for either term.

### 8. Show all employees born after 1960

```sql
SELECT EmployeeID, FirstName, LastName, BirthDate
FROM dbo.Employees
WHERE BirthDate >= '19610101'
ORDER BY BirthDate;
```

**Explanation:** includes employees born from 1 January 1961 onwards, excluding the whole of 1960.

### 9. List all products by UnitPrice from highest to lowest

```sql
SELECT ProductID, ProductName, UnitPrice
FROM dbo.Products
ORDER BY UnitPrice DESC, ProductID;
```

**Explanation:** sorts prices in descending order; ProductID provides consistent ordering for ties.

### 10. Show company and contact names for customers in London or Madrid

```sql
SELECT CompanyName, ContactName
FROM dbo.Customers
WHERE City IN ('London', 'Madrid')
ORDER BY CompanyName;
```

**Explanation:** IN matches either city, equivalent to two equality conditions joined with OR.

## 10. Learning outcomes

This stage applied relational database concepts to a practical schema, identified primary and foreign keys, and used SQL to retrieve, filter and sort records. The exercises established a foundation for subsequent JOIN practice, aggregation and exploratory analysis.

## References

- [Microsoft: Northwind sample database installation script](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd.sql)
- [Microsoft Learn: SELECT](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql)
- [Microsoft Learn: NULL and UNKNOWN](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/null-and-unknown-transact-sql)
