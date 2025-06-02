import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aksumfit/services/auth_manager.dart'; // Import AuthManager
import '../models/user.dart';

// Models used by various ApiService extensions (centralized imports)
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/models/logged_exercise.dart';
import 'package:aksumfit/models/logged_set.dart';
import 'package:aksumfit/models/personal_record.dart'; // Import PersonalRecord model
import 'package:aksumfit/models/challenge.dart'; // Import Challenge model
import 'package:aksumfit/features/nutrition/data/mock_food_database.dart';
import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/models/food_item.dart';
import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/models/body_measurement_entry.dart';
import 'package:aksumfit/models/performance_metric_entry.dart';
import 'package:aksumfit/models/exercise.dart'; // <-- Add this import
import 'package:intl/intl.dart'; // For DateFormat
import 'package:uuid/uuid.dart'; // For generating IDs for mock data


/// Enhanced API Service for AxumFit
/// Includes error handling, logging, retry logic, and production-ready features
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;

  // Social/Challenges API methods for SocialScreen
  Future<List<Challenge>> getFeaturedChallenges() async {
    // TODO: Replace with real API call or mock data as needed
    await _simulateNetworkDelay(delay: 200);
    // Return a subset of mock challenges, or empty list for now
    return [];
  }

  Future<List<Challenge>> getHotChallenges() async {
    // TODO: Replace with real API call or mock data as needed
    await _simulateNetworkDelay(delay: 200);
    // Return a subset of mock challenges, or empty list for now
    return [];
  }

  // API Configuration
  static const String _baseUrl = 'https://api.axumfit.com/v1';
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  // Initialize the service
  // Secure storage instance
  late final FlutterSecureStorage _secureStorage;

  void initialize() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(),
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
      }

    )); // End of BaseOptions

// --- Social/Challenges API Stubs ---

// Social/Challenges API methods for SocialScreen
Future<List<Challenge>> getFeaturedChallenges() async {
  // TODO: Replace with real API call or mock data as needed
  await _simulateNetworkDelay(delay: 200);
  // Return a subset of mock challenges, or empty list for now
  return [];
}

Future<List<Challenge>> getHotChallenges() async {
  // TODO: Replace with real API call or mock data as needed
  await _simulateNetworkDelay(delay: 200);
  // Return a subset of mock challenges, or empty list for now
  return [];
}

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
    int workoutsThisWeek = mockWorkoutLogs.where((log) =>
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
    final userEntries = mockWeightEntries.where((e) => e.userId == userId).toList();
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

// --- Mock Exercise Database ---
// (This should ideally be before _mockWorkoutPlans if _mockWorkoutPlans uses it directly in its initialization)
// However, for patching, we can define it here and then modify _mockWorkoutPlans.
// For a cleaner final structure, _mockExercisesDatabase would be defined before _mockWorkoutPlans.
final List<Exercise> _mockExercisesDatabase = [
  Exercise(id: "ex001", name: "Squats", type: ExerciseType.strength, muscleGroups: ["Quads", "Glutes", "Hamstrings", "Core"], description: "A compound lower body exercise.", equipment: ["Barbell", "Rack"]),
  Exercise(id: "ex002", name: "Push-ups", type: ExerciseType.strength, muscleGroups: ["Chest", "Triceps", "Shoulders", "Core"], description: "A bodyweight exercise for upper body strength.", equipment: []),
  Exercise(id: "ex003", name: "Rows (Dumbbell or Machine)", type: ExerciseType.strength, muscleGroups: ["Back (Lats)", "Biceps", "Rear Delts"], description: "Pulls weight towards your torso, works the back.", equipment: ["Dumbbells or Machine"]),
  Exercise(id: "ex004", name: "Plank", type: ExerciseType.strength, muscleGroups: ["Core", "Abs"], description: "An isometric core strength exercise.", equipment: []),
  Exercise(id: "ex005", name: "Leg Press", type: ExerciseType.strength, muscleGroups: ["Quads", "Glutes"], description: "A machine-based lower body exercise.", equipment: ["Leg Press Machine"]),
  Exercise(id: "ex006", name: "Romanian Deadlifts (RDLs)", type: ExerciseType.strength, muscleGroups: ["Hamstrings", "Glutes", "Lower Back"], description: "Focuses on hamstring and glute development.", equipment: ["Barbell or Dumbbells"]),
  Exercise(id: "ex007", name: "Leg Extensions", type: ExerciseType.strength, muscleGroups: ["Quads"], description: "Isolation exercise for quadriceps.", equipment: ["Leg Extension Machine"]),
  Exercise(id: "ex008", name: "Hamstring Curls", type: ExerciseType.strength, muscleGroups: ["Hamstrings"], description: "Isolation exercise for hamstrings.", equipment: ["Hamstring Curl Machine"]),
  Exercise(id: "ex009", name: "Calf Raises", type: ExerciseType.strength, muscleGroups: ["Calves"], description: "Strengthens calf muscles.", equipment: ["Bodyweight or Weights"]),
  Exercise(id: "yg001", name: "Sun Salutation A", type: ExerciseType.stretch, muscleGroups: ["Full Body", "Core", "Flexibility"], description: "A sequence of yoga poses.", equipment: ["Yoga Mat"]),
  Exercise(id: "yg002", name: "Downward-Facing Dog", type: ExerciseType.stretch, muscleGroups: ["Hamstrings", "Calves", "Shoulders", "Back"], description: "A common yoga pose.", equipment: ["Yoga Mat"]),
  Exercise(id: "yg003", name: "Warrior II (Right & Left)", type: ExerciseType.stretch, muscleGroups: ["Legs", "Core", "Shoulders"], description: "A standing yoga pose.", equipment: ["Yoga Mat"]),
  Exercise(id: "yg004", name: "Triangle Pose (Right & Left)", type: ExerciseType.stretch, muscleGroups: ["Hamstrings", "Groin", "Hips", "Core"], description: "A standing yoga pose.", equipment: ["Yoga Mat"]),
  Exercise(id: "yg005", name: "Child's Pose", type: ExerciseType.stretch, muscleGroups: ["Back", "Hips", "Thighs"], description: "A resting yoga pose.", equipment: ["Yoga Mat"]),
  Exercise(id: "hiit001", name: "Jumping Jacks", type: ExerciseType.cardio, muscleGroups: ["Full Body", "Cardio"], description: "A full-body cardio exercise.", equipment: []),
  Exercise(id: "hiit002", name: "High Knees", type: ExerciseType.cardio, muscleGroups: ["Full Body", "Cardio", "Core", "Legs"], description: "A cardio exercise that engages the core.", equipment: []),
  Exercise(id: "hiit003", name: "Burpees", type: ExerciseType.plyometrics, muscleGroups: ["Full Body", "Cardio", "Strength"], description: "A challenging full-body exercise.", equipment: []),
  Exercise(id: "hiit004", name: "Mountain Climbers", type: ExerciseType.cardio, muscleGroups: ["Core", "Cardio", "Shoulders"], description: "A dynamic core and cardio exercise.", equipment: []),
  Exercise(id: "hiit005", name: "Sprint in Place", type: ExerciseType.cardio, muscleGroups: ["Legs", "Cardio"], description: "High-intensity cardio exercise.", equipment: []),
  Exercise(id: "hiit006", name: "Cool Down Jog/Walk", type: ExerciseType.cardio, muscleGroups: ["Full Body", "Cardio"], description: "Low-intensity cardio for cool down.", equipment: []),
];

// Helper function to find exercise details by ID
// Top-level function for access from anywhere
Exercise? getExerciseDetailsById(String exerciseId) {
  try {
    return _mockExercisesDatabase.firstWhere((ex) => ex.id == exerciseId);
  } catch (e) {
    if (kDebugMode) {
      print("Warning: Exercise with ID '$exerciseId' not found in _mockExercisesDatabase.");
    }
    return null;
  }
}


// --- Workout Plan Mock Data & Service ---
// Note: The initialization of _mockWorkoutPlans will be modified to include exerciseDetails.
// This requires _mockExercisesDatabase to be defined above or accessible.
// For the diff, we'll assume _mockExercisesDatabase is accessible and modify _mockWorkoutPlans.

List<WorkoutPlan> _initializeMockWorkoutPlans() {
  return [
    WorkoutPlan(
      id: _uuid.v4(),
      name: "Beginner Strength Routine",
      description: "A great starting point for building overall strength. Focuses on compound movements.",
      category: WorkoutPlanCategory.hiit, // Use hiit as closest available, since 'cardio' is not in the enum
      difficulty: WorkoutDifficulty.beginner,
      estimatedDurationMinutes: 45,
      authorId: "system_generated_trainer_1",
      exercises: [
        WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex001", order: 0, sets: 3, reps: "8-12", restBetweenSetsSeconds: 60, exerciseDetails: getExerciseDetailsById("ex001")),
        WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex002", order: 1, sets: 3, reps: "As many as possible", restBetweenSetsSeconds: 60, exerciseDetails: getExerciseDetailsById("ex002")),
        WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex003", order: 2, sets: 3, reps: "10-15", restBetweenSetsSeconds: 60, exerciseDetails: getExerciseDetailsById("ex003")),
        WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex004", order: 3, sets: 3, reps: "Hold for 30-60s", restBetweenSetsSeconds: 45, exerciseDetails: getExerciseDetailsById("ex004")),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ["full body", "beginner friendly", "strength building"],
    ),
    WorkoutPlan(
      id: _uuid.v4(),
      name: "Leg Day Burner",
      description: "Intense leg workout to build strength and hypertrophy in your lower body.",
      category: WorkoutPlanCategory.hypertrophy,
      difficulty: WorkoutDifficulty.intermediate,
      estimatedDurationMinutes: 60,
      authorId: "system_generated_trainer_2",
      exercises: [
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex001", order: 0, sets: 4, reps: "8-10", restBetweenSetsSeconds: 90, exerciseDetails: getExerciseDetailsById("ex001")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex005", order: 1, sets: 3, reps: "10-12", restBetweenSetsSeconds: 75, exerciseDetails: getExerciseDetailsById("ex005")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex006", order: 2, sets: 3, reps: "10-12", restBetweenSetsSeconds: 75, exerciseDetails: getExerciseDetailsById("ex006")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex007", order: 3, sets: 3, reps: "12-15", restBetweenSetsSeconds: 60, exerciseDetails: getExerciseDetailsById("ex007")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex008", order: 4, sets: 3, reps: "12-15", restBetweenSetsSeconds: 60, exerciseDetails: getExerciseDetailsById("ex008")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "ex009", order: 5, sets: 4, reps: "15-20", restBetweenSetsSeconds: 45, exerciseDetails: getExerciseDetailsById("ex009")),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ["legs", "hypertrophy", "volume"],
    ),
    WorkoutPlan(
      id: _uuid.v4(),
      name: "Morning Yoga Flow",
      description: "A gentle yoga sequence to start your day with energy and mindfulness.",
      category: WorkoutPlanCategory.flexibility,
      difficulty: WorkoutDifficulty.allLevels,
      estimatedDurationMinutes: 30,
      authorId: "system_generated_yogi_1",
      exercises: [
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "yg001", order: 0, sets: 5, reps: "rounds", notes: "Flow through 5 rounds", exerciseDetails: getExerciseDetailsById("yg001")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "yg002", order: 1, sets: 1, reps: "Hold for 5 breaths", exerciseDetails: getExerciseDetailsById("yg002")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "yg003", order: 2, sets: 1, reps: "Hold each side for 5 breaths", exerciseDetails: getExerciseDetailsById("yg003")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "yg004", order: 3, sets: 1, reps: "Hold each side for 5 breaths", exerciseDetails: getExerciseDetailsById("yg004")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "yg005", order: 4, sets: 1, reps: "Hold for 5-10 breaths", exerciseDetails: getExerciseDetailsById("yg005")),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ["yoga", "flexibility", "morning routine", "mindfulness"],
    ),
    WorkoutPlan(
      id: _uuid.v4(),
      name: "HIIT Cardio Challenge",
      description: "High-Intensity Interval Training to boost your cardiovascular fitness and burn calories.",
      category: WorkoutPlanCategory.hiit,
      difficulty: WorkoutDifficulty.intermediate,
      estimatedDurationMinutes: 25,
      authorId: "system_generated_trainer_1",
      exercises: [
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit001", order: 0, sets: 1, reps: "60s work, 30s rest", notes: "Warm-up", exerciseDetails: getExerciseDetailsById("hiit001")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit002", order: 1, sets: 4, reps: "30s work, 15s rest", exerciseDetails: getExerciseDetailsById("hiit002")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit003", order: 2, sets: 4, reps: "30s work, 15s rest", exerciseDetails: getExerciseDetailsById("hiit003")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit004", order: 3, sets: 4, reps: "30s work, 15s rest", exerciseDetails: getExerciseDetailsById("hiit004")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit005", order: 4, sets: 4, reps: "30s work, 15s rest", exerciseDetails: getExerciseDetailsById("hiit005")),
          WorkoutPlanExercise(id: _uuid.v4(), exerciseId: "hiit006", order: 5, sets: 1, reps: "3-5 minutes", exerciseDetails: getExerciseDetailsById("hiit006")),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ["hiit", "cardio", "fat burning", "quick workout"],
    ),
  ];
}

final List<WorkoutPlan> _mockWorkoutPlans = _initializeMockWorkoutPlans();

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
final List<WorkoutLog> mockWorkoutLogs = [
  WorkoutLog(
    id: _uuid.v4(),
    userId: "demo_user_001",
    planId: _mockWorkoutPlans[0].id, // Assumes Beginner Strength Routine
    planName: _mockWorkoutPlans[0].name,
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    completedExercises: [
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex001", exerciseName: "Squats", sets: [
        LoggedSet(setNumber: 1, repsAchieved: 10, weightUsedKg: 50),
        LoggedSet(setNumber: 2, repsAchieved: 10, weightUsedKg: 50),
        LoggedSet(setNumber: 3, repsAchieved: 8, weightUsedKg: 50),
      ]),
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex002", exerciseName: "Push-ups", sets: [
        LoggedSet(setNumber: 1, repsAchieved: 15),
        LoggedSet(setNumber: 2, repsAchieved: 12),
        LoggedSet(setNumber: 3, repsAchieved: 10),
      ]),
    ],
    notes: "Felt good, focused on form.",
  ),
  WorkoutLog(
    id: _uuid.v4(),
    userId: "demo_user_001",
    planId: _mockWorkoutPlans[1].id, // Assumes Leg Day Burner
    planName: _mockWorkoutPlans[1].name,
    startTime: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
    endTime: DateTime.now().subtract(const Duration(days: 3, hours: 0, minutes: 45)),
    completedExercises: [
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex001", exerciseName: "Barbell Squats", sets: [
         LoggedSet(setNumber: 1, repsAchieved: 8, weightUsedKg: 60),
         LoggedSet(setNumber: 2, repsAchieved: 8, weightUsedKg: 60),
         LoggedSet(setNumber: 3, repsAchieved: 6, weightUsedKg: 60),
      ]),
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex005", exerciseName: "Leg Press", sets: [
         LoggedSet(setNumber: 1, repsAchieved: 10, weightUsedKg: 100),
         LoggedSet(setNumber: 2, repsAchieved: 10, weightUsedKg: 100),
      ]),
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex006", exerciseName: "Romanian Deadlifts (RDLs)", sets: [
         LoggedSet(setNumber: 1, repsAchieved: 12, weightUsedKg: 40),
         LoggedSet(setNumber: 2, repsAchieved: 10, weightUsedKg: 40),
      ]),
    ],
    notes: "Legs are toast!",
  ),
   WorkoutLog( // Log with an exercise that hits different muscle groups
    id: _uuid.v4(),
    userId: "demo_user_001",
    planId: _mockWorkoutPlans[3].id, // Assumes HIIT Cardio Challenge
    planName: _mockWorkoutPlans[3].name,
    startTime: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
    endTime: DateTime.now().subtract(const Duration(days: 5, hours: 0, minutes: 30)),
    completedExercises: [
      LoggedExercise(id: _uuid.v4(), exerciseId: "hiit003", exerciseName: "Burpees", sets: [ // Burpees are full body
         LoggedSet(setNumber: 1, repsAchieved: 15),
         LoggedSet(setNumber: 2, repsAchieved: 12),
      ]),
      LoggedExercise(id: _uuid.v4(), exerciseId: "ex004", exerciseName: "Plank", sets: [ // Plank is core
         LoggedSet(setNumber: 1, durationAchievedSeconds: 60),
         LoggedSet(setNumber: 2, durationAchievedSeconds: 45),
      ]),
    ],
  ),
];
extension WorkoutLogApiService on ApiService {
  Future<WorkoutLog> saveWorkoutLog(WorkoutLog log) async {
    await _simulateNetworkDelay(delay: 300);
    final logWithId = log.id.isEmpty ? log.copyWith(id: _uuid.v4()) : log;
    mockWorkoutLogs.add(logWithId);
    if (kDebugMode) print('📝 WorkoutLog saved: ${logWithId.planName ?? 'Ad-hoc workout'}');
    return logWithId;
  }
  Future<List<WorkoutLog>> getWorkoutLogs({String? userId, DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay(delay: 200);
    if (userId == null) return List.from(mockWorkoutLogs); // Return all if no userId

    var userLogs = mockWorkoutLogs.where((log) => log.userId == userId);

    if (startDate != null) {
        userLogs = userLogs.where((log) => !log.startTime.isBefore(startDate));
    }
    if (endDate != null) {
        userLogs = userLogs.where((log) => !log.startTime.isAfter(endDate));
    }
    return userLogs.toList();
  }
  Future<WorkoutLog?> getWorkoutLogById(String id) async {
    await _simulateNetworkDelay(delay: 100);
    try {
      return mockWorkoutLogs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }
}

// --- Nutrition Service Mock Data & Methods ---
final Map<String, DailyMealLog> mockDailyMealLogs = {};
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
    mockDailyMealLogs["${log.userId}_$dateKey"] = log;
    if (kDebugMode) print('🥗 Saved DailyMealLog for ${log.userId} on $dateKey');
    return log;
  }
  Future<DailyMealLog?> getDailyMealLog(String userId, DateTime date) async {
    await _simulateNetworkDelay(delay: 200);
    return mockDailyMealLogs["${userId}_${DateFormat('yyyy-MM-dd').format(date)}"];
  }
  Future<List<DailyMealLog>> getDailyMealLogsDateRange(String userId, DateTime start, DateTime end) async { /* ... */ return []; } // Simplified
}

// --- Progress Tracking Service Mock Data & Methods ---
final List<WeightEntry> mockWeightEntries = [];
final List<BodyMeasurementEntry> mockBodyMeasurementEntries = [];
final List<PerformanceMetricEntry> mockPerformanceMetricEntries = [];
final List<Goal> mockGoals = [];
final List<PersonalRecord> mockPersonalRecords = [
  PersonalRecord(
    id: _uuid.v4(),
    userId: "demo_user_001",
    exerciseName: "Bench Press",
    recordType: "1 Rep Max",
    value: "100 kg",
    dateAchieved: DateTime.now().subtract(const Duration(days: 30)),
  ),
  PersonalRecord(
    id: _uuid.v4(),
    userId: "demo_user_001",
    exerciseName: "Pull-ups",
    recordType: "Max Reps",
    value: "15 reps",
    dateAchieved: DateTime.now().subtract(const Duration(days: 10)),
  ),
  PersonalRecord(
    id: _uuid.v4(),
    userId: "demo_user_001",
    exerciseName: "Squat",
    recordType: "1 Rep Max",
    value: "140 kg",
    dateAchieved: DateTime.now().subtract(const Duration(days: 45)),
  ),
  PersonalRecord(
    id: _uuid.v4(),
    userId: "demo_user_001",
    exerciseName: "Running",
    recordType: "Fastest 5k",
    value: "22:30",
    dateAchieved: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

extension ProgressApiService on ApiService {
  // Weight Entries
  Future<WeightEntry> saveWeightEntry(WeightEntry entry) async {
    await _simulateNetworkDelay();
    mockWeightEntries.removeWhere((e) => e.id == entry.id);
    mockWeightEntries.add(entry);
    mockWeightEntries.sort((a, b) => b.date.compareTo(a.date));
    updateGoalCurrentValues(entry.userId, GoalMetricType.weight, entry.weightKg, entry.date);
    if (kDebugMode) print('⚖️ Saved WeightEntry: ${entry.weightKg} kg for ${entry.userId}');
    return entry;
  }

  Future<List<WeightEntry>> getWeightEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return mockWeightEntries.where((e) => e.userId == userId &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Body Measurement Entries
  Future<BodyMeasurementEntry> saveBodyMeasurementEntry(BodyMeasurementEntry entry) async {
    await _simulateNetworkDelay();
    mockBodyMeasurementEntries.removeWhere((e) => e.id == entry.id);
    mockBodyMeasurementEntries.add(entry);
    mockBodyMeasurementEntries.sort((a, b) => b.date.compareTo(a.date));
    if(entry.bodyFatPercentage != null) updateGoalCurrentValues(entry.userId, GoalMetricType.bodyFatPercentage, entry.bodyFatPercentage!, entry.date);
    if(entry.muscleMassKg != null) updateGoalCurrentValues(entry.userId, GoalMetricType.muscleMass, entry.muscleMassKg!, entry.date);
    if (kDebugMode) print('📏 Saved BodyMeasurementEntry for ${entry.userId}');
    return entry;
  }

  Future<List<BodyMeasurementEntry>> getBodyMeasurementEntries(String userId, {DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return mockBodyMeasurementEntries.where((e) => e.userId == userId &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Performance Metric Entries
  Future<PerformanceMetricEntry> savePerformanceMetricEntry(PerformanceMetricEntry entry) async {
    await _simulateNetworkDelay();
    mockPerformanceMetricEntries.removeWhere((e) => e.id == entry.id);
    mockPerformanceMetricEntries.add(entry);
    mockPerformanceMetricEntries.sort((a, b) => b.date.compareTo(a.date));
    if (kDebugMode) print('🏆 Saved PerformanceMetricEntry: ${entry.exerciseName}');
    return entry;
  }

  Future<List<PerformanceMetricEntry>> getPerformanceMetricEntries(String userId, {String? exerciseName, PerformanceMetricType? metricType, DateTime? startDate, DateTime? endDate}) async {
    await _simulateNetworkDelay();
    return mockPerformanceMetricEntries.where((e) => e.userId == userId &&
        (exerciseName == null || e.exerciseName.toLowerCase() == exerciseName.toLowerCase()) &&
        (metricType == null || e.metricType == metricType) &&
        (startDate == null || e.date.isAfter(startDate.subtract(const Duration(days:1)))) &&
        (endDate == null || e.date.isBefore(endDate.add(const Duration(days:1))))
    ).toList();
  }

  // Goals
  Future<Goal> saveGoal(Goal goal) async {
    await _simulateNetworkDelay();
    final existingIndex = mockGoals.indexWhere((g) => g.id == goal.id);
    if (existingIndex != -1) {
       mockGoals[existingIndex] = goal.copyWith(updatedAt: DateTime.now());
    } else {
      mockGoals.add(goal.id.isEmpty ? goal.copyWith(id: _uuid.v4()) : goal);
    }
    if (kDebugMode) print('🎯 Saved Goal: ${goal.name}');
    return goal;
  }

  Future<List<Goal>> getGoals(String userId, {bool? isActive}) async {
    await _simulateNetworkDelay();
    return mockGoals.where((g) => g.userId == userId && (isActive == null || g.isActive == isActive)).toList();
  }

  Future<Goal> updateGoal(Goal goal) async { // Alias for saveGoal for now
    return saveGoal(goal);
  }

  Future<bool> deleteGoal(String goalId) async {
    await _simulateNetworkDelay();
    final initialLength = mockGoals.length;
    mockGoals.removeWhere((g) => g.id == goalId);
    return mockGoals.length < initialLength;
  }

  // Personal Records
  Future<List<PersonalRecord>> getPersonalRecords(String userId) async {
    await _simulateNetworkDelay(delay: 200);
    return mockPersonalRecords.where((pr) => pr.userId == userId).toList();
  }

  // TODO: Add savePersonalRecord if needed in future

  void updateGoalCurrentValues(String userId, GoalMetricType metricType, double newValue, DateTime entryDate, {String? exerciseName}) {
    final relevantGoals = mockGoals.where((g) =>
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
}
