CREATE TABLE SalesData (
    CustomerID INT,
    Name VARCHAR(50),
    Age INT,
    City VARCHAR(50),
    PurchaseAmount DECIMAL(10,2),
    PurchaseDate DATE
);
WITH Numbers AS (
    SELECT TOP 10000 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Num
    FROM sys.objects a
    CROSS JOIN sys.objects b
)

INSERT INTO SalesData
SELECT
    Num AS CustomerID,
    CONCAT('Customer_', Num) AS Name,
    18 + ABS(CHECKSUM(NEWID())) % 50 AS Age,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1,
           'Delhi','Mumbai','Hyderabad','Chennai','Bangalore') AS City,
    CAST(100 + RAND(CHECKSUM(NEWID())) * 10000 AS DECIMAL(10,2)) AS PurchaseAmount,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()) AS PurchaseDate
FROM Numbers;
SELECT 
    City,
    SUM(PurchaseAmount) AS TotalSales
FROM SalesData
GROUP BY City;
SELECT TOP 5
    City,
    SUM(PurchaseAmount) AS TotalRevenue
FROM SalesData
GROUP BY City
ORDER BY TotalRevenue DESC;
SELECT *
FROM SalesData
WHERE PurchaseAmount >
(
    SELECT AVG(PurchaseAmount)
    FROM SalesData
);
