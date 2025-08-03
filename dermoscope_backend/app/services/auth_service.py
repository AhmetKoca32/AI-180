# auth_service.py
# JWT ve kullanıcı doğrulama işlemleri

from sqlalchemy.orm import Session
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from ..models.user_model import User
from ..core.security import verify_password, get_password_hash, create_access_token, decode_access_token
from ..schemas.user_schema import UserCreate
from ..database.session import get_db
from datetime import timedelta

security = HTTPBearer()

def authenticate_user(db: Session, email: str, password: str):
    """Kullanıcı doğrulama işlemi"""
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_user(db: Session, user: UserCreate):
    """Yeni kullanıcı oluşturma"""
    # Email kontrolü
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu email adresi zaten kayıtlı"
        )
    
    # Username kontrolü
    db_user = db.query(User).filter(User.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu kullanıcı adı zaten kullanılıyor"
        )
    
    # Yeni kullanıcı oluştur
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password,
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
        age=user.age,
        gender=user.gender
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_user_access_token(user: User):
    """Kullanıcı için access token oluştur"""
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return access_token

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """JWT token'dan mevcut kullanıcıyı al"""
    try:
        token = credentials.credentials
        payload = decode_access_token(token)
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Geçersiz token",
                headers={"WWW-Authenticate": "Bearer"},
            )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Geçersiz token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Kullanıcı bulunamadı",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user
