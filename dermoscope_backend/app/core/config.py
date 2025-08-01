# config.py
# Ortam değişkenlerini (.env) okuma

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DB_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    GEMINI_API_KEY: str  # Gemini API anahtarı

    class Config:
        env_file = ".env"

settings = Settings()
