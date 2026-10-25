USE OlistEcommerce
GO

CREATE TABLE Staging_Sellers(
	seller_id VARCHAR(100),
	seller_zip_code_prefix VARCHAR(100), 
	seller_city VARCHAR(100), 
	seller_state VARCHAR(100)
 )

--INSERTING RAW DATA FOR CLEANING 

BULK INSERT  Staging_Sellers 
	FROM 'D:\Olist Dataset\olist_sellers_dataset.csv' 
	WITH (
		FORMAT = 'CSV', 
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		FIELDQUOTE = '"',
		ROWTERMINATOR = '0x0a'
	)
-- Checking Duplicate IDs
SELECT 
	seller_id, 
	COUNT(*) AS TotalOccurences FROM Staging_Sellers GROUP BY seller_id HAVING COUNT(*)>1 


--CHECKING MISSING PRODUCT INFORMATION 
SELECT COUNT(*) AS TotalSellers,
	SUM(CASE WHEN seller_city IS NULL OR TRIM(seller_city)= '' THEN 1 ELSE 0 END) AS MissingSellerCity,
	SUM(CASE WHEN seller_state IS NULL OR TRIM(seller_state)='' THEN 1 ELSE 0 END) AS MissingSellerState,
	SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id)='' THEN 1 ELSE 0 END) AS MissingId,
	SUM(CASE WHEN seller_zip_code_prefix IS NULL OR TRIM(seller_zip_code_prefix)='' THEN 1 ELSE 0 END) AS MissingZipCodePrefix
	FROM Staging_Sellers


SELECT
	COUNT(*) AS InvalidZipCodePrefix FROM Staging_Sellers WHERE TRY_CONVERT(INT , seller_zip_code_prefix) IS NULL
	AND NULLIF(TRIM(seller_zip_code_prefix),'') IS NOT NULL 

--CHECKING ALL ZIP IS 5  DIGIT
SELECT COUNT(*) AS InvalidZipLength
FROM Staging_Sellers
WHERE LEN(TRIM(seller_zip_code_prefix)) <> 5
  AND NULLIF(TRIM(seller_zip_code_prefix), '') IS NOT NULL;
  
SELECT COUNT(*) AS InvalidSellerState
FROM Staging_Sellers
WHERE LEN(TRIM(seller_state)) <> 2
  AND NULLIF(TRIM(seller_state), '') IS NOT NULL;


INSERT INTO Sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    TRIM(seller_id),
    NULLIF(TRIM(seller_zip_code_prefix), ''),
    NULLIF(TRIM(seller_city), ''),
    NULLIF(TRIM(seller_state), '')
FROM Staging_Sellers;

SELECT
    (SELECT COUNT(*) FROM Staging_Sellers) AS StagingCount,
    (SELECT COUNT(*) FROM Sellers) AS FinalCount;


--CHANGING seller_zip_code_prefix column to VARCHAR 5 for NUMBERS can be started WITH 0
ALTER TABLE Sellers
ALTER COLUMN seller_zip_code_prefix VARCHAR(5) NULL; 

