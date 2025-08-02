from fastapi import APIRouter
from pydantic import BaseModel
from app.services.llm_advice import get_llm_advice

router = APIRouter()

class AdviceRequest(BaseModel):
    question: str

@router.post("/advice")
async def get_advice(body: AdviceRequest):
    response = get_llm_advice(body.question)
    return {"answer": response}