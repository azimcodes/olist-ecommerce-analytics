
USE OlistEcommerce
GO


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

--CHECKING ALL FOREIGN KEYS ARE REAlLY CONNECTED
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys AS fk;


CREATE TABLE Staging_Customers (
    customer_id VARCHAR(100),
    customer_unique_id VARCHAR(100), 
    customer_zip_code_prefix VARCHAR(100), 
    customer_city VARCHAR(100), 
    customer_state VARCHAR(100)
)

BULK INSERT Staging_Customers
FROM 'D:\Olist Dataset\olist_customers_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a'
)

--CHECKING CUSTOMER ID OCCURENCE COUNT TO SEE WHETHER IS UNIQUE 

SELECT 
customer_id,
COUNT(*) AS TotalOccurences 
FROM Staging_Customers GROUP BY customer_id HAVING COUNT(*) >1;

--CHECKING NULL 
SELECT COUNT(*) AS MissingCustomers FROM Staging_Customers WHERE customer_id IS NULL OR TRIM(customer_id) = '';
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN customer_unique_id IS NULL OR TRIM (customer_unique_id) = '' THEN 1 ELSE 0 END) AS MissinUniqueIDS,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL OR TRIM (customer_zip_code_prefix) = '' THEN 1 ELSE 0 END) as MissingZipCodes,
    SUM(CASE WHEN customer_city IS NULL OR TRIM(customer_city) = '' THEN 1 ELSE 0 END) AS MissingCities,
    SUM(CASE WHEN customer_state IS NULL OR TRIM(customer_state) = '' THEN 1 ELSE 0 END) AS MissingStates
FROM Staging_Customers;

--CHECKING CUSTOMER ZIP CODE PREFIX that they all have same length
SELECT
    LEN(TRIM(customer_zip_code_prefix)) AS ZipCodeLength , COUNT(*) AS TotalRecords  
    FROM Staging_Customers GROUP BY LEN(TRIM(customer_zip_code_prefix)) 
    ORDER BY ZipCodeLength


SELECT
    customer_zip_code_prefix
    FROM Staging_Customers 
    WHERE TRY_CONVERT(INT, customer_zip_code_prefix) IS NULL;

INSERT INTO Customers(
     customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT 
    TRIM(customer_id),
    TRIM(customer_unique_id),
    TRIM(customer_zip_code_prefix), 
    TRIM(customer_city),
    TRIM(customer_state)
FROM Staging_Customers;

--FINAL CHECK FOR COUNTS MATCHING
SELECT
    (SELECT COUNT(*) FROM Staging_Customers) AS StagingCount,
    (SELECT COUNT(*) FROM Customers) AS FinalCount;
