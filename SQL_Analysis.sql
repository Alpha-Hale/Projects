USE Performance

--------Filtering Data--------

SELECT *
FROM Opportunities_Data
WHERE Product_Category = 'Services' --1269 rows

SELECT *
FROM Opportunities_Data
WHERE Opportunity_Stage <> 'Stage - 0' --3390 rows

SELECT *
FROM Opportunities_Data
WHERE Opportunity_Stage IN ('Stage - 0', 'Stage - 2', 'Stage - 5')

SELECT *
FROM Opportunities_Data
WHERE Opportunity_Stage NOT IN ('Stage - 0', 'Stage - 2', 'Stage - 5')

SELECT *
FROM Opportunities_Data
WHERE New_Opportunity_Name LIKE '%Phase - 1%' --586 rows

SELECT *
FROM Opportunities_Data
WHERE New_Opportunity_Name NOT LIKE '%Phase - 1%' --586 rows

SELECT *
FROM Opportunities_Data
WHERE Product_Category = 'Services' AND Opportunity_Stage = 'Stage - 5'

SELECT *
FROM Opportunities_Data
WHERE Product_Category = 'Services' OR Opportunity_Stage = 'Stage - 5'

SELECT *
FROM Opportunities_Data
WHERE (Product_Category = 'Services' OR Opportunity_Stage = 'Stage - 5') OR New_Opportunity_Name LIKE '%Phase - 7%'

SELECT *
from Opportunities_Data
WHERE Est_Opportunity_Value > '50000'

SELECT *
from Opportunities_Data
WHERE Est_Opportunity_Value BETWEEN '30000' AND '50000'


-- 1 condition from another table   -- As the Opportunities Data table does not contain a sector column, the result will reflect the subquery based on the shared 'New Account No' column. 
SELECT *
FROM Opportunities_Data
WHERE New_Account_No IN (
SELECT CAST(New_Account_No AS nvarchar) FROM account
WHERE Sector = 'Banking')
--GROUP BY New_Account_No

--2
SELECT * 
FROM Opportunities_Data
WHERE Est_Completion_Month_ID IN (
SELECT DISTINCT Month_ID
FROM Calendar_lookup
WHERE Fiscal_Year = 'FY20')

--3
SELECT * 
FROM Opportunities_Data
WHERE Est_Completion_Month_ID IN (
SELECT DISTINCT Month_ID
FROM Calendar_lookup
WHERE Fiscal_Year = 'FY20') AND Est_Opportunity_Value > '50000'



--------IIF Statement--------

--1. Change the way how a value is displayed within a column (IFF statement)

SELECT New_Account_No, Opportunity_ID, New_Opportunity_Name, Est_Completion_Month_ID, Est_Opportunity_Value, 
IIF (Product_Category = 'Services', 'Services & Marketing', Product_Category) AS Product_Category
FROM Opportunities_Data

--2. Create a new column based on a condition (IFF statement)

SELECT *, 
IIF (New_Opportunity_Name LIKE '%Phase - 1%', 'Phase - 1',
IIF (New_Opportunity_Name LIKE '%Phase - 2%', 'Phase - 2',
IIF (New_Opportunity_Name LIKE '%Phase - 3%', 'Phase - 3',
IIF (New_Opportunity_Name LIKE '%Phase - 4%', 'Phase - 4',
IIF (New_Opportunity_Name LIKE '%Phase - 5%', 'Phase - 5', 'Needs Mapping'))))) AS Opp_Phase
FROM Opportunities_Data

--3. Select rows which need mapping by turning the previous query into a table

SELECT *
FROM
(
SELECT *, 
IIF (New_Opportunity_Name LIKE '%Phase - 1%', 'Phase - 1',
IIF (New_Opportunity_Name LIKE '%Phase - 2%', 'Phase - 2',
IIF (New_Opportunity_Name LIKE '%Phase - 3%', 'Phase - 3',
IIF (New_Opportunity_Name LIKE '%Phase - 4%', 'Phase - 4',
IIF (New_Opportunity_Name LIKE '%Phase - 5%', 'Phase - 5', 'Needs Mapping'))))) AS Opp_Phase
FROM Opportunities_Data
) a
WHERE Opp_Phase = 'Needs Mapping'  --1172 rows



--------Case Statement--------

--1 Change the way how a value is displayed within a column (CASE statement)

SELECT New_Account_No, Opportunity_ID, New_Opportunity_Name, Est_Completion_Month_ID, Est_Opportunity_Value, 
CASE 
	WHEN Product_Category = 'Services' THEN 'Services & Marketing' 
	ELSE Product_Category 
	END AS Product_Category
FROM Opportunities_Data

--2. Create a new column based on a condition (CASE statement)

SELECT *,
CASE
	WHEN New_Opportunity_Name LIKE '%Phase - 1%' THEN 'Phase - 1'
	WHEN New_Opportunity_Name LIKE '%Phase - 2%' THEN 'Phase - 2'
	WHEN New_Opportunity_Name LIKE '%Phase - 3%' THEN 'Phase - 3'
	WHEN New_Opportunity_Name LIKE '%Phase - 4%' THEN 'Phase - 4'
	WHEN New_Opportunity_Name LIKE '%Phase - 5%' THEN 'Phase - 5'
	ELSE 'Needs Mapping'
	END AS Opps_Phase
FROM Opportunities_Data



--------Update/Replace/Delete/Insert--------

-- 1. Permanently change how the values are displayed in a column (in practice, you would update a copied table, not the source table)

UPDATE account
SET Sector = IIF(Sector = 'Capital Markets/Securities', 'Capital Markets', Sector) 


--2. Permanently replace a value in a column, then update it (in practice, you would update a copied table, not the source table)

SELECT REPLACE(Account_Segment, 'PS', 'Public Sector') --AS 'New column name' is optional                          
FROM account

UPDATE account
SET Account_Segment = REPLACE(Account_Segment, 'PS', 'Public Sector')--AS 'New column name' is optional  


--3. Insert a new record into a table into the 'accounts' table

INSERT INTO account
SELECT '124785', 'Mali', 'FMCG', 'NULL', 'NULL', 'NULL', 'NULL', 'Sam'


--4. Deleting a record (in practice you would not delete any data from the source table)

DELETE 
FROM account
WHERE Industry_Manager = 'Sam'



--------Aggregation--------

--Sum the Est_Opportunity value by Product Category and aggregate by 1 column

SELECT Product_Category, Opportunity_Stage, SUM(CAST(Est_Opportunity_Value AS INT)) AS S_Est_Opportunity_Value   --You want to aggregate the 'Product Category column             
FROM Opportunities_Data
WHERE Opportunity_Stage = 'Stage - 4'
GROUP BY Product_Category, Opportunity_Stage    --You would usually group by the columns that you are not aggregating     


---Sum the Est_Opportunity value by Product Category and aggregate the data by 2 columns

SELECT Product_Category, Opportunity_Stage, SUM(CAST(Est_Opportunity_Value AS INT)) AS S_Est_Opportunity_Value   --You want to aggregate the 'Product Category column             
FROM Opportunities_Data
--WHERE Opportunity_Stage = 'Stage - 4'
GROUP BY Product_Category, Opportunity_Stage  
ORDER BY SUM(CAST(Est_Opportunity_Value AS INT)) DESC


--Show the number of opportunities per product category

SELECT Product_Category, COUNT(Opportunity_ID) AS No_of_Opps
FROM Opportunities_Data
GROUP BY Product_Category
ORDER BY COUNT(Opportunity_ID) DESC


-- Show the minimum opportunity value per product

SELECT Product_Category, MIN(CAST(Opportunity_ID AS INT)) AS Min_Est_Opp_Value
FROM Opportunities_Data
GROUP BY Product_Category
ORDER BY COUNT(Opportunity_ID) DESC


--------Joins------------

--1.Select the columns you need from all tables being joined. Include the column idenifier.
--2.Identify the column whiich is identical (column identifier) in each table so that you can join them
--3. At the top of the join, specify which columns you need from each column shown in the result


--1. Left Join - Everything included from the Opportunities Data table

SELECT a.*, b.New_Account_Name, b.Industry
FROM
	(
	SELECT New_Account_No, Opportunity_ID, New_Opportunity_Name, Est_Completion_Month_ID, Product_Category, Opportunity_Stage, Est_Opportunity_Value
	FROM Opportunities_Data
	) a --4133 rows

	LEFT JOIN
	(
	SELECT New_Account_No, New_Account_Name, Industry
	FROM account
	) b --1145 rows
	ON a.New_Account_No = b.New_Account_No

	--4133 rows overall

SELECT DISTINCT New_Account_No FROM Opportunities_Data --1139 distinct accounts
SELECT DISTINCT New_Account_No FROM account --1145 distinct accounts

--Therefore 6 accounts have not been included within the left join. To find out the accounts which have been excluded:

SELECT * FROM account WHERE New_Account_No NOT IN (SELECT DISTINCT New_Account_Name FROM Opportunities_Data) --6 accounts


--Unions All Joins & CTE Tables

WITH CTE_Category_Opps AS
(SELECT Product_Category, SUM(CAST(Est_Opportunity_Value AS INT)) as SUM_Est_Opps_Value
FROM Opportunities_Data
GROUP BY Product_Category

UNION ALL
SELECT 'Totals:' AS whatever, SUM(CAST(Est_Opportunity_Value AS INT)) AS SUM_Est_Opps_Value
FROM Opportunities_Data)


SELECT Product_Category FROM CTE_Category_Opps WHERE Product_Category = 'Labour'