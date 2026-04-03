import json
from pathlib import Path

_DATA_FILE = Path(__file__).parent.parent / "data" / "plate_styles.json"
_CACHE: dict | None = None


def _load() -> dict:
    global _CACHE
    if _CACHE is None:
        with open(_DATA_FILE) as f:
            _CACHE = json.load(f)
    return _CACHE


def get_plate_styles(state: str, vehicle_type: str = "car") -> dict:
    data = _load()
    state_data = data.get(state.upper())
    if not state_data:
        return {"supported": False, "styles": []}

    styles = state_data["styles"]
    if vehicle_type == "motorcycle":
        styles = [s for s in styles if s.get("motorcycle_max_length") is not None]

    return {"supported": True, "styles": styles}
