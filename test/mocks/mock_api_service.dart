import 'package:aksumfit/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:aksumfit/models/user.dart'; // Ensure AuthResponse and User are available

// Manual mock for AuthResponse if not already deeply mocked
class MockAuthResponse extends Mock implements AuthResponse {
  @override
  final bool success;
  @override
  final String token;
  @override
  final User user;
  @override
  final String? message;

  MockAuthResponse({
    required this.success,
    required this.token,
    required this.user,
    this.message,
  });
}

// Generate Mocks for ApiService by running:
// flutter pub run build_runner build --delete-conflicting-outputs
// Add the following annotation to a file (e.g. this one, or a central mocks.dart)
// @GenerateMocks([ApiService])
// For now, I will create a manual simplified mock as build_runner is not executed by the agent.

class MockApiService extends Mock implements ApiService {
  // Mocking specific methods needed for LoginScreen tests
  @override
  Future<AuthResponse> login({required String email, required String password}) {
    return super.noSuchMethod(
      Invocation.method(#login, [], {#email: email, #password: password}),
      returnValue: Future.value(
        MockAuthResponse( // Use the manual mock for AuthResponse
          success: true,
          token: 'mock_token',
          user: User(id: '1', name: 'Mock User', email: email, streakCount: 0, role: UserRole.user),
          message: 'Login successful'
        )
      ),
      returnValueForMissingStub: Future.value(
        MockAuthResponse(
          success: true,
          token: 'mock_token',
          user: User(id: '1', name: 'Mock User', email: email, streakCount: 0, role: UserRole.user),
          message: 'Login successful'
        )
      ),
    );
  }

  // Add other methods that need mocking for other widget tests here
}
