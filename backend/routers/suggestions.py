from fastapi import APIRouter

from models.schemas import (
    ChatRefineRequest,
    ChatRefineResponse,
    SuggestRequest,
    SuggestResponse,
)
from services.ai_service import chat_refine, generate_suggestions

router = APIRouter(prefix="/api", tags=["suggestions"])


@router.post("/suggest", response_model=SuggestResponse)
async def suggest_plates(req: SuggestRequest):
    suggestions = await generate_suggestions(req.interest, req.state, req.vehicle_type)
    return SuggestResponse(suggestions=suggestions)


@router.post("/chat-refine", response_model=ChatRefineResponse)
async def chat_refine_endpoint(req: ChatRefineRequest):
    suggestions, message = await chat_refine(
        req.interest, req.message, req.history, req.state, req.vehicle_type
    )
    return ChatRefineResponse(suggestions=suggestions, message=message)
