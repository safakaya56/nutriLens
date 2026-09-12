import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';
import '../models/diary_model.dart';
import '../models/food_item_model.dart';

class AppState extends ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  UserProfile? _userProfile;
  DailyDiarySummary? _dailySummary;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  UserProfile? get userProfile => _userProfile;
  DailyDiarySummary? get dailySummary => _dailySummary;
  String get selectedDate => _selectedDate;

  String _serverIp = "https://nutrilens-rlek.onrender.com";
  String get serverIp => _serverIp;

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    final savedIp = prefs.getString('server_ip');
    if (savedIp != null && savedIp.isNotEmpty && !savedIp.startsWith("192.168.") && savedIp != "localhost") {
      _serverIp = savedIp;
    } else {
      _serverIp = "https://nutrilens-rlek.onrender.com";
      await prefs.setString('server_ip', _serverIp);
    }
    apiClient.updateBaseIp(_serverIp);

    _token = prefs.getString('user_token');
    
    if (_token != null && _token!.isNotEmpty) {
      apiClient.setToken(_token);
      _userProfile = await apiClient.getProfile();
      if (_userProfile != null) {
        _isLoggedIn = true;
        await refreshDailySummary();
      } else {
        _isLoggedIn = false;
        _token = null;
        await prefs.remove('user_token');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
  }

  Future<void> updateServerIp(String newIp) async {
    _serverIp = newIp.trim();
    apiClient.updateBaseIp(_serverIp);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _serverIp);
    notifyListeners();
  }

  String? _authError;
  String? get authError => _authError;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    final result = await apiClient.login(email, password);
    if (result != null && result.containsKey('access_token')) {
      _token = result['access_token'];
      apiClient.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _token!);

      _userProfile = await apiClient.getProfile();
      _isLoggedIn = true;
      await refreshDailySummary();

      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result != null && result.containsKey('error')) {
      _authError = result['error'].toString();
    } else {
      _authError = "Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    final result = await apiClient.register(email, password, fullName);
    if (result != null && result.containsKey('access_token')) {
      _token = result['access_token'];
      apiClient.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _token!);

      _userProfile = await apiClient.getProfile();
      _isLoggedIn = true;
      await refreshDailySummary();

      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result != null && result.containsKey('error')) {
      _authError = result['error'].toString();
    } else {
      _authError = "Kayıt işlemi başarısız.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    _token = null;
    _isLoggedIn = false;
    _userProfile = null;
    _dailySummary = null;
    apiClient.setToken(null);
    notifyListeners();
  }

  // --- Water Tracking ---
  int _waterMl = 0;
  int _waterTargetMl = 2500;
  int get waterMl => _waterMl;
  int get waterTargetMl => _waterTargetMl;

  // --- Weekly Summary ---
  List<Map<String, dynamic>> _weeklyData = [];
  bool _isWeeklyLoading = false;
  List<Map<String, dynamic>> get weeklyData => _weeklyData;
  bool get isWeeklyLoading => _isWeeklyLoading;

  // --- Theme Mode ---
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  // --- Meal Reminders ---
  bool _mealRemindersEnabled = true;
  bool get mealRemindersEnabled => _mealRemindersEnabled;

  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 30);

  TimeOfDay get breakfastTime => _breakfastTime;
  TimeOfDay get lunchTime => _lunchTime;
  TimeOfDay get dinnerTime => _dinnerTime;

  Future<void> setBreakfastTime(TimeOfDay time) async {
    _breakfastTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('breakfast_time', '${time.hour}:${time.minute}');
  }

  Future<void> setLunchTime(TimeOfDay time) async {
    _lunchTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lunch_time', '${time.hour}:${time.minute}');
  }

  Future<void> setDinnerTime(TimeOfDay time) async {
    _dinnerTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dinner_time', '${time.hour}:${time.minute}');
  }

  // --- Network Error State ---
  String? _networkError;
  String? get networkError => _networkError;

  void clearNetworkError() {
    _networkError = null;
    notifyListeners();
  }

  Future<void> _loadWaterForSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    _waterMl = prefs.getInt('water_ml_$_selectedDate') ?? 0;
    _waterTargetMl = prefs.getInt('water_target_ml') ?? 2500;
    notifyListeners();
  }

  Future<void> addWater(int ml) async {
    _waterMl = (_waterMl + ml).clamp(0, 10000);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_ml_$_selectedDate', _waterMl);
  }

  Future<void> removeWater(int ml) async {
    _waterMl = (_waterMl - ml).clamp(0, 10000);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_ml_$_selectedDate', _waterMl);
  }

  Future<void> resetWater() async {
    _waterMl = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_ml_$_selectedDate', 0);
  }

  Future<void> _loadReminderPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _mealRemindersEnabled = prefs.getBool('meal_reminders_enabled') ?? true;

    final themeStr = prefs.getString('theme_mode');
    if (themeStr != null) {
      if (themeStr == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeStr == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    }

    final bStr = prefs.getString('breakfast_time');
    if (bStr != null && bStr.contains(':')) {
      final p = bStr.split(':');
      _breakfastTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }

    final lStr = prefs.getString('lunch_time');
    if (lStr != null && lStr.contains(':')) {
      final p = lStr.split(':');
      _lunchTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }

    final dStr = prefs.getString('dinner_time');
    if (dStr != null && dStr.contains(':')) {
      final p = dStr.split(':');
      _dinnerTime = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }

    notifyListeners();
  }

  Future<void> setMealRemindersEnabled(bool enabled) async {
    _mealRemindersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_reminders_enabled', enabled);
  }

  Future<void> loadWeeklySummary() async {
    _isWeeklyLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> result = [];
      final now = DateTime.tryParse(_selectedDate) ?? DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(d);
        final summary = await apiClient.getDailyDiary(dateStr);
        result.add({
          "date": dateStr,
          "dayName": DateFormat('EEE', 'tr_TR').format(d),
          "calories": summary?.consumedCalories ?? 0,
          "target": summary?.targetCalories ?? 2000,
          "protein": summary?.proteinConsumed ?? 0.0,
          "carbs": summary?.carbsConsumed ?? 0.0,
          "fat": summary?.fatConsumed ?? 0.0,
        });
      }
      _weeklyData = result;
    } catch (e) {
      debugPrint("Weekly summary load error: $e");
    } finally {
      _isWeeklyLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedDate(String dateStr) async {
    _selectedDate = dateStr;
    _dailySummary = null;
    notifyListeners();
    await _loadWaterForSelectedDate();
    await refreshDailySummary();
  }

  Future<void> refreshDailySummary() async {
    _networkError = null;
    _dailySummary = await apiClient.getDailyDiary(_selectedDate);
    await _loadWaterForSelectedDate();
    await _loadReminderPrefs();
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();

    final updated = await apiClient.updateProfile(profileData);
    if (updated != null) {
      _userProfile = updated;
      await refreshDailySummary();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _networkError = "Profil güncellenemedi. İnternet bağlantınızı kontrol edin.";
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> saveMeal(FoodAnalysisResult food, String mealType, double multiplier) async {
    final success = await apiClient.saveMealEntry(food, mealType, multiplier, date: _selectedDate);
    if (success) {
      await refreshDailySummary();
    } else {
      _networkError = "Yemek kaydedilemedi. Bağlantınızı kontrol edin.";
      notifyListeners();
    }
    return success;
  }
}

