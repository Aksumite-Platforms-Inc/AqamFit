import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

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
        }
      };

      final authResponse = AuthResponse.fromJson(mockResponse);
      await saveToken(authResponse.token);

      return authResponse;

      // Real API implementation:
      // final response = await _dio.post('/auth/register', data: {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      // });
      //
      // final authResponse = AuthResponse.fromJson(response.data);
      // await saveToken(authResponse.token);
      // return authResponse;
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

      // Mock login validation
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
          }
        };

        final authResponse = AuthResponse.fromJson(mockResponse);
        await saveToken(authResponse.token);
        return authResponse;
      } else {
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
      await clearToken();

      // Real API call would be:
      // await _dio.post('/auth/logout');
    } catch (e) {
      // Even if logout fails, clear local token
      await clearToken();
      if (kDebugMode) {
        print('Logout error (cleared local token anyway): $e');
      }
    }
  }

  /// User Profile Methods

  Future<User> getUserProfile() async {
    try {
      await _simulateNetworkDelay(delay: 300);

      // Mock user profile
      final mockData = {
        "id": "demo_user_001",
        "name": "Demo User",
        "email": "demo@axumfit.com",
        "profileImageUrl":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
        "streakCount": 7,
        "totalWorkouts": 45,
        "totalCaloriesBurned": 12500,
        "fitnessLevel": "intermediate",
        "joinedDate": "2024-01-15T10:30:00Z",
        "isVerified": true,
        "preferences": {
          "workoutReminders": true,
          "nutritionTracking": true,
          "socialFeatures": true,
        }
      };

      return User.fromJson(mockData);

      // Real API call:
      // final response = await _dio.get('/users/me');
      // return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Failed to fetch user profile: ${e.toString()}');
    }
  }

  Future<User> updateUserProfile({
    String? name,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      await _simulateNetworkDelay();

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      if (preferences != null) updateData['preferences'] = preferences;

      // Mock updated user
      final mockData = {
        "id": "demo_user_001",
        "name": name ?? "Demo User",
        "email": "demo@axumfit.com",
        "profileImageUrl": profileImageUrl ??
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
        "streakCount": 7,
        "totalWorkouts": 45,
        "totalCaloriesBurned": 12500,
        "fitnessLevel": "intermediate",
        "joinedDate": "2024-01-15T10:30:00Z",
        "isVerified": true,
        "preferences": preferences ??
            {
              "workoutReminders": true,
              "nutritionTracking": true,
              "socialFeatures": true,
            }
      };

      return User.fromJson(mockData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Token Management

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      if (kDebugMode) {
        print('🔐 Token saved successfully');
      }
    } catch (e) {
      throw ApiException('Failed to save authentication token');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to read token: $e');
      }
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      if (kDebugMode) {
        print('🗑️ Token cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear token: $e');
      }
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Workout Data Methods (Placeholders for future implementation)

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    await _simulateNetworkDelay();
    // Mock workout data
    return [
      {
        "id": "workout_001",
        "name": "Morning Cardio Blast",
        "duration": 30,
        "calories": 250,
        "date":
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "type": "cardio",
        "completed": true,
      },
      {
        "id": "workout_002",
        "name": "Strength Training",
        "duration": 45,
        "calories": 320,
        "date":
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "type": "strength",
        "completed": true,
      },
    ];
  }

  Future<Map<String, dynamic>> getTodaysStats() async {
    await _simulateNetworkDelay(delay: 200);
    return {
      "caloriesBurned": 150,
      "workoutsCompleted": 1,
      "activeMinutes": 25,
      "streakCount": 7,
      "weeklyGoalProgress": 0.6,
    };
  }

  /// Helper Methods

  Future<void> _simulateNetworkDelay({int delay = 500}) async {
    if (kDebugMode) {
      await Future.delayed(Duration(milliseconds: delay));
    }
  }

  void _handleUnauthorized() {
    // Clear token and navigate to login
    clearToken();
    // In a real app, you might want to emit an event or use a state management solution
    // to handle navigation to login screen
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'An error occurred';

        switch (statusCode) {
          case 400:
            return ApiException('Invalid request: $message');
          case 401:
            return ApiException('Authentication failed. Please login again.');
          case 403:
            return ApiException('Access denied: $message');
          case 404:
            return ApiException('Resource not found: $message');
          case 422:
            return ApiException('Validation error: $message');
          case 500:
            return ApiException('Server error. Please try again later.');
          default:
            return ApiException('Request failed: $message');
        }

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');

      case DioExceptionType.unknown:
      default:
        return ApiException('Network error. Please check your connection.');
    }
  }
}

/// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

/// Auth Response Model
class AuthResponse {
  final bool success;
  final String token;
  final User user;
  final String? message;

  AuthResponse({
    required this.success,
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      token: json['token'],
      user: User.fromJson(json['user']),
      message: json['message'],
    );
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
    final extra = err.requestOptions.extra;
    final retriesCount = extra['retries'] ?? 0;

    if (retriesCount < retries && _shouldRetry(err)) {
      logPrint?.call(
          'Retrying request (${retriesCount + 1}/$retries): ${err.requestOptions.path}');

      final delay = retryDelays.length > retriesCount
          ? retryDelays[retriesCount]
          : retryDelays.last;

      await Future.delayed(delay);

      err.requestOptions.extra['retries'] = retriesCount + 1;

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          handler.next(e);
        } else {
          handler.next(err);
        }
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }
}
