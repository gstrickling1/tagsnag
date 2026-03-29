from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import plates, suggestions

app = FastAPI(title="TagSnag API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(plates.router)
app.include_router(suggestions.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
