import httpx
from app.core.database import get_database
from app.models.schemas import FoodAnalysisResult, FoodComponent

async def get_food_by_barcode(barcode: str) -> FoodAnalysisResult:
    """
    Open Food Facts API'sinden barkod ile gıda ürünü arar.
    Gıda dışı veya veritabanında bulunmayan barkodlarda is_food=False döner.
    """
    db = get_database()
    if db is not None:
        cached_food = await db["food_cache"].find_one({"barcode": barcode})
        if cached_food:
            return FoodAnalysisResult(
                food_name=cached_food.get("food_name", "Barkod Ürünü"),
                meal_type="Ara Öğün",
                calories=cached_food.get("calories", 200),
                protein_g=cached_food.get("protein_g", 5.0),
                carbs_g=cached_food.get("carbs_g", 25.0),
                fat_g=cached_food.get("fat_g", 8.0),
                portion_multiplier=1.0,
                portion_g=cached_food.get("portion_g", 100.0),
                source="barcode",
                is_food=True,
                ingredients=[
                    FoodComponent(
                        name=cached_food.get("food_name", "Ürün"),
                        portion_g=cached_food.get("portion_g", 100.0),
                        calories=cached_food.get("calories", 200)
                    )
                ]
            )

    # Open Food Facts API Sorgusu
    url = f"https://world.openfoodfacts.org/api/v0/product/{barcode}.json"
    try:
        async with httpx.AsyncClient(timeout=8.0) as client:
            response = await client.get(url)
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == 1:
                    product = data.get("product", {})
                    food_name = product.get("product_name_tr") or product.get("product_name") or "Ambalajlı Besin"
                    nutriments = product.get("nutriments", {})
                    
                    calories = int(nutriments.get("energy-kcal_100g", nutriments.get("energy-kcal", 180)))
                    protein_g = float(nutriments.get("proteins_100g", nutriments.get("proteins", 4.0)))
                    carbs_g = float(nutriments.get("carbohydrates_100g", nutriments.get("carbohydrates", 22.0)))
                    fat_g = float(nutriments.get("fat_100g", nutriments.get("fat", 7.0)))

                    result = FoodAnalysisResult(
                        food_name=food_name,
                        meal_type="Ara Öğün",
                        calories=calories,
                        protein_g=protein_g,
                        carbs_g=carbs_g,
                        fat_g=fat_g,
                        portion_multiplier=1.0,
                        portion_g=100.0,
                        source="barcode",
                        is_food=True,
                        ingredients=[
                            FoodComponent(name=food_name, portion_g=100.0, calories=calories, protein_g=protein_g, carbs_g=carbs_g, fat_g=fat_g)
                        ]
                    )

                    # MongoDB'ye önbellekle
                    if db is not None:
                        await db["food_cache"].update_one(
                            {"barcode": barcode},
                            {"$set": {
                                "barcode": barcode,
                                "food_name": food_name,
                                "calories": calories,
                                "protein_g": protein_g,
                                "carbs_g": carbs_g,
                                "fat_g": fat_g,
                                "portion_g": 100.0
                            }},
                            upsert=True
                        )

                    return result
    except Exception as e:
        print(f"[Barcode Service ERROR] {e}")

    # Gıda veritabanında bulunmayan veya elektronik / kozmetik vb. gıda dışı barkod
    return FoodAnalysisResult(
        food_name="Gıda Dışı Barkod Ürünü",
        meal_type="Ara Öğün",
        calories=0,
        protein_g=0.0,
        carbs_g=0.0,
        fat_g=0.0,
        portion_multiplier=1.0,
        portion_g=0.0,
        source="barcode",
        confidence_score=0.0,
        is_food=False,
        error_message=f"'{barcode}' kodlu barkod bir gıda/içecek ürününe ait değildir. Lütfen ambalajlı bir gıda ürünü barkodu okutun.",
        ingredients=[]
    )
