from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from model_api import predict
from app.routers.auth import router as auth_router
from app.routers.user import router as user_router
from app.routers.advice import router as advice_router
from app.database.base import Base
from app.database.session import engine

# Database tablolarını oluştur
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Dermoscope API", version="1.0.0")

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Güvenlik için production'da spesifik origin'ler belirtin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ana API router'ları
app.include_router(auth_router, prefix="/auth", tags=["authentication"])
app.include_router(user_router, prefix="/user", tags=["user"])
app.include_router(predict.router, prefix="/model_api", tags=["model"])
app.include_router(advice_router, tags=["advice"]) 
