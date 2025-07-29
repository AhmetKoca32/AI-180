# advice.py
# Yaşam tarzı önerileri (LLM) endpointleri

from fastapi import APIRouter

router = APIRouter()

@router.post("/advice")
def get_advice():
    return {"msg": "LLM önerisi"}
