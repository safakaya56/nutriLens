from app.modules.users.calculator import PhysicalProfileInput, calculate_nutritional_targets

def test_calculator_male_weight_loss():
    profile = PhysicalProfileInput(
        age=24,
        height_cm=180,
        weight_kg=78,
        gender="male",
        goal="weight_loss",
        activity_level="moderate"
    )
    result = calculate_nutritional_targets(profile)
    
    # BMR: (10*78) + (6.25*180) - (5*24) + 5 = 780 + 1125 - 120 + 5 = 1790
    assert result.bmr == 1790
    # TDEE: 1790 * 1.55 = 2774.5 -> 2775
    assert result.tdee == 2775
    # Target: 2775 - 400 = 2375
    assert result.daily_target_calories == 2375
    # Protein: 2375 * 0.30 / 4 = 178g
    assert result.protein_g > 100

def test_calculator_female_maintain():
    profile = PhysicalProfileInput(
        age=30,
        height_cm=165,
        weight_kg=60,
        gender="female",
        goal="maintain",
        activity_level="light"
    )
    result = calculate_nutritional_targets(profile)
    
    # BMR: (10*60) + (6.25*165) - (5*30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25 -> 1320
    assert result.bmr == 1320
    assert result.tdee == int(round(1320 * 1.375))
    assert result.daily_target_calories == result.tdee
