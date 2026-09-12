import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "NutriLens API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    MONGODB_URI: str = "mongodb://localhost:27017/nutrilens_db"
    GEMINI_API_KEY: str = "YOUR_GEMINI_API_KEY_HERE"
    GEMINI_MODEL: str = "gemini-1.5-flash"
    JWT_SECRET: str = "your_jwt_secret_key_here"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"),
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
