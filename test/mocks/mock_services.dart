import 'package:mockito/mockito.dart';
import 'package:aksumfit/services/settings_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/repositories/user_repository.dart';
import 'package:aksumfit/models/user.dart'; // Required for AuthManager and UserRepository

// For code generation with build_runner:
// import 'mock_services.mocks.dart';

// If not using build_runner for this step, define manual mocks:
class MockSettingsService extends Mock implements SettingsService {}

class MockAuthManager extends Mock implements AuthManager {
  // Add reasonable defaults for getters if needed by widgets during render
  @override
  bool get isLoggedIn => false; // Default, override in tests

  @override
  User? get currentUser => null; // Default, override in tests
}

class MockUserRepository extends Mock implements UserRepository {}
