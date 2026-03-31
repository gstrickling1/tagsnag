from fastapi import APIRouter

from models.schemas import PlateCheckRequest, PlateCheckResponse, StateRules
from services.scraper import check_plate
from services.state_claim_info import get_claim_info
from services.state_urls import get_state_plate_url
from services.validator import get_all_states, get_rules, validate_plate

router = APIRouter(prefix="/api", tags=["plates"])


@router.post("/check-plate", response_model=PlateCheckResponse)
async def check_plate_endpoint(req: PlateCheckRequest):
    plate = req.plate.upper().strip()
    is_valid, msg = validate_plate(plate, req.state, req.vehicle_type)

    if not is_valid:
        return PlateCheckResponse(plate=plate, valid=False, status="invalid", message=msg)

    status = await check_plate(plate, req.state)

    official_url = get_state_plate_url(req.state)

    messages = {
        "not_found": "Great news! This plate appears to be available. Visit your county tag office to claim it!",
        "assigned": "Sorry, this plate is already taken. Try a different combination!",
        "unknown": "Check availability on your state's official site.",
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


@router.get("/claim-info/{state}")
async def get_state_claim_info(state: str):
    info = get_claim_info(state)
    if not info:
        return {"error": f"No claim info for state: {state}"}
    return {"state": state.upper(), **info}


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
