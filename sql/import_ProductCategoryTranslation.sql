USE OlistEcommerce
GO
--INSERTING RAW DATA FOR CLEANING
CREATE TABLE Staging_ProductCategoryTranslation (
	product_category_name VARCHAR(100),
	product_category_name_english VARCHAR(100)
) 
BULK INSERT Staging_ProductCategoryTranslation 
	FROM 'D:\Olist Dataset\product_category_name_translation.csv' 
	WITH(
			FORMAT = 'CSV', 
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '0x0a'
	)

SELECT COUNT(*) AS TotalCategories
FROM Staging_ProductCategoryTranslation;

--CHECKING DUPLICATE AND MISSING INFORMATION
SELECT 
	product_category_name, 
	COUNT(*) AS TotalOccurences FROM Staging_ProductCategoryTranslation
	GROUP BY product_category_name
	HAVING COUNT(*)>1

SELECT COUNT(*) AS MissingCategoryNames
	FROM Staging_ProductCategoryTranslation 
	WHERE product_category_name IS NULL OR 
	TRIM(product_category_name) = ''

--INSERTING INTO REAL TABLE AFTER CHECKING

INSERT INTO ProductCategoryTranslation (product_category_name,product_category_name_english)
SELECT  
	TRIM(product_category_name),
	TRIM(product_category_name_english)
	FROM Staging_ProductCategoryTranslation

	SELECT COUNT(*) AS TotalCategories
FROM ProductCategoryTranslation; 


EXEC sp_help 'ProductCategoryTranslation';

--ADDING MISSING Category Names
INSERT INTO ProductCategoryTranslation (
    product_category_name,
    product_category_name_english
)
VALUES
    ('pc_gamer', NULL),
    ('portateis_cozinha_e_preparadores_de_alimentos', NULL);

	SELECT COUNT(*) AS TotalCategories
FROM ProductCategoryTranslation;
