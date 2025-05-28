import '../models/user.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      if (response.containsKey('token') && response.containsKey('user')) {
        final token = response['token'] as String;
        await _apiService.saveToken(token);

        final userData = response['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Login failed: $e');
      // In a real app, handle different types of errors, e.g., DioException, etc.
      return null;
    }
    return null;
  }

  Future<User?> registerUser(String name, String email, String password) async {
    try {
      final response = await _apiService.register(name, email, password);
      if (response.containsKey('token') && response.containsKey('user')) {
        final token = response['token'] as String;
        await _apiService.saveToken(token);

        final userData = response['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Registration failed: $e');
      return null;
    }
    return null;
  }

  Future<User?> getMyProfile() async {
    try {
      // In a real app, this method would likely require an auth token.
      // The ApiService's Dio instance would be configured with an interceptor
      // to automatically add the token from FlutterSecureStorage.
      // For this mock, we directly call the mock profile fetch.
      return await _apiService.getUserProfile();
    } catch (e) {
      print('Get profile failed: $e');
      return null;
    }
  }

  Future<void> logoutUser() async {
    await _apiService.clearToken();
    // Potentially notify other parts of the app about logout
  }
}
