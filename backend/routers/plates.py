from fastapi import APIRouter

from models.schemas import PlateCheckRequest, PlateCheckResponse, StateRules
from scrapers.georgia import get_official_check_url
from services.scraper import check_plate
from services.validator import get_all_states, get_rules, validate_plate

router = APIRouter(prefix="/api", tags=["plates"])


@router.post("/check-plate", response_model=PlateCheckResponse)
async def check_plate_endpoint(req: PlateCheckRequest):
    plate = req.plate.upper().strip()
    is_valid, msg = validate_plate(plate, req.state)

    if not is_valid:
        return PlateCheckResponse(plate=plate, valid=False, status="invalid", message=msg)

    status = await check_plate(plate, req.state)

    official_url = get_official_check_url() if req.state == "GA" else ""

    messages = {
        "not_found": "Great news! This plate appears to be available. Visit your county tag office to claim it!",
        "assigned": "Sorry, this plate is already taken. Try a different combination!",
        "unknown": "Tap below to check availability on your state's official site.",
    }

    return PlateCheckResponse(
        plate=plate,
        valid=True,
        status=status,
        message=messages.get(status, ""),
        official_check_url=official_url,
    )


@router.get("/states")
async def list_states():
    return {"states": get_all_states()}


@router.get("/rules/{state}", response_model=StateRules)
async def get_state_rules(state: str):
    rules = get_rules(state)
    if not rules:
        return StateRules(
            state=state.upper(),
            max_length=0,
            allowed_chars="",
            notes=f"State {state.upper()} is not yet supported.",
        )
    return StateRules(
        state=state.upper(),
        max_length=rules["max_length"],
        allowed_chars=rules["allowed_chars"],
        notes=rules["notes"],
    )
