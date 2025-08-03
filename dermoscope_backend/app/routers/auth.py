# auth.py
# Kullanıcı kayıt/giriş işlemleri için endpointler

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database.session import get_db
from ..services.auth_service import authenticate_user, create_user, create_user_access_token
from ..schemas.user_schema import UserCreate, UserLogin, UserResponse, Token
from ..core.security import verify_password

router = APIRouter()

@router.post("/register", response_model=Token)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """Kullanıcı kayıt işlemi"""
    try:
        db_user = create_user(db, user)
        access_token = create_user_access_token(db_user)
        return {
            "access_token": access_token,
            "token_type": "bearer"
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Kayıt işlemi sırasında bir hata oluştu"
        )

@router.post("/login", response_model=Token)
def login_user(user_credentials: UserLogin, db: Session = Depends(get_db)):
    """Kullanıcı giriş işlemi"""
    user = authenticate_user(db, user_credentials.email, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Geçersiz email veya şifre",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_user_access_token(user)
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

@router.get("/me", response_model=UserResponse)
def get_current_user(db: Session = Depends(get_db)):
    """Mevcut kullanıcı bilgilerini getir"""
    # TODO: JWT token'dan kullanıcı bilgilerini al
    # Şimdilik test için sabit bir kullanıcı döndür
    return {
        "id": 1,
        "username": "test_user",
        "email": "test@example.com",
        "first_name": "Test",
        "last_name": "User"
    }
