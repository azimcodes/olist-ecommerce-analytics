USE OlistEcommerce
GO  

CREATE TABLE Staging_OrderItems( 
	order_id VARCHAR(100),
	order_item_id VARCHAR(100),
	product_id VARCHAR(100),
	seller_id VARCHAR(100),
	shipping_limit_date VARCHAR(100),
	price VARCHAR(100),
	freight_value VARCHAR(100)
);

--INSERTING RAW DATA FOR CLEANING

BULK INSERT  Staging_OrderItems
	FROM 'D:\Olist Dataset\olist_order_items_dataset.csv'
	WITH (
		FORMAT = 'CSV', 
		FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		FIELDQUOTE = '"',
		ROWTERMINATOR = '0x0a'
	)
	SELECT COUNT(*) AS TotalOrderItems FROM Staging_OrderItems


-- Checking Duplicate IDs

SELECT 
	order_id , 
	order_item_id, 
	COUNT(*) AS TotalOccurences  FROM Staging_OrderItems  
	GROUP BY order_id,order_item_id 
	HAVING COUNT(*)>1

--CHECKING MISSING VALUES

SELECT
	COUNT(*) AS TotalOrderItems, 
	SUM(CASE WHEN order_id IS NULL OR TRIM(order_id)='' THEN 1 ELSE 0 END) AS MissingOrderId,
	SUM(CASE WHEN order_item_id IS NULL OR TRIM(order_item_id)='' THEN 1 ELSE 0 END) AS MissingOrderItemId, 
	SUM(CASE WHEN product_id IS NULL OR TRIM(product_id)='' THEN 1 ELSE 0 END) AS MissingProductId,
	SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id)='' THEN 1 ELSE 0 END) AS MissingSellerId
	FROM Staging_OrderItems

--CHECKINK UNMATCHED ORDERS
	SELECT COUNT(*) AS UnmatchedOrders FROM Staging_OrderItems AS oi 
	LEFT JOIN Orders AS o ON TRIM(oi.order_id) = o.order_id WHERE o.order_id IS NULL

--CHECKING UNMATCHED PRODUCTS

	SELECT COUNT(*) AS UnmatchedProducts FROM Staging_OrderItems AS oi
	LEFT JOIN Products AS p ON TRIM(oi.product_id) = p.product_id WHERE p.product_id IS NULL

--CHECKING UNMATCHED SELLERS
	SELECT COUNT(*) AS UnmatchedSellers FROM Staging_OrderItems AS oi 
	LEFT JOIN Sellers AS s ON TRIM(oi.seller_id) = s.seller_id WHERE s.seller_id IS NULL 


--CHECKING INVALID DATA 
SELECT COUNT(*) AS InvalidOrderItemIds FROM Staging_OrderItems
WHERE TRY_CONVERT(INT, order_item_id) IS NULL  

SELECT
	SUM(CASE WHEN TRY_CONVERT(decimal(10,2), price) IS NULL 
	AND NULLIF(TRIM(price),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidPrice,
	SUM(CASE WHEN TRY_CONVERT(decimal(10,2),freight_value ) IS NULL 
	AND NULLIF(TRIM(freight_value),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidFreightValue
	FROM Staging_OrderItems 

SELECT COUNT(*) AS InvalidShippingDate FROM Staging_OrderItems
WHERE TRY_CONVERT(DATETIME,shipping_limit_date) IS NULL
AND NULLIF(TRIM(shipping_limit_date),'') IS NOT NULL 


SELECT 
	SUM(CASE WHEN LEN(TRIM(order_id))>32 THEN 1 ELSE 0 END) AS InvalidOrderIdLength,
	SUM(CASE WHEN LEN(TRIM(product_id))>32 THEN 1 ELSE 0 END) AS InvalidProductIdLength,
	SUM(CASE WHEN LEN(TRIM(seller_id))>32 THEN 1 ELSE 0 END) AS InvalidSellerIdLength
	FROM Staging_OrderItems

--AFTER ALL CHECKING WE ARE INSERTING INTO ACTUAL TABLE
INSERT INTO OrderItems (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    TRIM(order_id),
    TRY_CONVERT(INT, order_item_id),
    TRIM(product_id),
    TRIM(seller_id),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(shipping_limit_date), '')),
    TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(price), '')),
    TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(freight_value), ''))
FROM Staging_OrderItems; 

SELECT COUNT(*) AS TotalOrderItems FROM OrderItems
