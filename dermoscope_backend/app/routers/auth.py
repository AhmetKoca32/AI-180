# auth.py
# Kullanıcı kayıt/giriş işlemleri için endpointler

from fastapi import APIRouter

router = APIRouter()

@router.post("/register")
def register_user():
    return {"msg": "Kullanıcı kaydı"}

@router.post("/login")
def login_user():
    return {"msg": "Kullanıcı girişi"}
