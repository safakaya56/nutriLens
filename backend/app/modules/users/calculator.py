from pydantic import BaseModel, Field

class PhysicalProfileInput(BaseModel):
    age: int = Field(..., ge=10, le=120)
    height_cm: float = Field(..., ge=50, le=250)
    weight_kg: float = Field(..., ge=30, le=300)
    gender: str = Field(default="male", description="male veya female")
    goal: str = Field(default="weight_loss", description="weight_loss, maintain, weight_gain")
    activity_level: str = Field(default="moderate", description="sedentary, light, moderate, active")

class CalorieCalculationResult(BaseModel):
    bmr: int
    tdee: int
    daily_target_calories: int
    protein_g: int
    carbs_g: int
    fat_g: int

def calculate_nutritional_targets(profile: PhysicalProfileInput) -> CalorieCalculationResult:
    """
    Mifflin-St Jeor denklemi ile BMR ve TDEE hesaplama.
    """
    # 1. BMR (Bazal Metabolizma Hızı)
    if profile.gender.lower() in ["female", "kadın", "kadin"]:
        bmr = (10 * profile.weight_kg) + (6.25 * profile.height_cm) - (5 * profile.age) - 161
    else:
        bmr = (10 * profile.weight_kg) + (6.25 * profile.height_cm) - (5 * profile.age) + 5
    
    bmr = int(round(bmr))

    # 2. Aktivite Çarpanı (PAL Factor)
    activity_map = {
        "sedentary": 1.2,      # Masa Başı
        "light": 1.375,        # Hafif Aktif
        "moderate": 1.55,      # Orta Aktif
        "active": 1.725,       # Çok Hareketli
    }
    
    activity_factor = activity_map.get(profile.activity_level.lower(), 1.55)
    tdee = int(round(bmr * activity_factor))

    # 3. Hedefe Göre Kalori Düzenleme
    goal_key = profile.goal.lower()
    if goal_key in ["weight_loss", "kilo_ver", "kilo ver"]:
        daily_target = max(1200, tdee - 400)
    elif goal_key in ["weight_gain", "kas_kazan", "kilo al", "kilo_al"]:
        daily_target = tdee + 350
    else:
        daily_target = tdee

    # 4. Makro Dağılımı (%30 Protein, %45 Karbonhidrat, %25 Yağ)
    protein_g = int(round((daily_target * 0.30) / 4))
    carbs_g = int(round((daily_target * 0.45) / 4))
    fat_g = int(round((daily_target * 0.25) / 9))

    return CalorieCalculationResult(
        bmr=bmr,
        tdee=tdee,
        daily_target_calories=daily_target,
        protein_g=protein_g,
        carbs_g=carbs_g,
        fat_g=fat_g
    )
