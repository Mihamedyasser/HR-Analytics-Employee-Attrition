/*
HR Analytics — SQL starter queries
Import the CSV into SQL Server as dbo.HR_Employee before running.
Check that imported column names match the CSV.
*/

-- 1. Overall attrition KPI
SELECT
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS EmployeesLeft,
    CAST(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS AttritionRatePct
FROM dbo.HR_Employee;

-- 2. Attrition rate by department
SELECT
    Department,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS EmployeesLeft,
    CAST(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS AttritionRatePct
FROM dbo.HR_Employee
GROUP BY Department
ORDER BY AttritionRatePct DESC;

-- 3. Compare attrition by overtime
SELECT
    OverTime,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS EmployeesLeft,
    CAST(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS AttritionRatePct
FROM dbo.HR_Employee
GROUP BY OverTime
ORDER BY AttritionRatePct DESC;

-- 4. Attrition rate by job role
SELECT
    JobRole,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS EmployeesLeft,
    CAST(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS AttritionRatePct
FROM dbo.HR_Employee
GROUP BY JobRole
ORDER BY AttritionRatePct DESC;
