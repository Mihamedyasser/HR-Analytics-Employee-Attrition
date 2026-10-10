/* =====================================================================
   HR Analytics - Step 2: Clean view
   File : sql/02_clean_view.sql
   Notes: - Attrition and OverTime are stored as BIT (1 = Yes, 0 = No)
          - Constant columns (EmployeeCount, StandardHours, Over18) and
            unclear pay columns (DailyRate, HourlyRate, MonthlyRate)
            are excluded.
          - Adds binned groups for age, distance, income and experience.
   ===================================================================== */

USE HR_Analytics;
GO

CREATE OR ALTER VIEW dbo.vw_HR_Clean AS
SELECT
    EmployeeNumber,
    Age,
    CASE
        WHEN Age < 26 THEN '18-25'
        WHEN Age < 36 THEN '26-35'
        WHEN Age < 46 THEN '36-45'
        WHEN Age < 56 THEN '46-55'
        ELSE '56+'
    END AS AgeGroup,
    CAST(Attrition AS INT) AS AttritionFlag,
    CASE WHEN Attrition = 1 THEN 'Yes' ELSE 'No' END AS Attrition,
    BusinessTravel,
    Department,
    JobRole,
    Gender,
    MaritalStatus,
    EducationField,
    Education,
    DistanceFromHome,
    CASE
        WHEN DistanceFromHome <= 5  THEN '0-5 km'
        WHEN DistanceFromHome <= 15 THEN '6-15 km'
        ELSE '16+ km'
    END AS DistanceGroup,
    MonthlyIncome,
    CASE
        WHEN MonthlyIncome < 3000  THEN 'Low (<3K)'
        WHEN MonthlyIncome < 6000  THEN 'Mid (3-6K)'
        WHEN MonthlyIncome < 10000 THEN 'High (6-10K)'
        ELSE 'Very High (10K+)'
    END AS IncomeGroup,
    CAST(OverTime AS INT) AS OverTimeFlag,
    CASE WHEN OverTime = 1 THEN 'Yes' ELSE 'No' END AS OverTime,
    JobLevel,
    JobSatisfaction,
    EnvironmentSatisfaction,
    RelationshipSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    PerformanceRating,
    NumCompaniesWorked,
    TotalWorkingYears,
    CASE
        WHEN TotalWorkingYears <= 2  THEN '0-2 yrs'
        WHEN TotalWorkingYears <= 5  THEN '3-5 yrs'
        WHEN TotalWorkingYears <= 10 THEN '6-10 yrs'
        ELSE '10+ yrs'
    END AS ExperienceGroup,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,
    TrainingTimesLastYear,
    StockOptionLevel,
    PercentSalaryHike
FROM dbo.HR_Employee;
GO

-- Quick test (expected: 1470 | 237 | 16.12)
SELECT COUNT(*) AS Total,
       SUM(AttritionFlag) AS Left_,
       CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS RatePct
FROM dbo.vw_HR_Clean;
GO