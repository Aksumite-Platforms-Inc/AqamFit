import 'package:aksumfit/models/user.dart';
import 'package:flutter/foundation.dart';

/// Manages the current authenticated user's state.
class AuthManager extends ChangeNotifier {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  User? _currentUser;
  UserRole _currentUserRole = UserRole.unknown;

  User? get currentUser => _currentUser;
  UserRole get currentUserRole => _currentUserRole;

  bool get isLoggedIn => _currentUser != null;

  void setUser(User? user) {
    _currentUser = user;
    if (user != null) {
      _currentUserRole = user.role;
    } else {
      _currentUserRole = UserRole.unknown;
    }
    notifyListeners(); // Notify listeners of state change
  }

  void clearUser() {
    _currentUser = null;
    _currentUserRole = UserRole.unknown;
    notifyListeners();
  }

  // Example of checking role
  bool hasRole(UserRole role) {
    return _currentUserRole == role;
  }

  bool isUser() => _currentUserRole == UserRole.user;
  bool isTrainer() => _currentUserRole == UserRole.trainer;
  bool isNutritionist() => _currentUserRole == UserRole.nutritionist;
}
