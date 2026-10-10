# HR Analytics — Employee Attrition Analysis

## Objective
Explore employee attrition patterns in a public, synthetic HR dataset and communicate findings using Python, SQL Server, and Power BI.

## Dataset
`WA_Fn-UseC_-HR-Employee-Attrition.csv` (1,470 rows, 35 columns). This is a sample/training dataset, not a record of a real employer's employees. Check the dataset page and terms before redistributing the raw file.

## Questions
1. What is the overall attrition rate?
2. How does attrition vary by department and job role?
3. How does attrition compare between employees with and without overtime?
4. What other factors (e.g., job satisfaction, monthly income, years at company) are worth investigating?

## Project structure
- `python/hr_eda.py`: data checks, KPI summaries, and two starter charts.
- `sql/hr_analysis.sql`: SQL Server queries (after importing CSV as `dbo.HR_Employee`).
- `reports/`: generated CSV summaries and charts after running the Python script.
- `WA_Fn-UseC_-HR-Employee-Attrition.csv`: source dataset included for local practice.

## Run Python
Install Python, then run:
```bash
pip install pandas matplotlib
python python/hr_eda.py
```

## Important interpretation note
These are descriptive associations, not proof that any factor causes employees to leave.
