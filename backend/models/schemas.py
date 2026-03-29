from pydantic import BaseModel, Field


class PlateCheckRequest(BaseModel):
    plate: str = Field(..., description="The vanity plate text to check")
    state: str = Field(default="GA", description="State abbreviation")


class PlateCheckResponse(BaseModel):
    plate: str
    valid: bool
    status: str  # "not_found", "assigned", "unknown"
    message: str
    official_check_url: str = ""


class SuggestRequest(BaseModel):
    interest: str = Field(..., description="User's area of interest")
    state: str = Field(default="GA", description="State abbreviation")


class SuggestResponse(BaseModel):
    suggestions: list[str]


class ChatRefineRequest(BaseModel):
    interest: str
    message: str = Field(..., description="User's refinement message")
    history: list[dict] = Field(default_factory=list, description="Conversation history")
    state: str = Field(default="GA")


class ChatRefineResponse(BaseModel):
    suggestions: list[str]
    message: str


class StateRules(BaseModel):
    state: str
    max_length: int
    allowed_chars: str
    notes: str
