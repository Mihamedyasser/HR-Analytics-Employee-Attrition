/* =====================================================================
   HR Analytics - Step 1: Create the database
   File : sql/01_create_db.sql

   After running this script:
   1. Right-click HR_Analytics > Tasks > Import Flat File...
   2. Choose WA_Fn-UseC_-HR-Employee-Attrition.csv
   3. Name the table HR_Employee (schema dbo)
      If the wizard keeps the file name, rename it with:
        EXEC sp_rename 'dbo.[WA_Fn-UseC_-HR-Employee-Attrition]', 'HR_Employee';
   ===================================================================== */

IF DB_ID('HR_Analytics') IS NULL
    CREATE DATABASE HR_Analytics;
GO