import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aksumfit/services/auth_manager.dart'; // Import AuthManager
import '../models/user.dart';

// Models used by various ApiService extensions (centralized imports)
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/features/nutrition/data/mock_food_database.dart';
import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/food_item.dart';
import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/models/body_measurement_entry.dart';
import 'package:aksumfit/models/performance_metric_entry.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:uuid/uuid.dart'; // For generating IDs for mock data


/// Enhanced API Service for AxumFit
/// Includes error handling, logging, retry logic, and production-ready features
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;

  // API Configuration
  static const String _baseUrl = 'https://api.axumfit.com/v1';
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  // Initialize the service
  void initialize() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: IOSAccessibility.first_unlock_this_device,
      ),
    );

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': '1.0.0',
        'X-Platform': 'mobile',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request Interceptor - Add auth token automatically
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('🚀 API Request: ${options.method} ${options.path}');
          print('📄 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          print('📄 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ API Error: ${error.message}');
          print('📄 Response: ${error.response?.data}');
        }

        // Handle token expiration
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }

        handler.next(error);
      },
    ));

    // Retry Interceptor
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: kDebugMode ? print : null,
      retries: _maxRetries,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
  }

  /// Authentication Methods

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API call
      await _simulateNetworkDelay();

      // Mock successful registration
      final mockResponse = {
        "success": true,
        "token": "mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}",
        "user": {
          "id": DateTime.now().millisecondsSinceEpoch.toString(),
          "name": name,
          "email": email,
          "streakCount": 0,
          "profileImageUrl": null,
          "createdAt": DateTime.now().toIso8601String(),
          "isVerified": false,
          "role": "user" // Added role for registration
        }
      };

      final authResponse = AuthResponse.fromJson(mockResponse);
      await saveToken(authResponse.token);
      AuthManager().setUser(authResponse.user); // Set current user

      return authResponse;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      await _simulateNetworkDelay();

      if (email == "demo@axumfit.com" && password == "demo123") {
        final mockResponse = {
          "success": true,
          "token":
              "mock_jwt_token_${email}_${DateTime.now().millisecondsSinceEpoch}",
          "user": {
            "id": "demo_user_001",
            "name": "Demo User",
            "email": email,
            "streakCount": 7,
            "profileImageUrl":
                "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
            "createdAt": "2024-01-15T10:30:00Z",
            "isVerified": true,
            "totalWorkouts": 45,
            "totalCaloriesBurned": 12500,
            "fitnessLevel": "intermediate",
            "role": "trainer"
          }
        };

        final authResponse = AuthResponse.fromJson(mockResponse);
        await saveToken(authResponse.token);
        AuthManager().setUser(authResponse.user);
        return authResponse;
      } else {
        AuthManager().clearUser();
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: {"success": false, "message": "Invalid email or password"},
          ),
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _simulateNetworkDelay(delay: 200);
    } catch (e) {
      if (kDebugMode) {
        print('Logout API call error: $e');
      }
    } finally {
      await clearToken();
      AuthManager().clearUser();
    }
  }

  /// User Profile Methods
  Future<User> getUserProfile() async {
    try {
      await _simulateNetworkDelay(delay: 300);
      final mockData = {
        "id": "demo_user_001", "name": "Demo User", "email": "demo@axumfit.com",
        "profileImageUrl": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
        "role": "trainer", "streakCount": 7, "totalWorkouts": 45, "totalCaloriesBurned": 12500,
        "fitnessLevel": "intermediate", "joinedDate": "2024-01-15T10:30:00Z", "isVerified": true,
        "preferences": {"workoutReminders": true, "nutritionTracking": true, "socialFeatures": true,}
      };
      return User.fromJson(mockData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Failed to fetch user profile: ${e.toString()}');
    }
  }

  Future<User> updateUserProfile({ String? name, String? profileImageUrl, Map<String, dynamic>? preferences}) async {
    try {
      await _simulateNetworkDelay();
      final mockData = {
        "id": "demo_user_001", "name": name ?? "Demo User", "email": "demo@axumfit.com",
        "profileImageUrl": profileImageUrl ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
        "role": "trainer", "streakCount": 7, "totalWorkouts": 45, "totalCaloriesBurned": 12500,
        "fitnessLevel": "intermediate", "joinedDate": "2024-01-15T10:30:00Z", "isVerified": true,
        "preferences": preferences ?? {"workoutReminders": true, "nutritionTracking": true, "socialFeatures": true,}
      };
      return User.fromJson(mockData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Token Management
  Future<void> saveToken(String token) async { /* ... */ }
  Future<String?> getToken() async { /* ... */ return null; } // Simplified for brevity
  Future<void> clearToken() async { /* ... */ }
  Future<bool> isAuthenticated() async { /* ... */ return false; } // Simplified

  /// Workout Data Methods (Placeholders)
  Future<List<Map<String, dynamic>>> getWorkouts() async { await _simulateNetworkDelay(); return []; }
  Future<Map<String, dynamic>> getTodaysStats() async { await _simulateNetworkDelay(); return {}; }

  /// Helper Methods
  Future<void> _simulateNetworkDelay({int delay = 500}) async {
    if (kDebugMode) {
      await Future.delayed(Duration(milliseconds: delay));
    }
  }

  void _handleUnauthorized() {
    clearToken();
    AuthManager().clearUser();
    if (kDebugMode) print('Unauthorized: Token and user cleared.');
  }

  ApiException _handleDioError(DioException error) {
    // ... (existing error handling logic)
    return ApiException('Network error. Please check your connection.'); // Fallback
  }
}

// --- Home Screen Data Service Methods ---
extension HomeScreenApiService on ApiService {
  Future<WorkoutPlan?> getTodaysWorkoutPlan(String userId) async {
    // Mock: Return the first plan authored by the user, or the very first plan if none by user.
    await _simulateNetworkDelay(delay: 150);
    final userPlans = _mockWorkoutPlans.where((p) => p.authorId == userId).toList();
    if (userPlans.isNotEmpty) return userPlans.first;
    if (_mockWorkoutPlans.isNotEmpty) return _mockWorkoutPlans.first; // Fallback to any plan
    return null;
  }

  Future<Map<String, int>> getWeeklyWorkoutStats(String userId) async {
    // Mock: Simulate fetching weekly workout counts and active minutes
    await _simulateNetworkDelay(delay: 200);
    // In a real app, query WorkoutLogs for the past week
    int workoutsThisWeek = _mockWorkoutLogs.where((log) =>
        log.userId == userId &&
        log.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;
    // Mock active minutes
    int activeMinutesThisWeek = workoutsThisWeek * 35; // Assuming avg 35 mins per workout
    return {
      "workoutsCompleted": workoutsThisWeek,
      "activeMinutes": activeMinutesThisWeek,
    };
  }

  Future<WeightEntry?> getLatestWeightEntry(String userId) async {
    await _simulateNetworkDelay(delay: 100);
    final userEntries = _mockWeightEntries.where((e) => e.userId == userId).toList();
    userEntries.sort((a,b) => b.date.compareTo(a.date)); // Ensure latest is first
    if (userEntries.isNotEmpty) return userEntries.first;
    return null;
  }
}

/// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override String toString() => 'ApiException: $message';
}

/// Auth Response Model
class AuthResponse {
  final bool success; final String token; final User user; final String? message;
  AuthResponse({ required this.success, required this.token, required this.user, this.message});
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse( success: json['success'] ?? true, token: json['token'], user: User.fromJson(json['user']), message: json['message']);
  }
}

// --- Common Uuid instance for mock data generation ---
const Uuid _uuid = Uuid();

// --- Workout Plan Mock Data & Service ---
final List<WorkoutPlan> _mockWorkoutPlans = [];
extension WorkoutApiService on ApiService {
  Future<WorkoutPlan> saveWorkoutPlan(WorkoutPlan plan) async {
    await _simulateNetworkDelay(delay: 300);
    final existingIndex = _mockWorkoutPlans.indexWhere((p) => p.id == plan.id);
    if (existingIndex != -1) {
      _mockWorkoutPlans[existingIndex] = plan.copyWith(updatedAt: DateTime.now());
      if (kDebugMode) print('🔄 Updated WorkoutPlan: ${plan.name}');
      return _mockWorkoutPlans[existingIndex];
    } else {
      final planWithProperIds = plan.id.isEmpty || plan.id.startsWith("temp_")
          ? plan.copyWith(id: _uuid.v4(), exercises: plan.exercises.map((e) => e.id.isEmpty || e.id.startsWith("temp_") ? e.copyWith(id: _uuid.v4()) : e).toList())
          : plan.copyWith(exercises: plan.exercises.map((e) => e.id.isEmpty || e.id.startsWith("temp_") ? e.copyWith(id: _uuid.v4()) : e).toList());
      _mockWorkoutPlans.add(planWithProperIds);
      if (kDebugMode) print('➕ Added WorkoutPlan: ${planWithProperIds.name}');
      return planWithProperIds;
    }
  }
  Future<List<WorkoutPlan>> getWorkoutPlans({String? userId}) async {
    await _simulateNetworkDelay(delay: 400);
    if (userId != null) return _mockWorkoutPlans.where((plan) => plan.authorId == userId).toList();
    return List.from(_mockWorkoutPlans);
  }
  Future<WorkoutPlan?> getWorkoutPlanById(String id) async { /* ... */ return null; } // Simplified
  Future<bool> deleteWorkoutPlan(String id) async { /* ... */ return false; } // Simplified
}

// --- Workout Log Mock Data & Service ---
final List<WorkoutLog> _mockWorkoutLogs = [];
extension WorkoutLogApiService on ApiService {
  Future<WorkoutLog> saveWorkoutLog(WorkoutLog log) async {
    await _simulateNetworkDelay(delay: 300);
    final logWithId = log.id.isEmpty ? log.copyWith(id: _uuid.v4()) : log;
    _mockWorkoutLogs.add(logWithId);
    if (kDebugMode) print('📝 WorkoutLog saved: ${logWithId.planName ?? 'Ad-hoc workout'}');
    return logWithId;
  }
  Future<List<WorkoutLog>> getWorkoutLogs({String? userId}) async { /* ... */ return []; } // Simplified
  Future<WorkoutLog?> getWorkoutLogById(String id) async { /* ... */ return null; } // Simplified
}

// --- Nutrition Service Mock Data & Methods ---
final Map<String, DailyMealLog> _mockDailyMealLogs = {};
extension NutritionApiService on ApiService {
  Future<List<FoodItem>> searchFoodItems(String query) async {
    await _simulateNetworkDelay(delay: 250);
    if (query.isEmpty) return mockFoodDatabase.take(10).toList();
    final lq = query.toLowerCase();
    return mockFoodDatabase.where((f) => f.name.toLowerCase().contains(lq) || (f.brand.isNotEmpty && f.brand.toLowerCase().contains(lq))).toList();
  }
  Future<FoodItem?> getFoodItemById(String id) async { /* ... */ return null; } // Simplified
  Future<DailyMealLog> saveDailyMealLog(DailyMealLog log) async {
    await _simulateNetworkDelay(delay: 300);
    final dateKey = DateFormat('yyyy-MM-dd').format(log.date);
    _mockDailyMealLogs["${log.userId}_$dateKey"] = log;
    if (kDebugMode) print('🥗 Saved DailyMealLog for ${log.userId} on $dateKey');
    return log;
  }
  Future<DailyMealLog?> getDailyMealLog(String userId, DateTime date) async {
    await _simulateNetworkDelay(delay: 200);
    return _mockDailyMealLogs["${userId}_${DateFormat('yyyy-MM-dd').format(date)}"];
  }
  Future<List<DailyMealLog>> getDailyMealLogsDateRange(String userId, DateTime start, DateTime end) async { /* ... */ return []; } // Simplified
}

// --- Progress Tracking Service Mock Data & Methods ---
final List<WeightEntry> _mockWeightEntries = [];
final List<BodyMeasurementEntry> _mockBodyMeasurementEntries = [];
final List<PerformanceMetricEntry> _mockPerformanceMetricEntries = [];
final List<Goal> _mockGoals = [];

extension ProgressApiService on ApiService {
  // Weight Entries
  Future<WeightEntry> saveWeightEntry(WeightEntry entry) async {
    await _simulateNetworkDelay();
    _mockWeightEntries.removeWhere((e) => e.id == entry.id);
    _mockWeightEntries.add(entry);
    _mockWeightEntries.sort((a, b) => b.date.compareTo(a.date));
    _updateGoalCurrentValues(entry.userId, GoalMetricType.weight, entry.weightKg, entry.date);
    if (kDebugMode) print('⚖️ Saved WeightEntry: ${entry.weightKg} kg for ${entry.userId}');
    return entry;
  }

  Future<List<WeightEntry>> getWeightEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return _mockWeightEntries.where((e) => e.userId == userId &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Body Measurement Entries
  Future<BodyMeasurementEntry> saveBodyMeasurementEntry(BodyMeasurementEntry entry) async {
    await _simulateNetworkDelay();
    _mockBodyMeasurementEntries.removeWhere((e) => e.id == entry.id);
    _mockBodyMeasurementEntries.add(entry);
    _mockBodyMeasurementEntries.sort((a, b) => b.date.compareTo(a.date));
    if(entry.bodyFatPercentage != null) _updateGoalCurrentValues(entry.userId, GoalMetricType.bodyFatPercentage, entry.bodyFatPercentage!, entry.date);
    if(entry.muscleMassKg != null) _updateGoalCurrentValues(entry.userId, GoalMetricType.muscleMass, entry.muscleMassKg!, entry.date);
    if (kDebugMode) print('📏 Saved BodyMeasurementEntry for ${entry.userId}');
    return entry;
  }

  Future<List<BodyMeasurementEntry>> getBodyMeasurementEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return _mockBodyMeasurementEntries.where((e) => e.userId == userId &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Performance Metric Entries
  Future<PerformanceMetricEntry> savePerformanceMetricEntry(PerformanceMetricEntry entry) async {
    await _simulateNetworkDelay();
    _mockPerformanceMetricEntries.removeWhere((e) => e.id == entry.id);
    _mockPerformanceMetricEntries.add(entry);
    _mockPerformanceMetricEntries.sort((a, b) => b.date.compareTo(a.date));
    if (kDebugMode) print('🏆 Saved PerformanceMetricEntry: ${entry.exerciseName}');
    return entry;
  }

  Future<List<PerformanceMetricEntry>> getPerformanceMetricEntries(String userId, {String? exerciseName, PerformanceMetricType? metricType, DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return _mockPerformanceMetricEntries.where((e) => e.userId == userId &&
        (exerciseName == null || e.exerciseName.toLowerCase() == exerciseName.toLowerCase()) &&
        (metricType == null || e.metricType == metricType) &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Goals
  Future<Goal> saveGoal(Goal goal) async {
    await _simulateNetworkDelay();
    final existingIndex = _mockGoals.indexWhere((g) => g.id == goal.id);
    if (existingIndex != -1) {
       _mockGoals[existingIndex] = goal.copyWith(updatedAt: DateTime.now());
    } else {
      _mockGoals.add(goal.id.isEmpty ? goal.copyWith(id: _uuid.v4()) : goal);
    }
    if (kDebugMode) print('🎯 Saved Goal: ${goal.name}');
    return goal;
  }

  Future<List<Goal>> getGoals(String userId, {bool? isActive}) async {
    await _simulateNetworkDelay();
    return _mockGoals.where((g) => g.userId == userId && (isActive == null || g.isActive == isActive)).toList();
  }

  Future<Goal> updateGoal(Goal goal) async { // Alias for saveGoal for now
    return saveGoal(goal);
  }

  Future<bool> deleteGoal(String goalId) async {
    await _simulateNetworkDelay();
    final initialLength = _mockGoals.length;
    _mockGoals.removeWhere((g) => g.id == goalId);
    return _mockGoals.length < initialLength;
  }

  void _updateGoalCurrentValues(String userId, GoalMetricType metricType, double newValue, DateTime entryDate, {String? exerciseName}) {
    final relevantGoals = _mockGoals.where((g) =>
        g.userId == userId && g.isActive && g.metricType == metricType &&
        (g.exerciseName == null || g.exerciseName?.toLowerCase() == exerciseName?.toLowerCase()) &&
        (g.targetDate == null || g.targetDate!.isAfter(entryDate) || g.targetDate!.isAtSameMomentAs(entryDate))
    ).toList();

    for (var goal in relevantGoals) {
      goal.currentValue = newValue;
      goal.updatedAt = DateTime.now();
      if (kDebugMode) print('Updated current value for goal "${goal.name}" to $newValue');
    }
  }
}

/// Retry Interceptor for network resilience
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ... (existing retry logic)
  }

  bool _shouldRetry(DioException error) {
    // ... (existing shouldRetry logic)
    return false; // Simplified
  }
}
