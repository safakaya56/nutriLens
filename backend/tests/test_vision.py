import pytest
from app.modules.vision.service import _get_mock_food_result

def test_mock_vision_result():
    result = _get_mock_food_result()
    assert result.food_name == "Tavuklu Bulgur Pilavı"
    assert result.calories == 333
    assert result.protein_g == 38.0
    assert result.carbs_g == 22.0
    assert result.fat_g == 6.0
    assert len(result.ingredients) == 3
    assert result.ingredients[0].name == "Tavuk Göğsü"
