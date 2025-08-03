# user.py
# Kullanıcı bilgileri endpointleri

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database.session import get_db
from ..models.user_model import User
from ..schemas.user_schema import UserResponse, UserUpdate
from ..services.auth_service import get_current_user

router = APIRouter()

@router.get("/test")
def test_endpoint():
    """Test endpoint"""
    print("Backend: /user/test endpoint çağrıldı")
    return {"message": "User router çalışıyor!"}

@router.get("/profile", response_model=UserResponse)
def get_user_profile(db: Session = Depends(get_db)):
    """Kullanıcı profil bilgilerini getir (test için authentication olmadan)"""
    print("Backend: /user/profile endpoint çağrıldı")
    
    try:
        # Veritabanından ilk kullanıcıyı al (test için)
        user = db.query(User).first()
        
        if user:
            print(f"Backend: Veritabanından kullanıcı bulundu: {user.email}")
            response_data = {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "phone": user.phone,
                "age": user.age,
                "gender": user.gender
            }
        else:
            print("Backend: Veritabanında kullanıcı bulunamadı, test verisi döndürülüyor")
            # Veritabanında kullanıcı yoksa test verisi döndür
            response_data = {
                "id": 1,
                "username": "ahmet_koca",
                "email": "ahmet.koca@email.com",
                "first_name": "Ahmet",
                "last_name": "Koca",
                "phone": "+90 532 123 4567",
                "age": 32,
                "gender": "Erkek"
            }
        
        print(f"Backend: Döndürülen veri: {response_data}")
        return response_data
        
    except Exception as e:
        print(f"Backend: Hata oluştu: {e}")
        # Hata durumunda test verisi döndür
        return {
            "id": 1,
            "username": "ahmet_koca",
            "email": "ahmet.koca@email.com",
            "first_name": "Ahmet",
            "last_name": "Koca",
            "phone": "+90 532 123 4567",
            "age": 32,
            "gender": "Erkek"
        }

@router.put("/profile", response_model=UserResponse)
def update_user_profile(user_update: UserUpdate, db: Session = Depends(get_db)):
    """Kullanıcı profil bilgilerini güncelle (test için authentication olmadan)"""
    print("Backend: /user/profile PUT endpoint çağrıldı")
    print(f"Backend: Güncellenecek veri: {user_update}")
    
    try:
        # Veritabanından ilk kullanıcıyı al (test için)
        user = db.query(User).first()
        
        if user:
            print(f"Backend: Kullanıcı bulundu, güncelleniyor: {user.email}")
            
            # Güncellenecek alanları kontrol et
            if user_update.first_name is not None:
                user.first_name = user_update.first_name
            if user_update.last_name is not None:
                user.last_name = user_update.last_name
            if user_update.phone is not None:
                user.phone = user_update.phone
            if user_update.age is not None:
                user.age = user_update.age
            if user_update.gender is not None:
                user.gender = user_update.gender
            
            db.commit()
            db.refresh(user)
            
            response_data = {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "phone": user.phone,
                "age": user.age,
                "gender": user.gender
            }
            
            print(f"Backend: Kullanıcı güncellendi: {response_data}")
            return response_data
        else:
            print("Backend: Veritabanında kullanıcı bulunamadı, test verisi döndürülüyor")
            # Veritabanında kullanıcı yoksa test verisi döndür
            return {
                "id": 1,
                "username": "ahmet_koca",
                "email": "ahmet.koca@email.com",
                "first_name": user_update.first_name or "Ahmet",
                "last_name": user_update.last_name or "Koca",
                "phone": user_update.phone or "+90 532 123 4567",
                "age": user_update.age or 32,
                "gender": user_update.gender or "Erkek"
            }
            
    except Exception as e:
        print(f"Backend: Güncelleme hatası: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Profil güncellenirken bir hata oluştu"
        )

# JWT authentication gerektiren versiyonlar (gelecekte kullanılacak)
@router.get("/profile/secure", response_model=UserResponse)
def get_user_profile_secure(current_user: User = Depends(get_current_user)):
    """Kullanıcı profil bilgilerini getir (JWT authentication ile)"""
    return current_user

@router.put("/profile/secure", response_model=UserResponse)
def update_user_profile_secure(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Kullanıcı profil bilgilerini güncelle (JWT authentication ile)"""
    try:
        # Güncellenecek alanları kontrol et
        if user_update.first_name is not None:
            current_user.first_name = user_update.first_name
        if user_update.last_name is not None:
            current_user.last_name = user_update.last_name
        if user_update.phone is not None:
            current_user.phone = user_update.phone
        if user_update.age is not None:
            current_user.age = user_update.age
        if user_update.gender is not None:
            current_user.gender = user_update.gender
        
        db.commit()
        db.refresh(current_user)
        
        return current_user
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Profil güncellenirken bir hata oluştu"
        )

@router.get("/user")
def get_user():
    return {"msg": "Kullanıcı bilgisi"}

@router.post("/create-test-user")
def create_test_user(db: Session = Depends(get_db)):
    """Test kullanıcısı oluştur"""
    print("Backend: Test kullanıcısı oluşturuluyor...")
    
    try:
        # Önce mevcut test kullanıcısını kontrol et
        existing_user = db.query(User).filter(User.email == "ahmet.koca@email.com").first()
        
        if existing_user:
            print(f"Backend: Test kullanıcısı zaten mevcut: {existing_user.email}")
            return {
                "message": "Test kullanıcısı zaten mevcut",
                "user": {
                    "id": existing_user.id,
                    "username": existing_user.username,
                    "email": existing_user.email,
                    "first_name": existing_user.first_name,
                    "last_name": existing_user.last_name,
                    "phone": existing_user.phone,
                    "age": existing_user.age,
                    "gender": existing_user.gender
                }
            }
        
        # Yeni test kullanıcısı oluştur
        from ..core.security import get_password_hash
        
        test_user = User(
            username="ahmet_koca",
            email="ahmet.koca@email.com",
            hashed_password=get_password_hash("test123"),
            first_name="Ahmet",
            last_name="Koca",
            phone="+90 532 123 4567",
            age=32,
            gender="Erkek"
        )
        
        db.add(test_user)
        db.commit()
        db.refresh(test_user)
        
        print(f"Backend: Test kullanıcısı oluşturuldu: {test_user.email}")
        
        return {
            "message": "Test kullanıcısı başarıyla oluşturuldu",
            "user": {
                "id": test_user.id,
                "username": test_user.username,
                "email": test_user.email,
                "first_name": test_user.first_name,
                "last_name": test_user.last_name,
                "phone": test_user.phone,
                "age": test_user.age,
                "gender": test_user.gender
            }
        }
        
    except Exception as e:
        print(f"Backend: Test kullanıcısı oluşturma hatası: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Test kullanıcısı oluşturulurken bir hata oluştu"
        )
