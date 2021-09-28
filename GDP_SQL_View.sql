USE GDP

--1. Create an empty table

IF OBJECT_ID('Raw_Data') IS NOT NULL DROP TABLE Raw_Data

CREATE TABLE Raw_Data
(DEMO_IND NVARCHAR(200),
Indicator NVARCHAR(200),
[Location] NVARCHAR(200),
Country NVARCHAR(200),
[Time] NVARCHAR(200),
[Value] NVARCHAR(200),
[Flag_Codes] NVARCHAR(200),
Flags NVARCHAR(200)
)



--2. Import the data from excel into the table

BULK INSERT Raw_Data
FROM 'C:\Users\gail_\Documents\GDP\gdp_raw_data.csv'
WITH ( FORMAT = 'CSV');

SELECT * FROM Raw_Data



--3. Create a view

CREATE VIEW GDP_Excel_Data AS
SELECT a.*, b.GDP_Per_Capita
FROM
	(
	SELECT Country, [Time] AS Year_No, [Value] AS GDP_Value 
	FROM Raw_Data
	WHERE Indicator = 'GDP (current US$)'
	) a

	LEFT JOIN
	(
	SELECT Country, [Time] AS Year_No, [Value] AS GDP_Per_Capita
	FROM Raw_Data
	WHERE Indicator = 'GDP per capita (current US$)'
	) b
ON a.Country = b.Country AND a.Year_No = b.Year_No



--4. Call view

SELECT * FROM GDP_Excel_Data



