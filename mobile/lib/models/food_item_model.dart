class FoodComponent {
  final String name;
  final double portionG;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  FoodComponent({
    required this.name,
    required this.portionG,
    required this.calories,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  factory FoodComponent.fromJson(Map<String, dynamic> json) {
    return FoodComponent(
      name: json['name'] ?? 'Bileşen',
      portionG: (json['portion_g'] ?? 100).toDouble(),
      calories: (json['calories'] ?? 0).toInt(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion_g': portionG,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
    };
  }
}

class FoodAnalysisResult {
  final String foodName;
  final String mealType;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double portionMultiplier;
  final double portionG;
  final String source;
  final bool isFood;
  final String? errorMessage;
  final List<FoodComponent> ingredients;

  FoodAnalysisResult({
    required this.foodName,
    this.mealType = 'Öğle',
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.portionMultiplier = 1.0,
    this.portionG = 240.0,
    this.source = 'camera',
    this.isFood = true,
    this.errorMessage,
    required this.ingredients,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] ?? 'Tespit Edilen Yemek',
      mealType: json['meal_type'] ?? 'Öğle',
      calories: (json['calories'] ?? 0).toInt(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      portionMultiplier: (json['portion_multiplier'] ?? 1.0).toDouble(),
      portionG: (json['portion_g'] ?? 240.0).toDouble(),
      source: json['source'] ?? 'camera',
      isFood: json['is_food'] ?? true,
      errorMessage: json['error_message'],
      ingredients: (json['ingredients'] as List? ?? [])
          .map((i) => FoodComponent.fromJson(i))
          .toList(),
    );
  }

  FoodAnalysisResult copyWith({
    String? foodName,
    String? mealType,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? portionMultiplier,
    double? portionG,
    String? source,
    bool? isFood,
    String? errorMessage,
    List<FoodComponent>? ingredients,
  }) {
    return FoodAnalysisResult(
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      portionG: portionG ?? this.portionG,
      source: source ?? this.source,
      isFood: isFood ?? this.isFood,
      errorMessage: errorMessage ?? this.errorMessage,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
