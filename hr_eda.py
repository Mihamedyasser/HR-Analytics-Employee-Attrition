"""
HR Analytics — Employee Attrition Analysis
Run from this project folder:
    python python/hr_eda.py

Requirements:
    pip install pandas matplotlib
"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "WA_Fn-UseC_-HR-Employee-Attrition.csv"
REPORTS = ROOT / "reports"
REPORTS.mkdir(exist_ok=True)

df = pd.read_csv(DATA_PATH)

print("=" * 60)
print("HR ANALYTICS — INITIAL DATA QUALITY CHECK")
print("=" * 60)
print(f"Rows: {df.shape[0]}")
print(f"Columns: {df.shape[1]}")
print(f"Missing cells: {int(df.isna().sum().sum())}")
print(f"Duplicate rows: {int(df.duplicated().sum())}")
print("\nColumn types:")
print(df.dtypes.value_counts())
print("\nAttrition values:")
print(df["Attrition"].value_counts())
print("\nSample:")
print(df.head())

# Overall KPI
total = len(df)
left = int((df["Attrition"] == "Yes").sum())
rate = left / total * 100 if total else 0
print("\nOVERALL KPI")
print(f"Total employees: {total}")
print(f"Employees who left: {left}")
print(f"Attrition rate: {rate:.2f}%")

# Department summary
dept = (
    df.groupby("Department", dropna=False)
      .agg(TotalEmployees=("Attrition", "size"),
           EmployeesLeft=("Attrition", lambda s: (s == "Yes").sum()))
      .reset_index()
)
dept["AttritionRatePct"] = (dept["EmployeesLeft"] / dept["TotalEmployees"] * 100).round(2)
dept = dept.sort_values("AttritionRatePct", ascending=False)
dept.to_csv(REPORTS / "attrition_by_department.csv", index=False)
print("\nATTRITION BY DEPARTMENT")
print(dept.to_string(index=False))

# Overtime summary
overtime = (
    df.groupby("OverTime", dropna=False)
      .agg(TotalEmployees=("Attrition", "size"),
           EmployeesLeft=("Attrition", lambda s: (s == "Yes").sum()))
      .reset_index()
)
overtime["AttritionRatePct"] = (overtime["EmployeesLeft"] / overtime["TotalEmployees"] * 100).round(2)
overtime.to_csv(REPORTS / "attrition_by_overtime.csv", index=False)
print("\nATTRITION BY OVERTIME")
print(overtime.to_string(index=False))

# Job role summary
role = (
    df.groupby("JobRole", dropna=False)
      .agg(TotalEmployees=("Attrition", "size"),
           EmployeesLeft=("Attrition", lambda s: (s == "Yes").sum()))
      .reset_index()
)
role["AttritionRatePct"] = (role["EmployeesLeft"] / role["TotalEmployees"] * 100).round(2)
role = role.sort_values("AttritionRatePct", ascending=False)
role.to_csv(REPORTS / "attrition_by_job_role.csv", index=False)

# Plot 1: attrition rate by department
plt.figure(figsize=(8, 5))
plt.bar(dept["Department"].astype(str), dept["AttritionRatePct"])
plt.title("Employee Attrition Rate by Department")
plt.xlabel("Department")
plt.ylabel("Attrition Rate (%)")
plt.tight_layout()
plt.savefig(REPORTS / "attrition_by_department.png", dpi=160)
plt.close()

# Plot 2: attrition rate by overtime
plt.figure(figsize=(7, 5))
plt.bar(overtime["OverTime"].astype(str), overtime["AttritionRatePct"])
plt.title("Employee Attrition Rate by Overtime")
plt.xlabel("OverTime")
plt.ylabel("Attrition Rate (%)")
plt.tight_layout()
plt.savefig(REPORTS / "attrition_by_overtime.png", dpi=160)
plt.close()

print(f"\nSaved summary tables and charts to: {REPORTS}")
