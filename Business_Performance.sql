
--Business Performance Questions


--1. What is the total revenue of the company this year? FY21

SELECT SUM(Revenue) AS Total_Revenue_FY21 
FROM dbo.Revenue_Raw_Data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')



--2. What is the total revenue performance year on year (YoY)?

SELECT a.Total_Revenue_FY21, b.Total_Revenue_FY20, a.Total_Revenue_FY21-b.Total_Revenue_FY20 AS Diff_YoY, a.Total_Revenue_FY21 / b.Total_Revenue_FY20 - 1 AS Per_Diff_YoY
FROM
	(
	--FY21
	SELECT SUM(Revenue) AS Total_Revenue_FY21 
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')
	) a,
	(
	--FY20 
	SELECT SUM(Revenue) AS Total_Revenue_FY20 
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID -12  FROM Revenue_Raw_Data   
	WHERE Month_ID IN 
	(SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')) 
	) b

--As there is only 6 months of data available for FY21, we need to also compare this with the 6 months of data for FY20.
--To obtain the comparable 6 months of data for FY20, FY21 is filtered and then the previous 12 months selected.



--3. What is the MoM (month on month) revenue performance?

SELECT a.Total_Revenue_TM, b.Total_Revenue_LM, a.Total_Revenue_TM - b.Total_Revenue_LM AS MoM_Diff, a.Total_Revenue_TM / b.Total_Revenue_LM - 1 AS Perc_Diff_MoM
FROM
	(
	--This month
	SELECT SUM(Revenue) AS Total_Revenue_TM
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT MAX (Month_ID) FROM Revenue_Raw_Data)
	) a,

	(
	--Last month
	SELECT SUM(Revenue) AS Total_Revenue_LM
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT MAX (Month_ID)-1 FROM Revenue_Raw_Data)
	) b



--4. What is the total Revenue v's Target Performance for the year? FY21

SELECT a.Total_Revenue_FY21, b.Target_FY21, Total_Revenue_FY21 - b.Target_FY21 AS Dif, Total_Revenue_FY21 / b.Target_FY21 - 1 AS Perc_Diff
FROM 
	(
	--Revenue Performance for FY21
	SELECT SUM(Revenue) AS Total_Revenue_FY21 
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')
	) a,

	(
	--The targets are now comparable to the 6 months of data from FY21 revenue.
	SELECT SUM(Target) AS Target_FY21 FROM dbo.Targets_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21'))
	) b



--5. What is the Revenue V's Target Performance per month?

SELECT a.Month_ID, c.Fiscal_Month, a.Total_Revenue_FY21, b.Target_FY21, Total_Revenue_FY21 - b.Target_FY21 AS Dif, Total_Revenue_FY21 / b.Target_FY21 - 1 AS Perc_Diff
FROM
	(
	--Revenue Performance for FY21
	SELECT Month_ID, SUM(Revenue) AS Total_Revenue_FY21 
	FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')
	GROUP BY Month_ID
	) a

	LEFT JOIN
	(
	--The targets are now comparable to the 6 months of data from FY21 revenue.
	SELECT Month_ID, SUM(Target) AS Target_FY21 FROM dbo.Targets_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21'))
	GROUP BY Month_ID
	) b
	ON a.Month_ID = b.Month_ID

	LEFT JOIN
	(SELECT DISTINCT Month_ID, Fiscal_Month FROM dbo.Calendar_lookup) c
	ON a.Month_ID = c.Month_ID

ORDER BY a.Month_ID



--6. What is the best performing product in terms of revenue this year? FY21

SELECT SUM(Revenue) AS Revenue_Per_Category, Product_Category FROM dbo.Revenue_Raw_Data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup WHERE Fiscal_Year = 'FY21')
GROUP BY Product_Category
ORDER BY Revenue DESC



--7. What is the Product Performance V's Target for the month?

SELECT a.Product_Category, a.Month_ID, Revenue_Per_Category, Target, Revenue_Per_Category / Target - 1 AS Rev_Vs_Target
FROM
	(
	SELECT Month_ID, SUM(Revenue) AS Revenue_Per_Category, Product_Category FROM dbo.Revenue_Raw_Data
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM Revenue_Raw_Data)             
	GROUP BY Product_Category, Month_ID
	) a

	LEFT JOIN
	(
	SELECT SUM(Target) AS Target, Month_ID, Product_Category FROM Targets_Raw_Data
	WHERE Month_ID IN (SELECT MAX(Month_ID) FROM Revenue_Raw_Data)    
	GROUP BY Product_Category, Month_ID
	) b
ON a.Month_ID = b.Month_ID AND a.Product_Category = b.Product_Category



--8. Which opportunity has the highest opportunity value and what are the details? FY21

SELECT * FROM dbo.Opportunities_Data
WHERE Est_Completion_Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.Calendar_lookup
WHERE Fiscal_Year = 'FY21')
ORDER BY Est_Opportunity_Value DESC
