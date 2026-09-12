import unittest
from app.modules.users.calculator import PhysicalProfileInput, calculate_nutritional_targets
from app.modules.vision.service import _get_mock_food_result

class TestNutriLensBackend(unittest.TestCase):
    def test_calculator(self):
        profile = PhysicalProfileInput(
            age=24, height_cm=180, weight_kg=78, gender="male", goal="weight_loss", activity_level="moderate"
        )
        result = calculate_nutritional_targets(profile)
        self.assertEqual(result.bmr, 1790)
        self.assertEqual(result.tdee, 2774)
        self.assertEqual(result.daily_target_calories, 2374)

    def test_vision_mock(self):
        res = _get_mock_food_result()
        self.assertEqual(res.food_name, "Tavuklu Bulgur Pilavı")
        self.assertEqual(res.calories, 333)
        self.assertEqual(len(res.ingredients), 3)

if __name__ == "__main__":
    unittest.main()
