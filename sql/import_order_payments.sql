USE OlistEcommerce
GO

CREATE TABLE Staging_OrderPayments (
    order_id VARCHAR(100),
    payment_sequential VARCHAR(100),
    payment_type VARCHAR(100),
    payment_installments VARCHAR(100),
    payment_value VARCHAR(100)
);

--INSERTING RAW DATA FOR CLEANING

BULK INSERT Staging_OrderPayments 
    FROM 'D:\Olist Dataset\olist_order_payments_dataset.csv'
    WITH(
        FORMAT = 'CSV',
        FIRSTROW = 2, 
		FIELDTERMINATOR = ',',
		FIELDQUOTE = '"',
		ROWTERMINATOR = '0x0a'
    ) 

    SELECT COUNT(*) AS TotalOrderPayments
    FROM Staging_OrderPayments

-- Checking Duplicate IDs

SELECT
    order_id,
    payment_sequential, COUNT (*) AS TotalOccurences
    FROM Staging_OrderPayments GROUP BY order_id,payment_sequential 
    HAVING COUNT(*)>1

--CHECKING MISSING VALUES

 SELECT 
    COUNT(*) AS TotalOrderPayments,
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id)='' THEN 1 ELSE 0 END) AS MissingOrderID,
    SUM(CASE WHEN payment_sequential IS NULL OR TRIM(payment_sequential)='' THEN 1 ELSE 0 END) AS MissingPaymentSequential,
    SUM(CASE WHEN payment_type IS NULL OR TRIM(payment_type)='' THEN 1 ELSE 0 END) AS MissingPaymentType,
    SUM(CASE WHEN payment_installments IS NULL OR TRIM(payment_installments)='' THEN 1 ELSE 0 END) AS MissingPaymentInstallment,
    SUM(CASE WHEN payment_value IS NULL OR TRIM(payment_value)='' THEN 1 ELSE 0 END) AS MissingPaymentValue
    FROM Staging_OrderPayments 
   
--CHECKING INVALID DATA 

SELECT 
    COUNT(*) AS TotalOrderPayments, 
    SUM(CASE WHEN TRY_CONVERT(INT,payment_sequential) IS NULL AND NULLIF(TRIM(payment_sequential),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidPaymentSequential,
    SUM(CASE WHEN TRY_CONVERT(INT,payment_installments) IS NULL AND NULLIF(TRIM(payment_installments),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidPaymentInstallment,
    SUM(CASE WHEN TRY_CONVERT(decimal(10,2),payment_value) IS NULL AND NULLIF(TRIM(payment_value),'')IS NOT NULL THEN 1 ELSE 0 END) AS InvalidPaymentValue 
 FROM Staging_OrderPayments 

 --CHEKING UNMATCHED DATA

 SELECT COUNT(*) AS UnmatchedOrders FROM Staging_OrderPayments AS op
 LEFT JOIN Orders AS o ON TRIM(op.order_id) = o.order_id WHERE o.order_id IS NULL


 SELECT
    SUM(CASE WHEN LEN(TRIM(order_id)) > 32 THEN 1 ELSE 0 END) AS InvalidOrderIdLength,
    SUM(CASE WHEN LEN(TRIM(payment_type)) > 30 THEN 1 ELSE 0 END) AS InvalidPaymentTypeLength
    FROM Staging_OrderPayments 

--AFTER ALL CHECKING WE ARE INSERTING INTO ACTUAL TABLE

INSERT INTO OrderPayments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    TRIM(order_id),
    TRY_CONVERT(INT, payment_sequential),
    TRIM(payment_type),
    TRY_CONVERT(INT, payment_installments),
    TRY_CONVERT(DECIMAL(10,2), payment_value)
FROM Staging_OrderPayments; 

SELECT COUNT(*) AS TotalOrderPayments FROM OrderPayments
