from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from retrain import CAT_COLS, RetrainError, retrain_model

BASE_DIR = Path(__file__).parent
MODEL_PATH = BASE_DIR / "best_model.pkl"

# Load the saved pipeline once, when the server starts
model = joblib.load(MODEL_PATH)

app = FastAPI(
    title="Crop Yield Prediction API",
    description="Predicts crop yield (tonnes per hectare) for African crop-season records.",
)

# CORS: WRITE THIS COMMENT IN YOUR OWN WORDS. Say what you allow (which origins,
# methods, headers), what you restrict, and why you did not use "*".
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://linear-regression-model-w79d.onrender.com",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ],
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Accept"],
    allow_credentials=False,
)


class PredictionInput(BaseModel):
    country: str = Field(..., min_length=2, max_length=60, examples=["Benin"])
    product: str = Field(..., min_length=2, max_length=60, examples=["Onions"])
    season_name: str = Field(..., min_length=2, max_length=60, examples=["Main"])
    crop_production_system: str = Field(..., min_length=2, max_length=60, examples=["All (PS)"])
    area: float = Field(..., gt=0, le=5_000_000, description="Planted area in hectares", examples=[4.0])
    planting_year: int = Field(..., ge=1960, le=2035, examples=[2020])
    planting_month: int = Field(..., ge=1, le=12, examples=[3])
    harvest_month: int = Field(..., ge=1, le=12, examples=[10])


def known_categories():
    encoder = model.named_steps["prep"].named_transformers_["categorical"]
    return {col: set(cats) for col, cats in zip(CAT_COLS, encoder.categories_)}


@app.get("/")
def home():
    return {"message": "Crop Yield Prediction API is running."}


@app.post("/predict")
def predict(data: PredictionInput):
    row = pd.DataFrame([data.model_dump()])
    for col, allowed in known_categories().items():
        if row.loc[0, col] not in allowed:
            raise HTTPException(
                status_code=422,
                detail=f"Unknown {col}: '{row.loc[0, col]}'. It was not in the training data.",
            )
    prediction = float(model.predict(row)[0])
    return {"predicted_yield_t_per_ha": round(prediction, 3)}


@app.post("/retrain")
def retrain_endpoint(file: UploadFile = File(...)):
    global model

    if not file.filename.lower().endswith(".csv"):
        raise HTTPException(status_code=400, detail="Please upload a .csv file.")
    try:
        new = pd.read_csv(file.file)
    except Exception:
        raise HTTPException(status_code=400, detail="Could not read the file as a CSV.")

    try:
        new_model, summary = retrain_model(model, new)
    except RetrainError as e:
        raise HTTPException(status_code=422, detail=str(e))

    model = new_model        # start using the new model right away
    return {"message": "Model retrained and now in use.", **summary}