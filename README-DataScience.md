# DataScience: SQL Database Creation and Modification

**Author:** Sabahi Jamali  
**Platform:** Microsoft SQL Server 2022 | Transact-SQL (T-SQL)

## Overview

This practical exercise creates a small training database, populates it with fictional records and modifies its tables while retaining existing rows. It demonstrates primary and foreign keys, character and date types, data validation and verification using `SELECT` statements.

The final database contains **four courses and 13 Spartans**. The ERD and extended database design are documented separately.

> The code below records the exercise in execution order. Creation, insertion and modification statements are intended to run once on a new database; do not rerun the complete sequence against the database already created. The invalid-title test intentionally produces an error.

## 1. Create the Database and Tables

```sql
CREATE DATABASE DataScience;
GO

USE DataScience;
GO

CREATE TABLE Course (
    CourseID VARCHAR(20) PRIMARY KEY,
    CourseName VARCHAR(50) NOT NULL,
    Trainer VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL
);

CREATE TABLE Spartans (
    SpartanID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) NULL,
    LastName VARCHAR(50) NULL,
    Phone VARCHAR(24) NULL,
    CourseID VARCHAR(20) NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

SELECT * FROM Course;
SELECT * FROM Spartans;
```

**Purpose:** `CourseID` identifies each course, while `SpartanID` automatically generates a unique identifier for each Spartan. The foreign key requires each Spartan to reference an existing course. One course can have many Spartans; each Spartan references one course in this initial design.

**Result:** Both tables were created successfully and were initially empty.

| SQL feature | Application |
| --- | --- |
| `VARCHAR(n)` | Stores variable-length text, including names and course codes. Phone numbers were initially text to preserve leading zeros. |
| `INT IDENTITY(1,1)` | Generates integer IDs starting at 1 and increasing by 1. Gaps can occur after failed inserts. |
| `DATE` | Stores calendar dates without a time component. Date literals use `YYYY-MM-DD`. |
| `NOT NULL` / `NULL` | Defines whether a value is required or may be missing. |
| `GO` | Separates batches in the SQL execution tool; it is not a T-SQL statement. |

## 2. Populate the Tables

Courses are inserted first so the Spartans' foreign key references are valid. All names, contact details and course arrangements are fictional examples.

```sql
INSERT INTO Course (CourseID, CourseName, Trainer, StartDate)
VALUES
    ('TECH 200', 'Data Engineering', 'Alex Morgan', '2026-09-21'),
    ('TECH 201', 'Data Analytics', 'Priya Shah', '2026-10-05'),
    ('TECH 202', 'Data Science', 'Jordan Taylor', '2026-10-12'),
    ('TECH 203', 'AI Engineering', 'Samira Khan', '2026-10-19');

INSERT INTO Spartans (
    FirstName, MiddleName, LastName, Phone, CourseID
)
VALUES
    ('Amira', NULL, 'Hassan', '07700 900001', 'TECH 200'),
    ('James', 'Oliver', 'Wilson', '07700 900002', 'TECH 200'),
    ('Sofia', NULL, 'Patel', '07700 900003', 'TECH 201'),
    ('Daniel', 'Lee', 'Brown', '07700 900004', 'TECH 201'),
    ('Oliver', 'James', 'Clarke', '07700 900005', 'TECH 200'),
    ('Zara', NULL, 'Ahmed', '07700 900006', 'TECH 200'),
    ('Emily', 'Rose', 'Thompson', '07700 900007', 'TECH 201'),
    ('Noah', NULL, 'Williams', '07700 900008', 'TECH 201'),
    ('Aisha', 'Noor', 'Ali', '07700 900009', 'TECH 202'),
    ('Ethan', NULL, 'Roberts', '07700 900010', 'TECH 202'),
    ('Grace', 'Elizabeth', 'Evans', '07700 900011', 'TECH 203'),
    ('Leo', NULL, 'Chen', '07700 900012', 'TECH 203');

SELECT * FROM Course ORDER BY CourseID;
SELECT * FROM Spartans ORDER BY SpartanID;
```

**Result:** Four courses and 12 Spartans were confirmed. `NULL` represents an unspecified middle name. An earlier insert failed because its course reference did not exist; correcting the references resolved the foreign key error (Msg 547).

## 3. Modify the Existing Tables

### 3.1 Add and Populate Title

```sql
ALTER TABLE Spartans
ADD Title VARCHAR(10) NULL;
GO

SELECT SpartanID, FirstName, LastName, Title
FROM Spartans
ORDER BY SpartanID;

UPDATE Spartans
SET Title = 'Mx';

SELECT SpartanID, FirstName, LastName, Title
FROM Spartans
ORDER BY SpartanID;
```

**Purpose:** Adds a text column, then assigns a neutral sample title to every existing row. The `UPDATE` affects all rows because it has no `WHERE` clause.

**Result:** Title was initially `NULL`; all 12 existing Spartans then showed `Mx`.

### 3.2 Restrict Accepted Titles

```sql
ALTER TABLE Spartans
ADD CONSTRAINT CK_Spartans_Title
CHECK (Title IN ('Mr', 'Ms', 'Mx', 'Dr'));

SELECT SpartanID, FirstName, LastName, Title
FROM Spartans
ORDER BY SpartanID;
```

Run this separate test at this stage, before adding Email and removing Phone:

```sql
-- Intentional failure: Captain is not an accepted title
INSERT INTO Spartans (FirstName, LastName, CourseID, Title)
VALUES ('Test', 'Spartan', 'TECH 200', 'Captain');

SELECT COUNT(*) AS TotalSpartans
FROM Spartans;
```

**Result:** The invalid-title test was rejected with **Msg 547**, identifying `CK_Spartans_Title` and the `Title` column. The row was not inserted, and the count remained **12**.

**Key point:** `CHECK` restricts supplied titles, but Title remains nullable. Requiring a title for future rows would also require `NOT NULL`.

### 3.3 Add Unique Email Addresses

```sql
ALTER TABLE Spartans
ADD Email VARCHAR(100) NULL;
GO

SELECT SpartanID, FirstName, LastName, Email
FROM Spartans
ORDER BY SpartanID;

UPDATE Spartans
SET Email = LOWER(FirstName + '.' + LastName + '@example.com');

ALTER TABLE Spartans
ADD CONSTRAINT UQ_Spartans_Email UNIQUE (Email);

SELECT SpartanID, FirstName, LastName, Email
FROM Spartans
ORDER BY SpartanID;
```

**Purpose:** Generates lowercase fictional email addresses and prevents duplicate email values.

**Result:** All 12 existing Spartans received distinct addresses. A separate duplicate-insert test was not recorded. Email remains nullable; this SQL Server single-column `UNIQUE` constraint permits at most one `NULL`.

### 3.4 Add EndDate and Validate Date Order

```sql
ALTER TABLE Course
ADD EndDate DATE NULL;
GO

SELECT CourseID, CourseName, StartDate, EndDate
FROM Course
ORDER BY CourseID;

ALTER TABLE Course
ADD CONSTRAINT CK_Course_EndDate
CHECK (EndDate >= StartDate);

SELECT CourseID, CourseName, StartDate, EndDate
FROM Course
ORDER BY CourseID;
```

**Purpose:** Allows a course end date while preventing a supplied end date from preceding its start date. Equal dates are allowed.

**Result:** The change completed successfully. No end dates were populated, so existing values remained `NULL`. An invalid-date insert test was not recorded.

### 3.5 Increase CourseName Length

```sql
ALTER TABLE Course
ALTER COLUMN CourseName VARCHAR(100) NOT NULL;

SELECT CourseID, CourseName
FROM Course
ORDER BY CourseID;

SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Course'
  AND COLUMN_NAME = 'CourseName';
```

**Purpose:** Expands CourseName from `VARCHAR(50)` to `VARCHAR(100)` while keeping it mandatory.

**Result:** All four course names were preserved; the metadata check returned a maximum length of **100**.

### 3.6 Add Status with a Default

```sql
ALTER TABLE Spartans
ADD Status VARCHAR(20) NOT NULL
    CONSTRAINT DF_Spartans_Status DEFAULT 'Active';
GO

SELECT SpartanID, FirstName, LastName, Status
FROM Spartans
ORDER BY SpartanID;

-- Status is deliberately omitted to test its default
INSERT INTO Spartans (
    FirstName, LastName, Phone, CourseID, Title, Email
)
VALUES (
    'Maya', 'Lewis', '07700 900013',
    'TECH 202', 'Mx', 'maya.lewis@example.com'
);

SELECT SpartanID, FirstName, LastName, Status
FROM Spartans
WHERE Email = 'maya.lewis@example.com';
```

**Result:** All 12 existing Spartans received `Active`. Maya Lewis also received `Active` without supplying Status, bringing the total to **13**.

**Key point:** A default supplies a value when the column is omitted; it does not restrict Status to a list such as Active, Graduated and Withdrawn.

### 3.7 Make LastName Mandatory

First check existing rows:

```sql
SELECT SpartanID, FirstName, LastName
FROM Spartans
WHERE LastName IS NULL;
```

**Result:** No rows were returned, so no corrective update was necessary. If missing values had been found, they would need to be updated with the correct surnames before applying the change.

```sql
ALTER TABLE Spartans
ALTER COLUMN LastName VARCHAR(50) NOT NULL;

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Spartans'
  AND COLUMN_NAME = 'LastName';
```

**Result:** The metadata check returned `LastName | varchar | NO`, confirming that `NULL` is no longer accepted. `NOT NULL` alone does not prevent empty strings.

### 3.8 Rename and Remove Columns

```sql
EXEC sp_rename 'Course.Trainer', 'TrainerName', 'COLUMN';
GO

SELECT CourseID, CourseName, TrainerName
FROM Course
ORDER BY CourseID;
```

**Purpose:** Renames Trainer to TrainerName for consistency with CourseName. SQL Server uses `sp_rename` for this operation. Queries referring to the old name must be updated.

**Result:** All four trainer names were preserved under the new column name.

```sql
ALTER TABLE Spartans
DROP COLUMN Phone;

SELECT *
FROM Spartans
ORDER BY SpartanID;
```

**Purpose:** Removes phone numbers from the scope of this exercise.

**Result:** Phone was removed, including its stored values. All **13 Spartan rows** and their remaining fields were retained.

## 4. Final Results

The confirmed state after the exercise is summarised below. Results were checked through the learner's SQL Server outputs; the documentation review did not independently execute the database.

| Check | Confirmed result |
| --- | --- |
| Course records | 4 |
| Spartan records | 13, including Maya Lewis |
| Title | All current rows show Mx; Captain was rejected |
| Email | All current rows have distinct fictional addresses |
| CourseName | Maximum length increased to 100 |
| EndDate | Added; remains NULL until dates are supplied |
| Status | All current rows show Active; default tested with Maya |
| LastName | No existing NULL values; column changed to NOT NULL |
| TrainerName | Renamed successfully; four trainer values retained |
| Phone | Removed; Spartan rows retained |

Final columns:

- **Course:** CourseID, CourseName, TrainerName, StartDate, EndDate.
- **Spartans:** SpartanID, FirstName, MiddleName, LastName, CourseID, Title, Email, Status.

Identity values need not be consecutive. The observed Spartan IDs were 2–13 and 15; earlier failed inserts explain the gaps. Use row counts rather than the highest ID to count records.

## 5. Extension: Why ALTER TABLE Is Safer

`ALTER TABLE` makes targeted structural changes while retaining the existing table and unaffected data. Dropping and recreating a production table can delete records and disrupt relationships, permissions and dependent applications. Alterations still require testing: dropping a column deletes its data, and structural changes can temporarily block access. Renaming also requires updating references to the old name.

## Key Takeaways

- Create parent records before inserting rows that reference them through foreign keys.
- Check existing data before adding stricter rules such as `NOT NULL`.
- Use named constraints to make validation errors easier to interpret.
- Verify changes with both data queries and column metadata where relevant.
- Distinguish defaults, uniqueness and required values: each enforces a different rule.

## References

- [Microsoft Learn: ALTER TABLE (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-table-transact-sql?view=sql-server-ver16)
- [Microsoft Learn: sp_rename (Transact-SQL)](https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-rename-transact-sql?view=sql-server-ver16)
