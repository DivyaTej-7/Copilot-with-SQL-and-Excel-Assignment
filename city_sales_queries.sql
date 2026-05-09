-- Total sales per city
SELECT
    City,
    SUM(PurchaseAmount) AS TotalSales
FROM SalesData
GROUP BY City
ORDER BY TotalSales DESC;

-- Top 5 cities by revenue (SQL Server)
SELECT TOP 5
    City,
    SUM(PurchaseAmount) AS TotalRevenue
FROM SalesData
GROUP BY City
ORDER BY TotalRevenue DESC;