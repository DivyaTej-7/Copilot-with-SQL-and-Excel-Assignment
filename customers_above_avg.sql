-- 1) Individual purchase rows where the purchase amount is above the overall average purchase
SELECT *
FROM SalesData
WHERE PurchaseAmount > (SELECT AVG(PurchaseAmount) FROM SalesData);

-- 2) Distinct customers who have at least one purchase above the overall average
SELECT DISTINCT CustomerID, Name, City
FROM SalesData
WHERE PurchaseAmount > (SELECT AVG(PurchaseAmount) FROM SalesData);

-- 3) Customers whose total purchases (sum per customer) are above the average total-per-customer
WITH PerCustomer AS (
    SELECT CustomerID, Name, City, SUM(PurchaseAmount) AS TotalPurchase
    FROM SalesData
    GROUP BY CustomerID, Name, City
)
SELECT *
FROM PerCustomer
WHERE TotalPurchase > (SELECT AVG(TotalPurchase) FROM PerCustomer)
ORDER BY TotalPurchase DESC;