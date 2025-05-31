import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For ThemeMode and ChangeNotifier

// Define enums for settings
enum WeightUnit { kg, lbs }
enum DistanceUnit { km, miles }
enum HeightUnit { cm, ftIn } // Example, if you add height later

class SettingsService with ChangeNotifier { // Extend ChangeNotifier
  static const String _themeModeKey = 'themeMode';
  static const String _weightUnitKey = 'weightUnit';
  static const String _distanceUnitKey = 'distanceUnit';
  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding'; // New key
  // Add more keys as needed e.g.
  // static const String _heightUnitKey = 'heightUnit';
  // static const String _workoutRemindersKey = 'workoutReminders';

  late ThemeMode _themeMode;
  late WeightUnit _weightUnit;
  late DistanceUnit _distanceUnit;
  bool _hasCompletedOnboarding = false; // New private variable

  ThemeMode get themeMode => _themeMode;
  WeightUnit get weightUnit => _weightUnit;
  DistanceUnit get distanceUnit => _distanceUnit;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding; // New getter

  SettingsService() {
    // Initialize with defaults, then load actual saved values.
    // This ensures that the getters always return a valid value.
    _themeMode = ThemeMode.system;
    _weightUnit = WeightUnit.kg;
    _distanceUnit = DistanceUnit.km;
    _hasCompletedOnboarding = false; // Initialize here
    // loadSettings(); // loadSettings will be called from main.dart now
  }

  // Load all settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == prefs.getString(_themeModeKey),
      orElse: () => ThemeMode.system,
    );
    _weightUnit = WeightUnit.values.firstWhere(
      (e) => e.toString() == prefs.getString(_weightUnitKey),
      orElse: () => WeightUnit.kg,
    );
    _distanceUnit = DistanceUnit.values.firstWhere(
      (e) => e.toString() == prefs.getString(_distanceUnitKey),
      orElse: () => DistanceUnit.km,
    );
    _hasCompletedOnboarding = prefs.getBool(_hasCompletedOnboardingKey) ?? false; // Load value
    notifyListeners(); // Notify listeners after loading settings initially
  }

  // Theme Mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return; // Avoid unnecessary updates
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
    notifyListeners(); // Notify listeners about the change
  }

  // getThemeMode is now a getter `themeMode`

  // Weight Unit
  Future<void> setWeightUnit(WeightUnit unit) async {
    if (_weightUnit == unit) return;
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, unit.toString());
    notifyListeners();
  }

  // getWeightUnit is now a getter `weightUnit`

  // Distance Unit
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    if (_distanceUnit == unit) return;
    _distanceUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distanceUnitKey, unit.toString());
    notifyListeners();
  }

  // getDistanceUnit is now a getter `distanceUnit`

  // Example for a boolean preference (e.g., notifications)
  // late bool _workoutReminders;
  // bool get workoutReminders => _workoutReminders;

  // Future<void> setWorkoutReminders(bool enabled) async {
  //   if (_workoutReminders == enabled) return;
  //   _workoutReminders = enabled;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(_workoutRemindersKey, enabled);
  //   notifyListeners();
  // }

  // Future<bool> getWorkoutReminders() async { // This would be part of loadSettings
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_workoutRemindersKey) ?? false; // Default to false
  // }

  // Method to update onboarding status
  Future<void> setHasCompletedOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = value;
    await prefs.setBool(_hasCompletedOnboardingKey, value);
    notifyListeners(); // Notify if other parts of the app need to react
  }

  // getAllSettings is effectively replaced by the individual getters
  // and the loadSettings method.
}

// Helper extension for enum toString/fromString (optional, but can be cleaner)
// Not strictly needed if using e.toString() directly and parsing,
// but shown here for completeness if it was used more extensively.
extension EnumToStringHelper<T> on T {
  String enumToString() {
    return this.toString().split('.').last;
  }
}

// T stringToEnum<T>(String s, List<T> values) {
//   return values.firstWhere((v) => v.toString().split('.').last == s, orElse: () => values.first);
// }
