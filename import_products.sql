USE OlistEcommerce
GO

CREATE TABLE Staging_Products (
	product_id VARCHAR(100) , 
	product_category_name VARCHAR(100),
	product_name_lenght VARCHAR(100), 
	product_description_lenght VARCHAR(100),
	product_photos_qty VARCHAR(100) , 
	product_weight_g VARCHAR(100), 
	product_length_cm VARCHAR(100), 
	product_height_cm VARCHAR(100), 
	product_width_cm VARCHAR(100) 
)  

--INSERTING RAW DATA FOR CLEANING

BULK INSERT Staging_Products 
	FROM 'D:\Olist Dataset\olist_products_dataset.csv' 
	WITH (
	FORMAT = 'CSV', 
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '0x0a'
	)

	SELECT COUNT(*) AS TotalProducts
FROM Staging_Products; 

-- Checking Duplicate IDs
SELECT 
	product_id, 
	COUNT(*) AS TotalOccurences FROM Staging_Products
	GROUP BY product_id
	HAVING COUNT(*) > 1  


--CHECKING MISSING PRODUCT INFORMATION  (610 MISSING CATEGORIES , 2 Missing Weights )

SELECT 
	COUNT(*) AS TotalProducts,  
	SUM(CASE 
		WHEN product_category_name IS NULL OR TRIM(product_category_name)= '' THEN 1 ELSE 0 END 
	) AS MissingCategories , 

	SUM(CASE WHEN product_weight_g IS NULL OR TRIM(product_weight_g)= '' THEN 1 ELSE 0 END) AS MissingWeights 
	FROM Staging_Products


	SELECT COUNT(*) AS InvalidWeights FROM Staging_Products WHERE TRY_CONVERT(INT ,product_weight_g) IS NULL 
	AND NULLIF(TRIM(product_weight_g),'') IS NOT NULL

	SELECT 
		SUM(CASE WHEN TRY_CONVERT(INT, product_name_lenght) IS NULL AND 
		NULLIF(TRIM(product_name_lenght),'') IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidProductName,

		SUM(CASE WHEN TRY_CONVERT(INT, product_description_lenght) IS NULL 
		AND NULLIF(TRIM(product_description_lenght),'') IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidProductDescription, 
		
		SUM(CASE WHEN TRY_CONVERT(INT ,product_photos_qty)IS NULL
		AND NULLIF(TRIM(product_photos_qty),'')IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidProductPhotos,
		
		SUM(CASE WHEN TRY_CONVERT(INT ,product_length_cm) IS NULL 
		AND NULLIF(TRIM(product_length_cm), '') IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidProductLength,

		SUM(CASE WHEN TRY_CONVERT(INT ,product_height_cm) IS NULL 
		AND NULLIF(TRIM(product_height_cm), '') IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidHeightLength , 

		SUM(CASE WHEN TRY_CONVERT(INT ,product_width_cm) IS NULL 
		AND NULLIF(TRIM(product_width_cm), '') IS NOT NULL 
		THEN 1 ELSE 0 END) AS InvalidWidthLength

		FROM Staging_Products


--CHECKING UNMATCHED FOREIGN KEYs (13) 

SELECT TRIM(p.product_category_name) AS UnmatchedCategory, 
COUNT(*) AS TotalProducts
FROM Staging_Products AS p 
LEFT JOIN ProductCategoryTranslation AS t ON TRIM(p.product_category_name) =t.product_category_name 
WHERE t.product_category_name IS NULL AND NULLIF(TRIM(p.product_category_name),'')IS NOT NULL
GROUP BY TRIM(p.product_category_name)


SELECT COUNT(*) AS UnmatchedCategories FROM Staging_Products AS p
LEFT JOIN ProductCategoryTranslation AS t ON TRIM(p.product_category_name) = t.product_category_name 
WHERE t.product_category_name IS NULL AND NULLIF(TRIM(p.product_category_name),'')IS NOT NULL

--INSERTING INTO REAL PRODUCTS

INSERT INTO Products ( 
		product_id,
		product_category_name,
		product_name_lenght,
		product_description_lenght,
		product_photos_qty,
		product_weight_g,
		product_length_cm,
		product_height_cm,
		product_width_cm
	)
	SELECT 
		TRIM(product_id),
		NULLIF(TRIM(product_category_name), ''),
		TRY_CONVERT(INT,NULLIF(TRIM(product_name_lenght),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_description_lenght),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_photos_qty),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_weight_g),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_length_cm),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_height_cm),'')),
		TRY_CONVERT(INT,NULLIF(TRIM(product_width_cm),''))
		FROM Staging_Products

		SELECT
    (SELECT COUNT(*) FROM Staging_Products) AS StagingCount,
    (SELECT COUNT(*) FROM Products) AS FinalCount;