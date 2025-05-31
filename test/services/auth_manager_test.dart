import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthManager', () {
    late AuthManager authManager;

    setUp(() {
      // Ensure a fresh instance for each test if AuthManager is a singleton that maintains state.
      // If AuthManager() factory always returns the same instance, we might need a reset method or be careful with test order.
      // For this test, let's assume AuthManager() gives a fresh state or we test its modification.
      // As AuthManager is a singleton, its state will persist across tests unless reset.
      // For true unit tests, ideally, we'd be able to create a new instance or reset it.
      // Let's proceed assuming we can observe its state changes.
      authManager = AuthManager();
      // Manually clear user for each test to ensure isolation, as it's a singleton.
      authManager.clearUser();
    });

    test('initial state is correct', () {
      expect(authManager.currentUser, isNull);
      expect(authManager.currentUserRole, UserRole.unknown);
      expect(authManager.isLoggedIn, isFalse);
    });

    test('setUser updates currentUser, currentUserRole, and isLoggedIn', () {
      final user = User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        streakCount: 0,
        role: UserRole.user,
      );

      int listenerCallCount = 0;
      authManager.addListener(() {
        listenerCallCount++;
      });

      authManager.setUser(user);

      expect(authManager.currentUser, user);
      expect(authManager.currentUserRole, UserRole.user);
      expect(authManager.isLoggedIn, isTrue);
      expect(listenerCallCount, 1); // Ensure listeners are notified
    });

    test('setUser with null clears user and notifies listeners', () {
      // First set a user
      final user = User(id: '1', name: 'Test', email: 'test@test.com', streakCount: 0, role: UserRole.trainer);
      authManager.setUser(user);

      int listenerCallCount = 0;
      authManager.addListener(() {
        listenerCallCount++;
      });

      authManager.setUser(null);

      expect(authManager.currentUser, isNull);
      expect(authManager.currentUserRole, UserRole.unknown);
      expect(authManager.isLoggedIn, isFalse);
      expect(listenerCallCount, 1);
    });

    test('clearUser updates state and notifies listeners', () {
      final user = User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        streakCount: 0,
        role: UserRole.trainer,
      );
      authManager.setUser(user); // Set a user first

      int listenerCallCount = 0;
      authManager.addListener(() {
        listenerCallCount++;
      });

      authManager.clearUser();

      expect(authManager.currentUser, isNull);
      expect(authManager.currentUserRole, UserRole.unknown);
      expect(authManager.isLoggedIn, isFalse);
      expect(listenerCallCount, 1);
    });

    test('role checking methods work correctly', () {
      final regularUser = User(id: 'usr', name: 'Reg', email: 'usr@ex.com', streakCount: 0, role: UserRole.user);
      final trainerUser = User(id: 'trn', name: 'Train', email: 'trn@ex.com', streakCount: 0, role: UserRole.trainer);
      final nutritionistUser = User(id: 'nut', name: 'Nutri', email: 'nut@ex.com', streakCount: 0, role: UserRole.nutritionist);

      authManager.setUser(regularUser);
      expect(authManager.isUser(), isTrue);
      expect(authManager.isTrainer(), isFalse);
      expect(authManager.isNutritionist(), isFalse);
      expect(authManager.hasRole(UserRole.user), isTrue);
      expect(authManager.hasRole(UserRole.trainer), isFalse);

      authManager.setUser(trainerUser);
      expect(authManager.isUser(), isFalse);
      expect(authManager.isTrainer(), isTrue);
      expect(authManager.isNutritionist(), isFalse);
      expect(authManager.hasRole(UserRole.trainer), isTrue);

      authManager.setUser(nutritionistUser);
      expect(authManager.isUser(), isFalse);
      expect(authManager.isTrainer(), isFalse);
      expect(authManager.isNutritionist(), isTrue);
      expect(authManager.hasRole(UserRole.nutritionist), isTrue);

      authManager.clearUser();
      expect(authManager.isUser(), isFalse);
      expect(authManager.isTrainer(), isFalse);
      expect(authManager.isNutritionist(), isFalse);
      expect(authManager.hasRole(UserRole.user), isFalse); // Unknown role is not user role
      expect(authManager.currentUserRole, UserRole.unknown);
    });
  });
}
