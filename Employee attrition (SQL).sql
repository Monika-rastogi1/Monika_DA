-- Creating a Database for HR_Analytics
CREATE DATABASE Project_HRDB;

USE Project_HRDB;

SHOW TABLES;

-- Importing the Excel File into SQL - Using the Table Data Import Wizard

-- SQL CODES FOR MANDATORY 6 KPIs

-- KPI-1 : Average Attrition Rate for All Departments
SELECT
	Department, AVG(CASE
	WHEN Attrition = "Yes" THEN 1
	ELSE 0
	END) * 100 AS Average_Attrition_Rate
FROM
	HR_Analytics
GROUP BY
	Department
ORDER BY
	Average_Attrition_Rate;

-- KPI-2 : Average Hourly Rate of Male Research Scientists
SELECT
	Department, AVG(HourlyRate) AS Average_Hourly_Rate
FROM
	HR_Analytics
WHERE
	Gender = 'Male'
AND
	JobRole = 'Research Scientist'
GROUP BY
	Department
ORDER BY
	Average_Hourly_Rate;

-- KPI-3 : Attrition Rate vs Monthly Income Stats
-- Group By Attrition:
SELECT
	Department,
    AVG(CASE
	WHEN Attrition = "Yes" THEN 1
	ELSE 0
	END) * 100 AS Average_Attrition_Rate,
	AVG(MonthlyIncome) AS Average_Monthly_Income -- AVG = MEAN (Statistics)
FROM
	HR_Analytics
GROUP BY
	Department;

-- KPI-4 : Average Working Years for Each Department
SELECT
	Department, AVG(TotalWorkingYears) AS Average_Working_Years
FROM
	HR_Analytics
GROUP BY
	Department
ORDER BY
	Average_Working_Years;

-- KPI-5 : Job Role vs Work-Life Balance
SELECT
	JobRole, WorkLifeBalance, Count(EmployeeNumber) AS Employee_Count
FROM
	HR_Analytics
GROUP BY
	JobRole, WorkLifeBalance
ORDER BY
	JobRole, WorkLifeBalance;

-- KPI-6 : Attrition Rate vs Years Since Last Promotion Relation
SELECT
    Promotion_Range,
    SUM(CASE
        WHEN Attrition = 'Yes' THEN 1
        ELSE 0
    END) AS Attrition_Employee_Count,
    SUM(CASE
        WHEN Attrition = 'Yes' THEN 1
        ELSE 0
    END) / (SELECT COUNT(*) FROM HR_Analytics WHERE Attrition = "Yes") * 100 AS Attrition_Rate
FROM (
    SELECT
        CASE
            WHEN YearsSinceLastPromotion >= 1 AND YearsSinceLastPromotion <= 10 THEN '1-10'
            WHEN YearsSinceLastPromotion >= 11 AND YearsSinceLastPromotion <= 20 THEN '11-20'
            WHEN YearsSinceLastPromotion >= 21 AND YearsSinceLastPromotion <= 30 THEN '21-30'
            ELSE '30+'
        END AS Promotion_Range,
        Attrition
    FROM
        HR_Analytics
) AS Subquery
GROUP BY
    Promotion_Range
ORDER BY
    Promotion_Range;

