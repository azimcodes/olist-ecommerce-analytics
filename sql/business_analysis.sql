USE OlistEcommerce
GO


--TOTAL REVENUE OF ORDERS
SELECT SUM(oi.price) AS TotalRevenue FROM Orders AS o
INNER JOIN OrderItems AS oi ON o.order_id = oi.order_id 
WHERE o.order_status = 'delivered' 

--TOTAL DELIVERED ORDERS
SELECT COUNT(DISTINCT o.order_id) AS TotalDeliveredOrders FROM Orders AS o
INNER JOIN OrderItems AS oi ON o.order_id = oi.order_id 
WHERE o.order_status = 'delivered' 


--Average Order Value

SELECT
    SUM(oi.price) AS TotalRevenue,
    COUNT(DISTINCT o.order_id) AS TotalDeliveredOrders,
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS AOV
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


SELECT
    order_id,
    YEAR(order_purchase_timestamp) AS OrderYear,
    MONTH(order_purchase_timestamp) AS OrderMonth
    FROM Orders


--How many orders got received each year?
    SELECT
    YEAR(order_purchase_timestamp) AS OrderYear,
    COUNT(*) AS TotalOrders
    FROM Orders
    GROUP BY YEAR(order_purchase_timestamp)
    ORDER BY OrderYear;

--How much product revenue did Olist generate each month from delivered orders 
    SELECT TOP 5
    YEAR(order_purchase_timestamp) AS OrderYear,
    MONTH(order_purchase_timestamp) AS OrderMonth,
    SUM(oi.price) AS TotalRevenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id),2) AS AOV,
    COUNT(DISTINCT o.order_id) AS TotalOrders
    FROM Orders AS o INNER JOIN OrderItems AS oi ON o.order_id=oi.order_id WHERE o.order_status = 'delivered'
    GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp)
    HAVING SUM(oi.price) > 980000
    ORDER BY TotalRevenue DESC

--Which months generated more revenue than the average monthly revenue?
WITH MonthlySales AS
 (
    SELECT
        YEAR(o.order_purchase_timestamp) AS OrderYear,
        MONTH(o.order_purchase_timestamp) AS OrderMonth,
        SUM(oi.price) AS TotalRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) SELECT
    OrderYear,
    OrderMonth,
    TotalRevenue
FROM MonthlySales WHERE TotalRevenue > (
    SELECT AVG(TotalRevenue)
    FROM MonthlySales
)
ORDER BY TotalRevenue DESC;



WITH MonthlySales AS
 (
    SELECT
        YEAR(o.order_purchase_timestamp) AS OrderYear,
        MONTH(o.order_purchase_timestamp) AS OrderMonth,
        SUM(oi.price) AS TotalRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) SELECT
    OrderYear,
    OrderMonth,
    TotalRevenue,
    ROW_NUMBER() OVER (ORDER BY TotalRevenue DESC) AS RowNum,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank,
    DENSE_RANK() OVER (ORDER BY TotalRevenue DESC) AS DenseRevenueRank
FROM MonthlySales WHERE TotalRevenue > (
    SELECT AVG(TotalRevenue)
    FROM MonthlySales
)


--Which product categories generated the highest revenue from delivered orders?

SELECT TOP 3
    pct.product_category_name_english,
    SUM(oi.price) AS TotalRevenue
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
INNER JOIN Products AS p
    ON oi.product_id = p.product_id
INNER JOIN ProductCategoryTranslation AS pct
    ON p.product_category_name = pct.product_category_name
WHERE o.order_status = 'delivered' GROUP BY pct.product_category_name_english ORDER BY TotalRevenue DESC; 

--Which sellers generated the highest product revenue from delivered orders?

SELECT TOP 3
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.price) AS TotalRevenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id),2) AS AOV
FROM Orders AS o 
    INNER JOIN OrderItems AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered' GROUP BY oi.seller_id ORDER BY TotalRevenue DESC

--Which Brazilian states generate the highest seller revenue?

SELECT TOP 5
    s.seller_state,
    SUM(oi.price) AS TotalRevenue, 
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT s.seller_id) AS TotalSellers,
    ROUND(SUM(oi.price) / COUNT(DISTINCT s.seller_id),2) AS AOV
        FROM Sellers AS s 
            INNER JOIN OrderItems as oi ON s.seller_id = oi.seller_id
            INNER JOIN Orders as o ON o.order_id = oi.order_id
            WHERE o.order_status = 'delivered'
            GROUP BY s.seller_state HAVING SUM(oi.price)>800000 ORDER BY TotalRevenue DESC


--how to find the top 3 sellers in every state using a CTE
WITH SellerRanking AS(
SELECT
    s.seller_state,
    s.seller_id,
    SUM(oi.price) AS TotalRevenue,

        ROW_NUMBER() OVER (
        PARTITION BY s.seller_state
        ORDER BY SUM(oi.price) DESC
    ) AS SellerRank
        FROM Sellers AS s 
            INNER JOIN OrderItems as oi ON s.seller_id = oi.seller_id
            INNER JOIN Orders as o ON o.order_id = oi.order_id
            WHERE o.order_status = 'delivered'
            GROUP BY  s.seller_id , s.seller_state
) SELECT * FROM SellerRanking WHERE SellerRank <= 3;


WITH MonthlyRevenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS OrderYear,
        MONTH(o.order_purchase_timestamp) AS OrderMonth,
        SUM(oi.price) AS TotalRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT
    OrderYear,
    OrderMonth,
    TotalRevenue,
    LAG(TotalRevenue) OVER (
    ORDER BY OrderYear, OrderMonth
) AS PreviousRevenue
FROM MonthlyRevenue
ORDER BY OrderYear, OrderMonth;

--Calculate growth percentage
WITH MonthlyRevenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS OrderYear,
        MONTH(o.order_purchase_timestamp) AS OrderMonth,
        SUM(oi.price) AS TotalRevenue
    FROM Orders AS o
    INNER JOIN OrderItems AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
RevenueComparison AS (
    SELECT *, LAG(TotalRevenue) OVER (
    ORDER BY OrderYear, OrderMonth
) AS PreviousRevenue FROM MonthlyRevenue
)
SELECT
    OrderYear,
    OrderMonth,
    TotalRevenue,
    PreviousRevenue,
       ROUND(
        (TotalRevenue - PreviousRevenue)
        / NULLIF(PreviousRevenue, 0) * 100,
        2
    ) AS GrowthPercentage
FROM RevenueComparison
ORDER BY OrderYear, OrderMonth; 
            

--Which order items are low, medium, or high value? 

SELECT TOP 20
    product_id,
    price,
    CASE 
        WHEN price<100 THEN 'LOW VALUE'
        WHEN price<500 THEN 'MEDIUM VALUE'
        ELSE 'HIGH VALUE' END AS PRICECATEGORY FROM OrderItems ORDER BY price DESC 


--How many customers purchased only once, and how many returned to purchase again?

SELECT 
    customer_unique_id, 
    CASE WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One Time' ELSE 'Repeat' END      
    AS CustomerSegment FROM
    Customers AS c INNER JOIN Orders AS o 
    ON c.customer_id = o.customer_id WHERE o.order_status = 'delivered'
    GROUP BY customer_unique_id


SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    CASE
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerSegment
    FROM Customers AS c
    INNER JOIN Orders AS o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
    ORDER BY TotalOrders DESC;


