from pathlib import Path

import joblib
import pandas as pd
from sklearn.base import clone

BASE_DIR = Path(__file__).parent
MODEL_PATH = BASE_DIR / "best_model.pkl"
TRAIN_DATA_PATH = BASE_DIR / "training_data.csv.gz"

CAT_COLS = ["country", "product", "season_name", "crop_production_system"]
NUM_COLS = ["area", "planting_year", "planting_month", "harvest_month"]
FEATURES = CAT_COLS + NUM_COLS
TARGET = "yield"


class RetrainError(ValueError):
    """Raised when the uploaded data cannot be used for retraining."""


def clean_new_rows(new: pd.DataFrame) -> pd.DataFrame:
    """Keep only valid rows, using the same ranges as the /predict input checks."""
    missing = [c for c in FEATURES + [TARGET] if c not in new.columns]
    if missing:
        raise RetrainError(f"Missing columns: {missing}")

    new = new[FEATURES + [TARGET]].copy()
    for col in NUM_COLS + [TARGET]:
        new[col] = pd.to_numeric(new[col], errors="coerce")
    new = new.dropna()

    ok = (
        (new["area"] > 0) & (new["area"] <= 5_000_000)
        & new["planting_year"].between(1960, 2035)
        & new["planting_month"].between(1, 12)
        & new["harvest_month"].between(1, 12)
        & (new[TARGET] > 0) & (new[TARGET] <= 500)
    )
    new = new[ok]
    if new.empty:
        raise RetrainError("No valid rows found in the file.")
    return new


def retrain_model(current_model, new_df: pd.DataFrame):
    """Refit a fresh copy of the pipeline on the original data plus the new rows.

    Returns (new_model, summary). The caller decides to start using new_model.
    """
    n_uploaded = len(new_df)
    new = clean_new_rows(new_df)

    original = pd.read_csv(TRAIN_DATA_PATH)
    combined = pd.concat([original, new], ignore_index=True)

    new_model = clone(current_model)
    new_model.fit(combined[FEATURES], combined[TARGET])

    joblib.dump(new_model, MODEL_PATH, compress=3)
    combined.to_csv(TRAIN_DATA_PATH, index=False)

    summary = {
        "rows_uploaded": n_uploaded,
        "new_rows_used": len(new),
        "rows_rejected": n_uploaded - len(new),
        "total_training_rows": len(combined),
    }
    return new_model, summary