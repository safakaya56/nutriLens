class UserProfile {
  final String email;
  final String fullName;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender;
  final String goal;
  final String activityLevel;
  final int bmr;
  final int tdee;
  final int dailyTargetCalories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  UserProfile({
    required this.email,
    required this.fullName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.goal,
    required this.activityLevel,
    required this.bmr,
    required this.tdee,
    required this.dailyTargetCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Muhammet',
      age: json['age'] ?? 24,
      heightCm: (json['height_cm'] ?? 180.0).toDouble(),
      weightKg: (json['weight_kg'] ?? 78.0).toDouble(),
      gender: json['gender'] ?? 'male',
      goal: json['goal'] ?? 'weight_loss',
      activityLevel: json['activity_level'] ?? 'moderate',
      bmr: json['bmr'] ?? 1750,
      tdee: json['tdee'] ?? 2450,
      dailyTargetCalories: json['daily_target_calories'] ?? 2100,
      proteinG: json['protein_g'] ?? 140,
      carbsG: json['carbs_g'] ?? 210,
      fatG: json['fat_g'] ?? 65,
    );
  }
}
