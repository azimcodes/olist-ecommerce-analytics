--CREATE VIEW

GO

CREATE VIEW vw_CustomerSegments AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT o.order_id) - 1 AS RepeatPurchases,
    CASE
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerSegment
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id;

GO

SELECT
    CustomerSegment,
    COUNT(*) AS TotalCustomers
FROM vw_CustomerSegments
GROUP BY CustomerSegment; 

--HOW MUCH PERCENT OF CUSTOMERS ARE RepeatedCustomers
SELECT 
   COUNT(*) AS TotalCustomers,
   SUM(CASE WHEN RepeatPurchases > 0 THEN 1 ELSE 0 END) AS RepeatCustomers,
   ROUND(
   SUM(CASE WHEN RepeatPurchases>0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS RepeatPercentage
   FROM vw_CustomerSegments