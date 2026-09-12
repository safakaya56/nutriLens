import httpx

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_full_system():
    print("--- 1. Testing Root Endpoint ---")
    res = httpx.get("http://127.0.0.1:8000/")
    print("Root response:", res.json())
    assert res.status_code == 200

    print("\n--- 2. Testing Auth Registration ---")
    reg_data = {"email": "muhammet@nutrilens.app", "password": "securepassword123", "full_name": "Muhammet"}
    res = httpx.post(f"{BASE_URL}/auth/register", json=reg_data)
    print("Register response:", res.status_code)
    token = res.json().get("access_token") if res.status_code == 200 else None

    if not token:
        print("User already registered, logging in...")
        res = httpx.post(f"{BASE_URL}/auth/login", json={"email": "muhammet@nutrilens.app", "password": "securepassword123"})
        token = res.json()["access_token"]

    print("Access token received successfully!")
    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- 3. Testing User Profile & Calculator ---")
    res = httpx.get(f"{BASE_URL}/users/profile", headers=headers)
    print("User Profile:", res.json())

    update_profile = {
        "age": 24, "height_cm": 180, "weight_kg": 78, "gender": "male",
        "goal": "weight_loss", "activity_level": "moderate"
    }
    res = httpx.put(f"{BASE_URL}/users/profile", json=update_profile, headers=headers)
    print("Updated Profile & Mifflin-St Jeor result:", res.json())
    assert res.json()["daily_target_calories"] == 2374

    print("\n--- 4. Testing Barcode Lookup ---")
    res = httpx.get(f"{BASE_URL}/food/barcode/8690504018001")
    print("Barcode analysis result:", res.json()["food_name"], "-", res.json()["calories"], "kcal")

    print("\n--- 5. Testing Adding Diary Entry ---")
    entry = {
        "meal_type": "Öğle",
        "food_name": "Tavuklu Bulgur Pilavı",
        "calories": 333,
        "protein_g": 38.0,
        "carbs_g": 22.0,
        "fat_g": 6.0,
        "portion_multiplier": 1.0,
        "portion_g": 240.0,
        "ingredients": [
            {"name": "Tavuk Göğsü", "portion_g": 120.0, "calories": 198},
            {"name": "Bulgur Pilavı", "portion_g": 80.0, "calories": 120},
            {"name": "Akdeniz Salata", "portion_g": 40.0, "calories": 15}
        ]
    }
    res = httpx.post(f"{BASE_URL}/diary/entry", json=entry, headers=headers)
    print("Diary Entry Result:", res.json())

    print("\n--- 6. Testing Daily Diary Summary ---")
    res = httpx.get(f"{BASE_URL}/diary", headers=headers)
    print("Daily Summary:", res.json()["consumed_calories"], "kcal consumed out of", res.json()["target_calories"], "kcal target.")

    print("\nALL SYSTEM E2E TESTS PASSED PERFECTLY!")

if __name__ == "__main__":
    test_full_system()
