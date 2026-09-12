class MealItem {
  final String id;
  final String mealType;
  final String foodName;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool completed;

  MealItem({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.completed = true,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['_id'] ?? json['id'] ?? '',
      mealType: json['meal_type'] ?? 'Öğle',
      foodName: json['food_name'] ?? 'Yemek',
      calories: (json['calories'] ?? 0).toInt(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      completed: json['completed'] ?? true,
    );
  }
}

class DailyDiarySummary {
  final String date;
  final int targetCalories;
  final int consumedCalories;
  final int remainingCalories;
  final double proteinConsumed;
  final double proteinTarget;
  final double carbsConsumed;
  final double carbsTarget;
  final double fatConsumed;
  final double fatTarget;
  final List<MealItem> meals;

  DailyDiarySummary({
    required this.date,
    required this.targetCalories,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.meals,
  });

  factory DailyDiarySummary.fromJson(Map<String, dynamic> json) {
    return DailyDiarySummary(
      date: json['date'] ?? '',
      targetCalories: json['target_calories'] ?? 2100,
      consumedCalories: json['consumed_calories'] ?? 620,
      remainingCalories: json['remaining_calories'] ?? 1480,
      proteinConsumed: (json['protein_consumed'] ?? 45.0).toDouble(),
      proteinTarget: (json['protein_target'] ?? 140.0).toDouble(),
      carbsConsumed: (json['carbs_consumed'] ?? 60.0).toDouble(),
      carbsTarget: (json['carbs_target'] ?? 210.0).toDouble(),
      fatConsumed: (json['fat_consumed'] ?? 20.0).toDouble(),
      fatTarget: (json['fat_target'] ?? 65.0).toDouble(),
      meals: (json['meals'] as List? ?? [])
          .map((m) => MealItem.fromJson(m))
          .toList(),
    );
  }
}
