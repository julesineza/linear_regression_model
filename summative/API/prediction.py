from pathlib import Path
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

BASE_DIR = Path(__file__).parent
MODEL_PATH = BASE_DIR / "best_model.pkl"

# Load the saved pipeline once, when the server starts
model = joblib.load(MODEL_PATH)

CAT_COLS = ["country", "product", "season_name", "crop_production_system"]

app = FastAPI(
    title="Crop Yield Prediction API",
    description="Predicts crop yield (tonnes per hectare) for African crop-season records.",
)


class PredictionInput(BaseModel):
    # text fields: enforced as str
    country: str = Field(..., min_length=2, max_length=60, examples=["Benin"])
    product: str = Field(..., min_length=2, max_length=60, examples=["Onions"])
    season_name: str = Field(..., min_length=2, max_length=60, examples=["Main"])
    crop_production_system: str = Field(..., min_length=2, max_length=60, examples=["All (PS)"])

    # numeric fields: enforced type AND a realistic range
    area: float = Field(..., gt=0, le=5_000_000, description="Planted area in hectares", examples=[4.0])
    planting_year: int = Field(..., ge=1960, le=2035, examples=[2020])
    planting_month: int = Field(..., ge=1, le=12, examples=[3])
    harvest_month: int = Field(..., ge=1, le=12, examples=[10])


def known_categories():
    """Read the list of categories the model saw in training."""
    encoder = model.named_steps["prep"].named_transformers_["cat"]
    return {col: set(cats) for col, cats in zip(CAT_COLS, encoder.categories_)}


@app.post("/predict")
def predict(data: PredictionInput):
    row = pd.DataFrame([data.model_dump()])

    # reject categories the model has never seen, instead of silently guessing
    for col, allowed in known_categories().items():
        if row.loc[0, col] not in allowed:
            raise HTTPException(
                status_code=422,
                detail=f"Unknown {col}: '{row.loc[0, col]}'. It was not in the training data.",
            )

    prediction = float(model.predict(row)[0])
    return {"predicted_yield_t_per_ha": round(prediction, 3)}