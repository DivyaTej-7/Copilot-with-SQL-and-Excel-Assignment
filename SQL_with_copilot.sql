-- Create table and insert 10,000 rows of random data (SQL Server)

IF OBJECT_ID('dbo.SalesData', 'U') IS NOT NULL
    DROP TABLE dbo.SalesData;
GO

CREATE TABLE dbo.SalesData (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT,
    City VARCHAR(50),
    PurchaseAmount DECIMAL(10,2),
    PurchaseDate DATE
);
GO

SET NOCOUNT ON;

BEGIN TRAN;

WITH Numbers AS (
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Num
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO dbo.SalesData (CustomerID, Name, Age, City, PurchaseAmount, PurchaseDate)
SELECT
    Num AS CustomerID,
    'Customer_' + CAST(Num AS VARCHAR(10)) AS Name,
    18 + ABS(CHECKSUM(NEWID())) % 50 AS Age,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Hyderabad'
        WHEN 3 THEN 'Chennai'
        ELSE 'Bangalore'
    END AS City,
    -- Purchase amount between ~100.00 and ~10100.00 with two decimals
    CAST(100.0 + (ABS(CHECKSUM(NEWID())) % 10000) + (ABS(CHECKSUM(NEWID())) % 100) / 100.0 AS DECIMAL(10,2)) AS PurchaseAmount,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, CAST(GETDATE() AS DATE)) AS PurchaseDate
FROM Numbers;

COMMIT TRAN;
GO

-- Quick checks
SELECT COUNT(*) AS TotalRows FROM dbo.SalesData;
SELECT City, COUNT(*) AS Customers, SUM(PurchaseAmount) AS TotalSales
FROM dbo.SalesData
GROUP BY City
ORDER BY TotalSales DESC;
GO