"""
HR Analytics - Advanced Analysis (Phase 3)
Correlations, seaborn charts, and models to find the main drivers of attrition.

Run from the project root:
    python python/hr_advanced.py

Requirements:
    pip install pandas numpy matplotlib seaborn scikit-learn
"""
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

sns.set_theme(style="whitegrid")

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "WA_Fn-UseC_-HR-Employee-Attrition.csv"
REPORTS = ROOT / "reports"
REPORTS.mkdir(exist_ok=True)

# ---------------------------------------------------------------------
# 1. Load and clean
# ---------------------------------------------------------------------
df = pd.read_csv(DATA_PATH)

# Constant / identifier columns carry no information
drop_cols = ["EmployeeCount", "StandardHours", "Over18", "EmployeeNumber"]
df = df.drop(columns=[c for c in drop_cols if c in df.columns])

df["AttritionFlag"] = (df["Attrition"] == "Yes").astype(int)
df["OverTimeFlag"] = (df["OverTime"] == "Yes").astype(int)
print(f"Rows: {len(df)} | Attrition rate: {df['AttritionFlag'].mean() * 100:.2f}%")

# ---------------------------------------------------------------------
# 2. Correlation of numeric features with attrition
# ---------------------------------------------------------------------
numeric = df.select_dtypes(include=np.number)
corr_target = (
    numeric.corr()["AttritionFlag"]
    .drop("AttritionFlag")
    .sort_values(key=abs, ascending=False)
)
corr_target.to_csv(REPORTS / "correlation_with_attrition.csv", header=["Correlation"])
print("\nTop 10 correlations with attrition:")
print(corr_target.head(10).round(3).to_string())

top = corr_target.head(12).sort_values()
plt.figure(figsize=(8, 6))
colors = ["#c0392b" if v > 0 else "#2980b9" for v in top.values]
plt.barh(top.index, top.values, color=colors)
plt.title("Top Numeric Correlations with Attrition")
plt.xlabel("Correlation")
plt.tight_layout()
plt.savefig(REPORTS / "correlation_with_attrition.png", dpi=160)
plt.close()

# Heatmap of the most relevant features
heat_cols = ["AttritionFlag"] + list(corr_target.head(10).index)
plt.figure(figsize=(10, 8))
sns.heatmap(numeric[heat_cols].corr(), annot=True, fmt=".2f", cmap="coolwarm", center=0)
plt.title("Correlation Heatmap (Top Features)")
plt.tight_layout()
plt.savefig(REPORTS / "correlation_heatmap.png", dpi=160)
plt.close()

# ---------------------------------------------------------------------
# 3. Seaborn charts for key insights
# ---------------------------------------------------------------------
# 3.1 Monthly income: leavers vs stayers
plt.figure(figsize=(7, 5))
sns.boxplot(data=df, x="Attrition", y="MonthlyIncome")
plt.title("Monthly Income: Stayers vs Leavers")
plt.tight_layout()
plt.savefig(REPORTS / "income_by_attrition.png", dpi=160)
plt.close()

# 3.2 OverTime x distance heatmap (attrition rate %)
df["DistanceGroup"] = pd.cut(
    df["DistanceFromHome"], bins=[-1, 5, 15, 100], labels=["0-5 km", "6-15 km", "16+ km"]
)
pivot = (
    df.pivot_table(index="OverTime", columns="DistanceGroup", values="AttritionFlag",
                   aggfunc="mean", observed=True) * 100
)
plt.figure(figsize=(7, 4))
sns.heatmap(pivot, annot=True, fmt=".1f", cmap="Reds")
plt.title("Attrition Rate (%) by OverTime and Distance")
plt.tight_layout()
plt.savefig(REPORTS / "attrition_overtime_distance.png", dpi=160)
plt.close()

# 3.3 Attrition rate by job role
role = (df.groupby("JobRole")["AttritionFlag"].mean() * 100).sort_values()
plt.figure(figsize=(9, 5))
plt.barh(role.index, role.values, color="#e67e22")
plt.title("Attrition Rate (%) by Job Role")
plt.xlabel("Attrition Rate (%)")
plt.tight_layout()
plt.savefig(REPORTS / "attrition_by_job_role.png", dpi=160)
plt.close()

# ---------------------------------------------------------------------
# 4. Modeling
# ---------------------------------------------------------------------
X = pd.get_dummies(
    df.drop(columns=["Attrition", "AttritionFlag", "OverTime", "DistanceGroup"]),
    drop_first=True,
).astype(float)
y = df["AttritionFlag"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)

# 4.1 Logistic Regression (interpretable)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

logit = LogisticRegression(max_iter=2000, class_weight="balanced")
logit.fit(X_train_s, y_train)
logit_proba = logit.predict_proba(X_test_s)[:, 1]
print("\n=== Logistic Regression ===")
print(f"ROC AUC: {roc_auc_score(y_test, logit_proba):.3f}")
print(classification_report(y_test, logit.predict(X_test_s), target_names=["Stayed", "Left"]))

coefs = pd.Series(logit.coef_[0], index=X.columns).sort_values(key=abs, ascending=False)
coefs.to_csv(REPORTS / "logistic_coefficients.csv", header=["Coefficient"])
top_coefs = coefs.head(12).sort_values()
plt.figure(figsize=(9, 6))
plt.barh(top_coefs.index,
         top_coefs.values,
         color=["#c0392b" if v > 0 else "#2980b9" for v in top_coefs.values])
plt.title("Logistic Regression: Top Drivers of Attrition\n(red = increases risk, blue = decreases risk)")
plt.xlabel("Standardized coefficient")
plt.tight_layout()
plt.savefig(REPORTS / "logistic_top_drivers.png", dpi=160)
plt.close()

# 4.2 Random Forest (feature importance)
rf = RandomForestClassifier(
    n_estimators=300, random_state=42, class_weight="balanced", min_samples_leaf=3
)
rf.fit(X_train, y_train)
rf_proba = rf.predict_proba(X_test)[:, 1]
print("\n=== Random Forest ===")
print(f"ROC AUC: {roc_auc_score(y_test, rf_proba):.3f}")
print(classification_report(y_test, rf.predict(X_test), target_names=["Stayed", "Left"]))

imp = pd.Series(rf.feature_importances_, index=X.columns).sort_values(ascending=False)
imp.to_csv(REPORTS / "rf_feature_importance.csv", header=["Importance"])
top_imp = imp.head(12).sort_values()
plt.figure(figsize=(9, 6))
plt.barh(top_imp.index, top_imp.values, color="#27ae60")
plt.title("Random Forest: Top 12 Feature Importances")
plt.xlabel("Importance")
plt.tight_layout()
plt.savefig(REPORTS / "rf_feature_importance.png", dpi=160)
plt.close()

print(f"\nSaved all tables and charts to: {REPORTS}")
