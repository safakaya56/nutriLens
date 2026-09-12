from typing import List, Optional
from pydantic import BaseModel, Field

# --- User & Auth Schemas ---
class UserRegister(BaseModel):
    email: str
    password: str
    full_name: str = "Muhammet"

class UserLogin(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

class UserProfileSchema(BaseModel):
    email: str
    full_name: str
    age: int = 24
    height_cm: float = 180.0
    weight_kg: float = 78.0
    gender: str = "male"
    goal: str = "weight_loss"
    activity_level: str = "moderate"
    bmr: int = 1750
    tdee: int = 2450
    daily_target_calories: int = 2100
    protein_g: int = 140
    carbs_g: int = 210
    fat_g: int = 65

# --- Food & Vision Schemas ---
class FoodComponent(BaseModel):
    name: str
    portion_g: float
    calories: int
    protein_g: float = 0
    carbs_g: float = 0
    fat_g: float = 0

class FoodAnalysisResult(BaseModel):
    food_name: str
    meal_type: str = "Öğle"
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float
    portion_multiplier: float = 1.0
    portion_g: float = 240.0
    source: str = "camera" # 'camera' veya 'barcode'
    confidence_score: Optional[float] = 0.95
    analysis_notes: Optional[str] = None
    is_food: bool = True
    error_message: Optional[str] = None
    ingredients: List[FoodComponent] = []

# --- Diary Schemas ---
class DiaryEntryCreate(BaseModel):
    meal_type: str  # "Kahvaltı", "Öğle", "Akşam", "Ara Öğün"
    food_name: str
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float
    portion_multiplier: float = 1.0
    portion_g: float = 240.0
    ingredients: List[FoodComponent] = []
    date: Optional[str] = None # YYYY-MM-DD

class DailyDiarySummary(BaseModel):
    date: str
    target_calories: int
    consumed_calories: int
    remaining_calories: int
    protein_consumed: float
    protein_target: float
    carbs_consumed: float
    carbs_target: float
    fat_consumed: float
    fat_target: float
    meals: List[dict]
