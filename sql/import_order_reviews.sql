USE OlistEcommerce
GO 

CREATE TABLE Staging_OrderReviews(
	review_id VARCHAR(100),
	order_id VARCHAR(100),
	review_score VARCHAR(100),
	review_comment_title VARCHAR(300),
	review_comment_message VARCHAR(MAX),
	review_creation_date VARCHAR(100),
	review_answer_timestamp VARCHAR(100)
)

BULK INSERT Staging_OrderReviews
	FROM 'D:\Olist Dataset\olist_order_reviews_dataset.csv'
	WITH(
		FORMAT = 'CSV',
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		FIELDQUOTE = '"',
		ROWTERMINATOR = '0x0a'
	)

	SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'Staging_OrderReviews';


--INSERTING RAW DATA FOR CLEANING

BULK INSERT dbo.Staging_OrderReviews
FROM 'D:\Olist Dataset\olist_order_reviews_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001'
);

SELECT COUNT(*) AS TotalRows
FROM dbo.Staging_OrderReviews;

EXEC sp_help 'dbo.OrderReviews';

SELECT review_id,
COUNT(*) AS TotalOccurences FROM Staging_OrderReviews GROUP BY review_id HAVING COUNT(*) > 1

-- FINDING COMPOSITE PRIMARY KEY BECAUE review_id itself COULD not Be unique
SELECT
	review_id,
	order_id,
	review_score FROM Staging_OrderReviews WHERE review_id = '4c4bc2df56b20a1bc3749622240a427f'

--DOES THE COMBINATION OF review_id, order_id appear more than once(No)
SELECT 
	review_id,
	order_id FROM Staging_OrderReviews GROUP BY review_id , order_id HAVING COUNT(*) > 1

    
--CHECKING MISSING VALUES (ONLY review title , and review message which is allowed)
SELECT
    COUNT(*) AS TotalReviews,

    SUM(CASE WHEN review_id IS NULL OR TRIM(review_id) = ''
        THEN 1 ELSE 0 END) AS MissingReviewId,

    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = ''
        THEN 1 ELSE 0 END) AS MissingOrderId,

    SUM(CASE WHEN review_score IS NULL OR TRIM(review_score) = ''
        THEN 1 ELSE 0 END) AS MissingReviewScore,

    SUM(CASE WHEN review_comment_title IS NULL OR TRIM(review_comment_title) = ''
        THEN 1 ELSE 0 END) AS MissingCommentTitle,

    SUM(CASE WHEN review_comment_message IS NULL OR TRIM(review_comment_message) = ''
        THEN 1 ELSE 0 END) AS MissingCommentMessage,

    SUM(CASE WHEN review_creation_date IS NULL OR TRIM(review_creation_date) = ''
        THEN 1 ELSE 0 END) AS MissingCreationDate,

    SUM(CASE WHEN review_answer_timestamp IS NULL OR TRIM(review_answer_timestamp) = ''
        THEN 1 ELSE 0 END) AS MissingAnswerTimestamp

FROM Staging_OrderReviews;

--CHECKING INVALID DATA 
SELECT
    SUM(CASE
        WHEN TRY_CONVERT(INT, review_score) IS NULL
         AND NULLIF(TRIM(review_score), '') IS NOT NULL
        THEN 1 ELSE 0
    END) AS InvalidReviewScore,

    SUM(CASE
        WHEN TRY_CONVERT(DATETIME, review_creation_date) IS NULL
         AND NULLIF(TRIM(review_creation_date), '') IS NOT NULL
        THEN 1 ELSE 0
    END) AS InvalidCreationDate,

    SUM(CASE
        WHEN TRY_CONVERT(DATETIME, review_answer_timestamp) IS NULL
         AND NULLIF(TRIM(review_answer_timestamp), '') IS NOT NULL
        THEN 1 ELSE 0
    END) AS InvalidAnswerTimestamp

FROM Staging_OrderReviews;

--CHEKING WHETHER REVIEW SCORE is Between 1-5
SELECT COUNT(*) AS InvalidReviewScoreRange
FROM Staging_OrderReviews
WHERE TRY_CONVERT(INT, review_score) NOT BETWEEN 1 AND 5; 

-- CHEKING UnMatched Orders
SELECT COUNT(*) AS UnmatchedOrders FROM Staging_OrderReviews AS r
LEFT JOIN Orders AS o ON TRIM(o.order_id) = r.order_id WHERE o.order_id IS NULL

SELECT
    SUM(CASE WHEN LEN(TRIM(review_id)) > 32 THEN 1 ELSE 0 END) 
    AS InvalidReviewIdLength,
    SUM(CASE WHEN LEN(TRIM(order_id))>32 THEN 1 ELSE 0 END) 
    AS InvalidOrderIdLength,
    SUM(CASE WHEN LEN(TRIM(review_comment_title)) > 255 THEN 1 ELSE 0 END)
    AS InvalidReviewCommentTitleLength
    FROM Staging_OrderReviews 

--CREATING COMBINATED PRIMARY KEY with review id and order id to confront duplicates
ALTER TABLE dbo.OrderReviews
ADD CONSTRAINT PK_OrderReviews
PRIMARY KEY (review_id, order_id);
SELECT
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'OrderReviews'
  AND CONSTRAINT_NAME IN (
      SELECT CONSTRAINT_NAME
      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
      WHERE TABLE_NAME = 'OrderReviews'
        AND CONSTRAINT_TYPE = 'PRIMARY KEY'
  );


  -- AFTER ALL CHECKS ,INSERTING TO REAL TABLE
INSERT INTO dbo.OrderReviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    TRIM(review_id),
    TRIM(order_id),
    TRY_CONVERT(INT, review_score),
    NULLIF(TRIM(review_comment_title), ''),
    NULLIF(TRIM(review_comment_message), ''),
    TRY_CONVERT(DATETIME, review_creation_date),
    TRY_CONVERT(DATETIME, review_answer_timestamp)
FROM dbo.Staging_OrderReviews;

SELECT
    (SELECT COUNT(*) FROM dbo.Staging_OrderReviews) AS StagingRows,
    (SELECT COUNT(*) FROM dbo.OrderReviews) AS FinalRows;
