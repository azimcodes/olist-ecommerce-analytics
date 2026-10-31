USE OlistEcommerce
GO

CREATE TABLE Staging_GeoLocation(
	geolocation_zip_code_prefix VARCHAR(100),
	geolocation_lat VARCHAR(100),
	geolocation_lng VARCHAR(100),
	geolocation_city VARCHAR(100),
	geolocation_state VARCHAR(100)
) 

BULK INSERT Staging_GeoLocation
FROM 'D:\Olist Dataset\olist_geolocation_dataset.csv'
WITH(
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '0x0a'
)

SELECT COUNT(*) AS TotalRows
FROM Staging_Geolocation;


SELECT
	geolocation_zip_code_prefix,
	COUNT(*) AS TotalOccurences FROM Staging_GeoLocation
	GROUP BY geolocation_zip_code_prefix HAVING COUNT(*) > 1 ORDER BY TotalOccurences DESC

--CHECKING MISSIN VALUES
SELECT COUNT(*) AS TotalGeoLocations,
	SUM(CASE WHEN geolocation_zip_code_prefix IS NULL OR 
	TRIM(geolocation_zip_code_prefix) = ''THEN 1 ELSE 0 END ) AS MissingGeoLocationPrefix,
	SUM(CASE WHEN geolocation_lat IS NULL OR 
	TRIM(geolocation_lat) = '' THEN 1 ELSE 0 END) AS MissingGeoLocationLat,
	SUM(CASE WHEN geolocation_lng IS NULL OR 
	TRIM(geolocation_lng) = '' THEN 1 ELSE 0 END) AS MissingGeoLocationLng,
	SUM(CASE WHEN geolocation_city IS NULL OR 
	TRIM(geolocation_city) = '' THEN 1 ELSE 0 END) AS MissingGeoLocationCity,
	SUM(CASE WHEN geolocation_state IS NULL OR 
	TRIM(geolocation_state)= '' THEN 1 ELSE 0 END) AS MissingGeoLocationState
	FROM Staging_Geolocation

--CHECKING INVALID VALUES
SELECT 
	SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,7),geolocation_lat) IS NULL
	AND NULLIF(TRIM(geolocation_lat),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidGeoLocationLat,
	SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,7),geolocation_lng) IS NULL
	AND NULLIF(TRIM(geolocation_lng),'') IS NOT NULL THEN 1 ELSE 0 END) AS InvalidGeoLocationLng
	FROM Staging_GeoLocation 
SELECT
    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,7), geolocation_lat)
             NOT BETWEEN -90 AND 90
        THEN 1 ELSE 0
    END) AS InvalidLatitudeRange,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(10,7), geolocation_lng)
             NOT BETWEEN -180 AND 180
        THEN 1 ELSE 0
    END) AS InvalidLongitudeRange
FROM Staging_Geolocation;
	
	--Missing values, exactly 5 digits
	SELECT
    SUM(
        CASE
            WHEN (
                LEN(TRIM(geolocation_zip_code_prefix)) <> 5
                OR TRIM(geolocation_zip_code_prefix) LIKE '%[^0-9]%'
            )
            AND NULLIF(TRIM(geolocation_zip_code_prefix), '') IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS InvalidZipPrefix
FROM Staging_Geolocation;

--validate geolocation_state
SELECT
    SUM(CASE
        WHEN LEN(TRIM(geolocation_state)) <> 2
        AND NULLIF(TRIM(geolocation_state), '') IS NOT NULL
        THEN 1 ELSE 0
    END) AS InvalidStateLength
FROM Staging_Geolocation;

ALTER TABLE dbo.Geolocation
ALTER COLUMN geolocation_zip_code_prefix VARCHAR(5) NULL;

INSERT INTO Geolocation(
	geolocation_zip_code_prefix,
	geolocation_lat,
	geolocation_lng,
	geolocation_city,
	geolocation_state
)
SELECT
	TRIM(geolocation_zip_code_prefix),
	TRY_CONVERT(DECIMAL(10,7), geolocation_lat),
	TRY_CONVERT(DECIMAL(10,7), geolocation_lng),
	TRIM(geolocation_city),
	TRIM(geolocation_state)
 FROM Staging_GeoLocation 

 SELECT COUNT(*) AS TotalGeoLocations FROM Geolocation