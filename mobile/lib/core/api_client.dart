import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/food_item_model.dart';
import '../models/diary_model.dart';

class ApiClient {
  static const String liveProductionUrl = "https://nutrilens-rlek.onrender.com/api/v1";
  static String get defaultIp => "nutrilens-rlek.onrender.com";
  late final Dio _dio;
  String? token;

  ApiClient({String? serverIp}) {
    final baseUrl = _formatBaseUrl(serverIp ?? liveProductionUrl);
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  static String _formatBaseUrl(String input) {
    var formatted = input.trim();
    if (formatted.isEmpty) return liveProductionUrl;
    if (!formatted.startsWith("http://") && !formatted.startsWith("https://")) {
      formatted = "https://$formatted";
    }
    if (!formatted.endsWith("/api/v1")) {
      if (formatted.endsWith("/")) {
        formatted = "${formatted}api/v1";
      } else {
        formatted = "$formatted/api/v1";
      }
    }
    return formatted;
  }

  void updateBaseIp(String newIp) {
    _dio.options.baseUrl = _formatBaseUrl(newIp);
    debugPrint("[ApiClient] Updated baseUrl to: ${_dio.options.baseUrl}");
  }

  void setToken(String? userToken) {
    token = userToken;
    if (userToken != null && userToken.isNotEmpty) {
      _dio.options.headers["Authorization"] = "Bearer $userToken";
    } else {
      _dio.options.headers.remove("Authorization");
    }
  }

  // --- Auth API ---
  Future<Map<String, dynamic>?> register(String email, String password, String fullName) async {
    try {
      debugPrint("[ApiClient] POST /auth/register to ${_dio.options.baseUrl}");
      final response = await _dio.post("/auth/register", data: {
        "email": email,
        "password": password,
        "full_name": fullName,
      });
      return response.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final data = e.response?.data;
      debugPrint("[REGISTER ERROR] HTTP $status - Data: $data - Error: $e");
      if (data is Map && data.containsKey('detail')) {
        return {'error': data['detail'].toString()};
      }
      return {'error': 'Sunucuya bağlanılamadı. Lütfen sunucu bağlantınızı kontrol edin.'};
    } catch (e) {
      debugPrint("[REGISTER EXCEPTION] $e");
      return {'error': 'Kayıt işlemi sırasında bir hata oluştu.'};
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      debugPrint("[ApiClient] POST /auth/login to ${_dio.options.baseUrl}");
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });
      return response.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final data = e.response?.data;
      debugPrint("[LOGIN ERROR] HTTP $status - Data: $data - Error: $e");
      if (data is Map && data.containsKey('detail')) {
        return {'error': data['detail'].toString()};
      }
      return {'error': 'Sunucuya bağlanılamadı. Lütfen sunucu bağlantınızı kontrol edin.'};
    } catch (e) {
      debugPrint("[LOGIN EXCEPTION] $e");
      return {'error': 'Giriş işlemi sırasında bir hata oluştu.'};
    }
  }

  // --- Profile API ---
  Future<UserProfile?> getProfile() async {
    try {
      final response = await _dio.get("/users/profile");
      return UserProfile.fromJson(response.data);
    } catch (e) {
      debugPrint("GetProfile Error: $e");
      return null;
    }
  }

  Future<UserProfile?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put("/users/profile", data: profileData);
      return UserProfile.fromJson(response.data);
    } catch (e) {
      debugPrint("UpdateProfile Error: $e");
      return null;
    }
  }

  // --- Vision & Barcode API ---
  Future<FoodAnalysisResult?> analyzeFoodImageBytes(Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post("/vision/analyze", data: formData);
      return FoodAnalysisResult.fromJson(response.data);
    } catch (e) {
      debugPrint("AnalyzeFoodImage Error: $e");
      return null;
    }
  }

  Future<FoodAnalysisResult?> analyzeFoodBarcode(String barcode) async {
    try {
      final response = await _dio.get("/food/barcode/$barcode");
      return FoodAnalysisResult.fromJson(response.data);
    } catch (e) {
      debugPrint("AnalyzeFoodBarcode Error: $e");
      return null;
    }
  }

  // --- Diary API ---
  Future<DailyDiarySummary?> getDailyDiary([String? date]) async {
    try {
      final response = await _dio.get("/diary", queryParameters: date != null ? {"date": date} : null);
      return DailyDiarySummary.fromJson(response.data);
    } catch (e) {
      debugPrint("GetDailyDiary Error: $e");
      return null;
    }
  }

  Future<bool> saveMealEntry(FoodAnalysisResult food, String mealType, double multiplier, {String? date}) async {
    try {
      final response = await _dio.post("/diary/entry", data: {
        "meal_type": mealType,
        "food_name": food.foodName,
        "calories": (food.calories * multiplier).round(),
        "protein_g": food.proteinG * multiplier,
        "carbs_g": food.carbsG * multiplier,
        "fat_g": food.fatG * multiplier,
        "portion_multiplier": multiplier,
        "portion_g": food.portionG * multiplier,
        "ingredients": food.ingredients.map((i) => i.toJson()).toList(),
        "date": date,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("SaveMealEntry Error: $e");
      return false;
    }
  }
}
