from dotenv import load_dotenv

load_dotenv()

import json
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import plates, suggestions

app = FastAPI(title="TagSnag API", version="0.2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(plates.router)
app.include_router(suggestions.router)

# Load plate styles data at startup
_PLATE_STYLES_FILE = Path(__file__).parent / "data" / "plate_styles.json"
_PLATE_STYLES: dict = {}
try:
    with open(_PLATE_STYLES_FILE) as f:
        _PLATE_STYLES = json.load(f)
except Exception:
    pass


@app.get("/api/plate-styles/{state}")
async def get_plate_styles_endpoint(state: str, vehicle_type: str = "car"):
    state_data = _PLATE_STYLES.get(state.upper())
    if not state_data:
        return {"supported": False, "styles": []}
    styles = state_data["styles"]
    if vehicle_type == "motorcycle":
        styles = [s for s in styles if s.get("motorcycle_max_length") is not None]
    return {"supported": True, "styles": styles}


@app.get("/health")
async def health():
    return {"status": "ok", "version": "0.2.0"}
