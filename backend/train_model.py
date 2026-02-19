import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score

# Load dataset
df = pd.read_csv("kerala_professional_energy_dataset_5000.csv")

print("Columns in dataset:", df.columns)

# Use ONLY existing columns
X = df[["total_daily_units", "month"]]
y = df["monthly_bill"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = RandomForestRegressor(
    n_estimators=400,
    max_depth=15,
    random_state=42
)

model.fit(X_train, y_train)

predictions = model.predict(X_test)

print("MAE:", round(mean_absolute_error(y_test, predictions), 2))
print("R2 Score:", round(r2_score(y_test, predictions), 4))

joblib.dump(model, "energy_bill_model.pkl")

print("Model trained and saved successfully!")


