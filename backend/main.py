from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import os
import numpy as np

app = FastAPI()

# ---------------------------
# CORS (Flutter Support)
# ---------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------
# Load Model
# ---------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "energy_bill_model.pkl")

if os.path.exists(MODEL_PATH):
    model = joblib.load(MODEL_PATH)
    print("Model Loaded Successfully!")
else:
    model = None
    print("Model file not found!")

# ---------------------------
# Request Schema (2 Features)
# ---------------------------
class BillRequest(BaseModel):
    total_daily_units: float
    month: int

# ---------------------------
# Root
# ---------------------------
@app.get("/")
def home():
    return {"message": "EnergEYE ML API Running 🚀"}

# ---------------------------
# Prediction
# ---------------------------
@app.post("/predict")
def predict_bill(data: BillRequest):

    if model is None:
        return {"error": "Model not loaded"}

    try:
        features = np.array([[
            data.total_daily_units,
            data.month
        ]])

        prediction = model.predict(features)

        return {
            "predicted_bill": round(float(prediction[0]), 2)
        }

    except Exception as e:
        return {"error": str(e)}

