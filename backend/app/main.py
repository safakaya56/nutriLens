from datetime import datetime
from contextlib import asynccontextmanager
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.core.config import settings
from app.core.database import connect_to_mongo, close_mongo_connection, get_database
from app.core.security import get_password_hash, verify_password, create_access_token, decode_access_token
from app.models.schemas import (
    UserRegister, UserLogin, TokenResponse, UserProfileSchema,
    FoodAnalysisResult, DiaryEntryCreate, DailyDiarySummary
)
from app.modules.users.calculator import PhysicalProfileInput, calculate_nutritional_targets
from app.modules.vision.service import analyze_food_image
from app.modules.food.barcode import get_food_by_barcode

@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_to_mongo()
    yield
    await close_mongo_connection()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS izni (Mobil ve web erişimleri için)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

async def get_current_user_email(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Geçersiz veya süresi dolmuş token.")
    return payload["sub"]

# --- Health Check ---
@app.get("/")
def read_root():
    return {"message": "NutriLens API Hizmette!", "version": settings.VERSION}

# --- Auth Routes ---
@app.post("/api/v1/auth/register", response_model=TokenResponse)
async def register(user_data: UserRegister):
    db = get_database()
    if db is not None:
        existing = await db["users"].find_one({"email": user_data.email})
        if existing:
            raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kayıtlı.")
        
        hashed_password = get_password_hash(user_data.password)
        default_profile = PhysicalProfileInput(age=24, height_cm=180, weight_kg=78, gender="male", goal="weight_loss", activity_level="moderate")
        calc = calculate_nutritional_targets(default_profile)
        
        user_doc = {
            "email": user_data.email,
            "full_name": user_data.full_name,
            "hashed_password": hashed_password,
            "profile": {
                "age": default_profile.age,
                "height_cm": default_profile.height_cm,
                "weight_kg": default_profile.weight_kg,
                "gender": default_profile.gender,
                "goal": default_profile.goal,
                "activity_level": default_profile.activity_level,
                "bmr": calc.bmr,
                "tdee": calc.tdee,
                "daily_target_calories": calc.daily_target_calories,
                "protein_g": calc.protein_g,
                "carbs_g": calc.carbs_g,
                "fat_g": calc.fat_g
            }
        }
        await db["users"].insert_one(user_doc)
    
    token = create_access_token({"sub": user_data.email})
    return TokenResponse(access_token=token, user={"email": user_data.email, "full_name": user_data.full_name})

@app.post("/api/v1/auth/login", response_model=TokenResponse)
async def login(credentials: UserLogin):
    db = get_database()
    if db is not None:
        user = await db["users"].find_one({"email": credentials.email})
        if not user or not verify_password(credentials.password, user["hashed_password"]):
            raise HTTPException(status_code=400, detail="E-posta veya şifre hatalı.")
        
        token = create_access_token({"sub": user["email"]})
        return TokenResponse(
            access_token=token,
            user={"email": user["email"], "full_name": user.get("full_name", user["email"].split("@")[0].capitalize())}
        )
    
    # Fallback dev login
    token = create_access_token({"sub": credentials.email})
    return TokenResponse(access_token=token, user={"email": credentials.email, "full_name": credentials.email.split("@")[0].capitalize()})

# --- Profile & Calculator Routes ---
@app.get("/api/v1/users/profile", response_model=UserProfileSchema)
async def get_profile(email: str = Depends(get_current_user_email)):
    db = get_database()
    full_name = email.split("@")[0].capitalize()
    if db is not None:
        user = await db["users"].find_one({"email": email})
        if user:
            full_name = user.get("full_name", full_name)
            p = user.get("profile", {})
            return UserProfileSchema(
                email=user["email"],
                full_name=full_name,
                age=p.get("age", 24),
                height_cm=p.get("height_cm", 180.0),
                weight_kg=p.get("weight_kg", 78.0),
                gender=p.get("gender", "male"),
                goal=p.get("goal", "weight_loss"),
                activity_level=p.get("activity_level", "moderate"),
                bmr=p.get("bmr", 1750),
                tdee=p.get("tdee", 2450),
                daily_target_calories=p.get("daily_target_calories", 2100),
                protein_g=p.get("protein_g", 140),
                carbs_g=p.get("carbs_g", 210),
                fat_g=p.get("fat_g", 65)
            )
    return UserProfileSchema(email=email, full_name=full_name)

@app.put("/api/v1/users/profile", response_model=UserProfileSchema)
async def update_profile(profile_input: PhysicalProfileInput, email: str = Depends(get_current_user_email)):
    calc = calculate_nutritional_targets(profile_input)
    updated_profile_data = {
        "age": profile_input.age,
        "height_cm": profile_input.height_cm,
        "weight_kg": profile_input.weight_kg,
        "gender": profile_input.gender,
        "goal": profile_input.goal,
        "activity_level": profile_input.activity_level,
        "bmr": calc.bmr,
        "tdee": calc.tdee,
        "daily_target_calories": calc.daily_target_calories,
        "protein_g": calc.protein_g,
        "carbs_g": calc.carbs_g,
        "fat_g": calc.fat_g
    }
    
    full_name = email.split("@")[0].capitalize()
    db = get_database()
    if db is not None:
        user = await db["users"].find_one({"email": email})
        if user and "full_name" in user:
            full_name = user["full_name"]
        await db["users"].update_one(
            {"email": email},
            {"$set": {"profile": updated_profile_data}}
        )
    
    return UserProfileSchema(
        email=email,
        full_name=full_name,
        **updated_profile_data
    )

@app.post("/api/v1/users/calculate")
def calculate_target(profile_input: PhysicalProfileInput):
    return calculate_nutritional_targets(profile_input)

# --- Vision & Barcode Routes ---
@app.post("/api/v1/vision/analyze", response_model=FoodAnalysisResult)
async def analyze_image(file: UploadFile = File(...)):
    image_bytes = await file.read()
    content_type = file.content_type or "image/jpeg"
    result = await analyze_food_image(image_bytes, content_type)
    return result

@app.get("/api/v1/food/barcode/{code}", response_model=FoodAnalysisResult)
async def analyze_barcode(code: str):
    return await get_food_by_barcode(code)

# --- Diary Routes ---
@app.get("/api/v1/diary", response_model=DailyDiarySummary)
async def get_daily_diary(date: Optional[str] = None, email: str = Depends(get_current_user_email)):
    target_date = date or datetime.now().strftime("%Y-%m-%d")
    
    db = get_database()
    user_target_calories = 2100
    user_protein_target = 140
    user_carbs_target = 210
    user_fat_target = 65
    
    if db is not None:
        user = await db["users"].find_one({"email": email})
        if user and "profile" in user:
            user_target_calories = user["profile"].get("daily_target_calories", 2100)
            user_protein_target = user["profile"].get("protein_g", 140)
            user_carbs_target = user["profile"].get("carbs_g", 210)
            user_fat_target = user["profile"].get("fat_g", 65)

    meals_list = []
    if db is not None:
        cursor = db["daily_diaries"].find({"user_email": email, "date": target_date})
        async for doc in cursor:
            doc["_id"] = str(doc["_id"])
            meals_list.append(doc)

    consumed_cal = sum(m.get("calories", 0) for m in meals_list)
    consumed_p = sum(m.get("protein_g", 0) for m in meals_list)
    consumed_c = sum(m.get("carbs_g", 0) for m in meals_list)
    consumed_f = sum(m.get("fat_g", 0) for m in meals_list)

    return DailyDiarySummary(
        date=target_date,
        target_calories=user_target_calories,
        consumed_calories=consumed_cal,
        remaining_calories=max(0, user_target_calories - consumed_cal),
        protein_consumed=float(consumed_p),
        protein_target=float(user_protein_target),
        carbs_consumed=float(consumed_c),
        carbs_target=float(user_carbs_target),
        fat_consumed=float(consumed_f),
        fat_target=float(user_fat_target),
        meals=meals_list
    )

@app.post("/api/v1/diary/entry")
async def add_diary_entry(entry: DiaryEntryCreate, email: str = Depends(get_current_user_email)):
    target_date = entry.date or datetime.now().strftime("%Y-%m-%d")
    db = get_database()
    
    doc = {
        "user_email": email,
        "date": target_date,
        "meal_type": entry.meal_type,
        "food_name": entry.food_name,
        "calories": entry.calories,
        "protein_g": entry.protein_g,
        "carbs_g": entry.carbs_g,
        "fat_g": entry.fat_g,
        "portion_multiplier": entry.portion_multiplier,
        "portion_g": entry.portion_g,
        "ingredients": [i.model_dump() for i in entry.ingredients],
        "created_at": datetime.utcnow()
    }
    
    if db is not None:
        result = await db["daily_diaries"].insert_one(doc)
        doc["_id"] = str(result.inserted_id)

    return {"status": "success", "message": "Öğün veritabanına başarıyla kaydedildi!", "entry": doc}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

