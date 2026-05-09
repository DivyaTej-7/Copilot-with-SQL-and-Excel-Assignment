-- SQL Server (SSMS) script: create SalesData table, insert 10,000 realistic random rows, and include queries
-- Run this whole file in SSMS. This is T-SQL and tested conceptually for SQL Server 2016+.

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

IF OBJECT_ID('dbo.SalesData', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesData (
      CustomerID INT IDENTITY(1,1) PRIMARY KEY,
      Name VARCHAR(100),
      Age INT,
      City VARCHAR(100),
      PurchaseAmount DECIMAL(10,2),
      PurchaseDate DATE
    );
END

-- Helper lists
IF OBJECT_ID('tempdb..#FirstNames') IS NOT NULL DROP TABLE #FirstNames;
CREATE TABLE #FirstNames (FirstName VARCHAR(50));
INSERT INTO #FirstNames (FirstName) VALUES
('James'),('Mary'),('John'),('Patricia'),('Robert'),('Jennifer'),('Michael'),('Linda'),('William'),('Elizabeth'),
('David'),('Barbara'),('Richard'),('Susan'),('Joseph'),('Jessica'),('Thomas'),('Sarah'),('Charles'),('Karen'),
('Christopher'),('Nancy'),('Daniel'),('Lisa'),('Matthew'),('Margaret'),('Anthony'),('Betty'),('Mark'),('Sandra'),
('Donald'),('Ashley'),('Steven'),('Dorothy'),('Paul'),('Kimberly'),('Andrew'),('Emily'),('Joshua'),('Donna'),
('Kenneth'),('Michelle'),('Kevin'),('Carol'),('Brian'),('Amanda'),('George'),('Melissa'),('Edward'),('Deborah');

IF OBJECT_ID('tempdb..#LastNames') IS NOT NULL DROP TABLE #LastNames;
CREATE TABLE #LastNames (LastName VARCHAR(50));
INSERT INTO #LastNames (LastName) VALUES
('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),('Rodriguez'),('Martinez'),
('Hernandez'),('Lopez'),('Gonzalez'),('Wilson'),('Anderson'),('Thomas'),('Taylor'),('Moore'),('Jackson'),('Martin'),
('Lee'),('Perez'),('Thompson'),('White'),('Harris'),('Sanchez'),('Clark'),('Ramirez'),('Lewis'),('Robinson'),
('Walker'),('Young'),('Allen'),('King'),('Wright'),('Scott'),('Torres'),('Nguyen'),('Hill'),('Flores'),
('Green'),('Adams'),('Nelson'),('Baker'),('Hall'),('Rivera'),('Campbell'),('Mitchell'),('Carter'),('Roberts');

IF OBJECT_ID('tempdb..#Cities') IS NOT NULL DROP TABLE #Cities;
CREATE TABLE #Cities (City VARCHAR(100));
INSERT INTO #Cities (City) VALUES
('New York'),('Los Angeles'),('Chicago'),('Houston'),('Phoenix'),('Philadelphia'),('San Antonio'),('San Diego'),
('Dallas'),('San Jose'),('Austin'),('Jacksonville'),('Fort Worth'),('Columbus'),('Charlotte'),('San Francisco'),
('Indianapolis'),('Seattle'),('Denver'),('Washington');

-- Generate 10,000 rows using a numbers CTE
IF OBJECT_ID('tempdb..#InsertedRows') IS NOT NULL DROP TABLE #InsertedRows;

WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numbers WHERE n < 10000
)
INSERT INTO dbo.SalesData (Name, Age, City, PurchaseAmount, PurchaseDate)
SELECT
    -- Random first + last name via TOP 1 ... ORDER BY NEWID()
    (SELECT TOP (1) FirstName FROM #FirstNames ORDER BY NEWID()) + ' ' + (SELECT TOP (1) LastName FROM #LastNames ORDER BY NEWID()) AS Name,
    -- Age 18..80
    (ABS(CHECKSUM(NEWID())) % 63) + 18 AS Age,
    -- Random city
    (SELECT TOP (1) City FROM #Cities ORDER BY NEWID()) AS City,
    -- PurchaseAmount between 10.00 and 1000.00 with two decimals
    CONVERT(DECIMAL(10,2), ((ABS(CHECKSUM(NEWID())) % 991) + 10) + (ABS(CHECKSUM(NEWID())) % 100) / 100.0) AS PurchaseAmount,
    -- PurchaseDate within last ~3 years
    DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 1095), CAST(GETDATE() AS DATE)) AS PurchaseDate
FROM Numbers
OPTION (MAXRECURSION 0);

COMMIT TRANSACTION;

-- Queries (operable in SSMS)

-- 1) Total sales grouped by city
-- Returns City, TotalSales (rounded to 2 decimals), and number of purchases
SELECT
  City,
  ROUND(SUM(PurchaseAmount), 2) AS TotalSales,
  COUNT(*) AS NumPurchases
FROM dbo.SalesData
GROUP BY City
ORDER BY City;

-- 2) Top 5 cities by total revenue (descending)
SELECT TOP (5)
  City,
  ROUND(SUM(PurchaseAmount), 2) AS TotalRevenue,
  COUNT(*) AS NumPurchases
FROM dbo.SalesData
GROUP BY City
ORDER BY TotalRevenue DESC;

-- 3) Purchases (rows) where PurchaseAmount is greater than overall average purchase amount
SELECT
  CustomerID,
  Name,
  Age,
  City,
  PurchaseAmount,
  PurchaseDate
FROM dbo.SalesData
WHERE PurchaseAmount > (SELECT AVG(PurchaseAmount) FROM dbo.SalesData)
ORDER BY PurchaseAmount DESC;

-- 4) Customers (by CustomerID) whose average purchase amount (across their purchases) is greater than the overall average
SELECT
  CustomerID,
  Name,
  ROUND(AVG(PurchaseAmount), 2) AS AvgPurchase,
  COUNT(*) AS NumPurchases
FROM dbo.SalesData
GROUP BY CustomerID, Name
HAVING AVG(PurchaseAmount) > (SELECT AVG(PurchaseAmount) FROM dbo.SalesData)
ORDER BY AvgPurchase DESC;

-- Cleanup temp tables (optional)
IF OBJECT_ID('tempdb..#FirstNames') IS NOT NULL DROP TABLE #FirstNames;
IF OBJECT_ID('tempdb..#LastNames') IS NOT NULL DROP TABLE #LastNames;
IF OBJECT_ID('tempdb..#Cities') IS NOT NULL DROP TABLE #Cities;
