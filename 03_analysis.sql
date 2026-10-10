/* =====================================================================
   HR Analytics - Employee Attrition Analysis
   File    : sql/03_analysis.sql
   Source  : dbo.vw_HR_Clean (created in 02_clean_view.sql)
   Engine  : SQL Server
   Notes   : AttritionFlag = 1 means the employee left the company.
             Attrition rate = employees left / total employees * 100
   ===================================================================== */

USE HR_Analytics;
GO

/* ---------------------------------------------------------------------
   0. Sanity check: row count and overall attrition KPI
   Expected: 1470 | 237 | 16.12
   --------------------------------------------------------------------- */
SELECT
    COUNT(*)                                                    AS TotalEmployees,
    SUM(AttritionFlag)                                          AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean;
GO

/* ---------------------------------------------------------------------
   1. Attrition by Department (with share of total workforce)
   --------------------------------------------------------------------- */
SELECT
    Department,
    COUNT(*)                                                       AS TotalEmployees,
    SUM(AttritionFlag)                                             AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2))    AS AttritionRatePct,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS PctOfWorkforce
FROM dbo.vw_HR_Clean
GROUP BY Department
ORDER BY AttritionRatePct DESC;
GO

/* ---------------------------------------------------------------------
   2. Attrition by OverTime
   Also shows each group's share of ALL employees who left.
   --------------------------------------------------------------------- */
SELECT
    OverTime,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(AttritionFlag)                                              AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2))     AS AttritionRatePct,
    CAST(100.0 * SUM(AttritionFlag)
         / SUM(SUM(AttritionFlag)) OVER () AS DECIMAL(5,2))         AS PctOfAllLeavers
FROM dbo.vw_HR_Clean
GROUP BY OverTime
ORDER BY AttritionRatePct DESC;
GO

/* ---------------------------------------------------------------------
   3. Attrition by Age Group
   --------------------------------------------------------------------- */
SELECT
    AgeGroup,
    COUNT(*)                                                    AS TotalEmployees,
    SUM(AttritionFlag)                                          AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean
GROUP BY AgeGroup
ORDER BY AgeGroup;
GO

/* ---------------------------------------------------------------------
   4. Attrition by Income Group
   --------------------------------------------------------------------- */
SELECT
    IncomeGroup,
    COUNT(*)                                                    AS TotalEmployees,
    SUM(AttritionFlag)                                          AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean
GROUP BY IncomeGroup
ORDER BY AttritionRatePct DESC;
GO

/* ---------------------------------------------------------------------
   5. Job roles ranked by attrition rate (CTE + RANK window function)
   --------------------------------------------------------------------- */
WITH RoleStats AS (
    SELECT
        JobRole,
        COUNT(*)                                                    AS TotalEmployees,
        SUM(AttritionFlag)                                          AS EmployeesLeft,
        CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
    FROM dbo.vw_HR_Clean
    GROUP BY JobRole
)
SELECT
    RANK() OVER (ORDER BY AttritionRatePct DESC) AS RankNo,
    JobRole,
    TotalEmployees,
    EmployeesLeft,
    AttritionRatePct
FROM RoleStats
ORDER BY RankNo;
GO

/* ---------------------------------------------------------------------
   6. Leavers vs Stayers: income, tenure, time since last promotion
   (1.0 * forces decimal averages instead of integer rounding)
   --------------------------------------------------------------------- */
SELECT
    Attrition,
    COUNT(*)                                              AS Employees,
    CAST(AVG(1.0 * MonthlyIncome) AS DECIMAL(10,0))       AS AvgMonthlyIncome,
    CAST(AVG(1.0 * YearsAtCompany) AS DECIMAL(5,2))       AS AvgYearsAtCompany,
    CAST(AVG(1.0 * YearsSinceLastPromotion) AS DECIMAL(5,2)) AS AvgYearsSincePromotion
FROM dbo.vw_HR_Clean
GROUP BY Attrition;
GO

/* ---------------------------------------------------------------------
   7a. Attrition by Job Satisfaction (1 = Low ... 4 = High)
   --------------------------------------------------------------------- */
SELECT
    JobSatisfaction,
    COUNT(*)                                                    AS TotalEmployees,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;
GO

/* ---------------------------------------------------------------------
   7b. Attrition by Work-Life Balance (1 = Bad ... 4 = Best)
   Note: rating 1 has a small sample (80 employees).
   --------------------------------------------------------------------- */
SELECT
    WorkLifeBalance,
    COUNT(*)                                                    AS TotalEmployees,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;
GO

/* ---------------------------------------------------------------------
   8. Combined effect: OverTime x Distance from home
   Highest-risk segment: OverTime = Yes and 16+ km (~40.59%)
   --------------------------------------------------------------------- */
SELECT
    OverTime,
    DistanceGroup,
    COUNT(*)                                                    AS TotalEmployees,
    SUM(AttritionFlag)                                          AS EmployeesLeft,
    CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS AttritionRatePct
FROM dbo.vw_HR_Clean
GROUP BY OverTime, DistanceGroup
ORDER BY OverTime, DistanceGroup;
GO