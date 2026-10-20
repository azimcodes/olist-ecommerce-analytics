-- CREATING STAGING TABLE FOR RAW ORDERS DATA 
USE OlistEcommerce
GO


CREATE TABLE Staging_Orders( 
		order_id VARCHAR(100) , 
		customer_id VARCHAR(100), 
		order_status VARCHAR(100),
		order_purchase_timestamp VARCHAR(100),
		order_approved_at VARCHAR(100),
		order_delivered_carrier_date VARCHAR(100),
		order_delivered_customer_date VARCHAR(100), 
		order_estimated_delivery_date VARCHAR(100)
)

--ADDING Orders DATA csv

BULK INSERT Staging_Orders 
	FROM  "D:\Olist Dataset\olist_orders_dataset.csv" 
	WITH (
		FORMAT = 'CSV' ,
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		FIELDQUOTE = '"',
		ROWTERMINATOR = '0x0a'
		);

		SELECT COUNT(*) AS TotalOrders 
		FROM Staging_Orders

	SELECT 
		order_status,
		COUNT(*) AS TotalOrders FROM Staging_Orders 
		GROUP BY order_status 
		ORDER BY TotalOrders DESC

--CHECKING MISSING ORDER TIMESTAMPS 

SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN order_purchase_timestamp IS NULL
          OR TRIM(order_purchase_timestamp) = ''
        THEN 1 ELSE 0
    END) AS MissingPurchaseDates,

    SUM(CASE
        WHEN order_approved_at IS NULL
          OR TRIM(order_approved_at) = ''
        THEN 1 ELSE 0
    END) AS MissingApprovalDates,

    SUM(CASE
        WHEN order_delivered_carrier_date IS NULL
          OR TRIM(order_delivered_carrier_date) = ''
        THEN 1 ELSE 0
    END) AS MissingCarrierDates,

    SUM(CASE
        WHEN order_delivered_customer_date IS NULL
          OR TRIM(order_delivered_customer_date) = ''
        THEN 1 ELSE 0
    END) AS MissingDeliveryDates,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NULL
          OR TRIM(order_estimated_delivery_date) = ''
        THEN 1 ELSE 0
    END) AS MissingEstimatedDates

FROM Staging_Orders; 

-- Checked Which orders delivered Without deliver date (8)
SELECT COUNT(*) AS DeliveredWithoutDate FROM Staging_Orders
WHERE order_status = 'delivered' 
    AND (order_delivered_customer_date IS NULL 
    OR TRIM(order_delivered_customer_date) = ' ')
    
   
-- Checking Whether There is Missing Customer References

SELECT COUNT(*) AS MissingCustomerReferences FROM Staging_Orders AS o
LEFT JOIN Customers as c
    ON TRIM(o.customer_id) = c.customer_id
    WHERE c.customer_id IS NULL

-- Checking Invalid Timestamps
    SELECT COUNT(*) AS InvalidDates FROM Staging_Orders
    WHERE TRY_CONVERT(datetime, order_purchase_timestamp) IS NULL

    SELECT
    SUM(CASE WHEN NULLIF(TRIM(order_approved_at), '') IS NOT NULL
             AND TRY_CONVERT(DATETIME, order_approved_at) IS NULL
        THEN 1 ELSE 0 END) AS InvalidApprovalDates,

    SUM(CASE WHEN NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
             AND TRY_CONVERT(DATETIME, order_delivered_carrier_date) IS NULL
        THEN 1 ELSE 0 END) AS InvalidCarrierDates,

    SUM(CASE WHEN NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
             AND TRY_CONVERT(DATETIME, order_delivered_customer_date) IS NULL
        THEN 1 ELSE 0 END) AS InvalidDeliveryDates,

    SUM(CASE WHEN NULLIF(TRIM(order_estimated_delivery_date), '') IS NOT NULL
             AND TRY_CONVERT(DATETIME, order_estimated_delivery_date) IS NULL
        THEN 1 ELSE 0 END) AS InvalidEstimatedDates

FROM Staging_Orders; 

-- Checking Duplicate IDs

SELECT 
    order_id, 
    COUNT(*) AS TotalOccurences FROM Staging_orders 
    GROUP BY order_id
    HAVING COUNT(*) > 1

--INSERTING INTO real Orders Table After checking
    INSERT INTO Orders( 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    )
SELECT
    TRIM(order_id),
    TRIM(customer_id),
    TRIM(order_status),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(order_purchase_timestamp), '')),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(order_approved_at), '')),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(order_delivered_carrier_date), '')),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(order_delivered_customer_date), '')),
    TRY_CONVERT(DATETIME, NULLIF(TRIM(order_estimated_delivery_date), ''))
FROM Staging_Orders; 

SELECT
    (SELECT COUNT(*) FROM Staging_Orders) AS StagingCount,
    (SELECT COUNT(*) FROM Orders) AS OrderCount