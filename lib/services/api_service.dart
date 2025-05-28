import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

// POST /auth/register
// Request: { "name": "Test User", "email": "test@example.com", "password": "password123" }
// Response: { "token": "your_jwt_token", "user": { "id": "1", "name": "Test User", "email": "test@example.com", "streakCount": 0, "profileImageUrl": null } }

// POST /auth/login
// Request: { "email": "test@example.com", "password": "password123" }
// Response: { "token": "your_jwt_token", "user": { "id": "1", "name": "Test User", "email": "test@example.com", "streakCount": 0, "profileImageUrl": null } }

// GET /users/me (Authenticated)
// Response: { "id": "1", "name": "Test User", "email": "test@example.com", "profileImageUrl": "https://example.com/profile.jpg", "streakCount": 10 }

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Base URL for the API
  static const String _baseUrl = 'https://api.aksumfit.com/v1'; // Placeholder

  ApiService()
      : _dio = Dio(BaseOptions(baseUrl: _baseUrl)),
        _secureStorage = const FlutterSecureStorage();

  // --- Mock API Methods ---

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // Mock successful registration response
    return {
      "token": "mock_jwt_token_for_${email}",
      "user": {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": name,
        "email": email,
        "streakCount": 0,
        "profileImageUrl": null,
      }
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // Mock successful login response
    if (email == "test@example.com" && password == "password123") {
      return {
        "token": "mock_jwt_token_for_${email}",
        "user": {
          "id": "1",
          "name": "Test User LoggedIn",
          "email": email,
          "streakCount": 5, // Example streak
          "profileImageUrl": "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
        }
      };
    } else {
      // Simulate an error for other credentials for now
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {"message": "Invalid credentials"},
        ),
      );
    }
  }

  Future<User> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    // Mock user profile data
    return User(
      id: "1", // Consistent with mock login
      name: "Mock User Profile",
      email: "profile@example.com",
      profileImageUrl: "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y&s=120",
      streakCount: 15,
    );
  }

  // --- Token Management (Placeholders) ---

  Future<void> saveToken(String token) async {
    print("ApiService: Saving token (placeholder): $token");
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    print("ApiService: Retrieving token (placeholder)");
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    print("ApiService: Clearing token (placeholder)");
    await _secureStorage.delete(key: 'auth_token');
  }

  // In a real app, you would add an interceptor to Dio to automatically
  // add the token to the headers of authenticated requests.
  // Example (for future implementation):
  // _dio.interceptors.add(InterceptorsWrapper(
  //   onRequest: (options, handler) async {
  //     final token = await getToken();
  //     if (token != null && token.isNotEmpty) {
  //       options.headers['Authorization'] = 'Bearer $token';
  //     }
  //     return handler.next(options);
  //   },
  // ));
}
