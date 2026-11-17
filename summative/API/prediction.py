from pathlib import Path
import joblib
import pandas as pd
from sklearn.base import clone
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

BASE_DIR = Path(__file__).parent
MODEL_PATH = BASE_DIR / "best_model.pkl"
TRAIN_DATA_PATH = BASE_DIR / "training_data.csv.gz"

CAT_COLS = ["country", "product", "season_name", "crop_production_system"]
NUM_COLS = ["area", "planting_year", "planting_month", "harvest_month"]
FEATURES = CAT_COLS + NUM_COLS
TARGET = "yield"

# Load the saved pipeline once, when the server starts
model = joblib.load(MODEL_PATH)

app = FastAPI(
    title="Crop Yield Prediction API",
    description="Predicts crop yield (tonnes per hectare) for African crop-season records.",
)

# CORS: browsers block web pages from calling an API on a different website
# unless the API says it is allowed. I allow only my deployed API URL and my
# local Flutter web debug address (no "*"), only the GET and POST methods this
# API uses, and only the Content-Type and Accept headers. Credentials are off
# because the API uses no cookies or logins. Everything else is blocked.
# (Rewrite this comment in your own words.)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://linear-regression-model-w79d.onrender.com",   # <- replace with your Render URL
        "http://localhost:8080",               # <- replace with your Flutter web debug port
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
def retrain(file: UploadFile = File(...)):
    global model

    if not file.filename.lower().endswith(".csv"):
        raise HTTPException(status_code=400, detail="Please upload a .csv file.")
    try:
        new = pd.read_csv(file.file)
    except Exception:
        raise HTTPException(status_code=400, detail="Could not read the file as a CSV.")

    missing = [c for c in FEATURES + [TARGET] if c not in new.columns]
    if missing:
        raise HTTPException(status_code=422, detail=f"Missing columns: {missing}")

    # keep only the needed columns, convert numbers, drop unusable rows
    new = new[FEATURES + [TARGET]].copy()
    for col in NUM_COLS + [TARGET]:
        new[col] = pd.to_numeric(new[col], errors="coerce")
    n_uploaded = len(new)
    new = new.dropna()
    ok = (
        (new["area"] > 0) & (new["area"] <= 5_000_000)
        & new["planting_year"].between(1960, 2035)
        & new["planting_month"].between(1, 12)
        & new["harvest_month"].between(1, 12)
        & (new[TARGET] > 0)
    )
    new = new[ok]
    if new.empty:
        raise HTTPException(status_code=422, detail="No valid rows found in the file.")

    # original data + new rows, then refit a fresh copy of the pipeline
    original = pd.read_csv(TRAIN_DATA_PATH)
    combined = pd.concat([original, new], ignore_index=True)

    new_model = clone(model)
    new_model.fit(combined[FEATURES], combined[TARGET])

    joblib.dump(new_model, MODEL_PATH, compress=3)   # save to disk
    model = new_model                                 # start using it right away
    combined.to_csv(TRAIN_DATA_PATH, index=False)     # remember the new rows for next time

    return {
        "message": "Model retrained and now in use.",
        "rows_uploaded": n_uploaded,
        "rows_used": len(new),
        "rows_rejected": n_uploaded - len(new),
        "total_training_rows": len(combined),
    }