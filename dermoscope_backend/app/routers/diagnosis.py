# diagnosis.py
# Görsel yükleme + AI tanısı endpointleri

from fastapi import APIRouter

router = APIRouter()

@router.post("/diagnosis")
def diagnose():
    return {"msg": "AI tanısı"}
