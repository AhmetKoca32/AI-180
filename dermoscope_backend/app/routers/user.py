# user.py
# Kullanıcı bilgileri endpointleri

from fastapi import APIRouter

router = APIRouter()

@router.get("/user")
def get_user():
    return {"msg": "Kullanıcı bilgisi"}
