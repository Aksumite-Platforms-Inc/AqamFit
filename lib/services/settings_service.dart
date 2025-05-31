import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For ThemeMode

// Define enums for settings
enum WeightUnit { kg, lbs }
enum DistanceUnit { km, miles }
enum HeightUnit { cm, ftIn } // Example, if you add height later

class SettingsService {
  static const String _themeModeKey = 'themeMode';
  static const String _weightUnitKey = 'weightUnit';
  static const String _distanceUnitKey = 'distanceUnit';
  // Add more keys as needed e.g.
  // static const String _heightUnitKey = 'heightUnit';
  // static const String _workoutRemindersKey = 'workoutReminders';

  // Theme Mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system, // Default to system theme
    );
  }

  // Weight Unit
  Future<void> setWeightUnit(WeightUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, unit.toString());
  }

  Future<WeightUnit> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final unitString = prefs.getString(_weightUnitKey);
    return WeightUnit.values.firstWhere(
      (e) => e.toString() == unitString,
      orElse: () => WeightUnit.kg, // Default to kg
    );
  }

  // Distance Unit
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distanceUnitKey, unit.toString());
  }

  Future<DistanceUnit> getDistanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final unitString = prefs.getString(_distanceUnitKey);
    return DistanceUnit.values.firstWhere(
      (e) => e.toString() == unitString,
      orElse: () => DistanceUnit.km, // Default to km
    );
  }

  // Example for a boolean preference (e.g., notifications)
  // Future<void> setWorkoutReminders(bool enabled) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(_workoutRemindersKey, enabled);
  // }

  // Future<bool> getWorkoutReminders() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_workoutRemindersKey) ?? false; // Default to false
  // }


  // It might be useful to have a method to load all settings at once
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'themeMode': await getThemeMode(),
      'weightUnit': await getWeightUnit(),
      'distanceUnit': await getDistanceUnit(),
      // 'workoutReminders': await getWorkoutReminders(),
    };
  }
}

// Helper extension for enum toString/fromString (optional, but can be cleaner)
extension EnumToStringHelper<T> on T {
  String enumToString() {
    return this.toString().split('.').last;
  }
}

// T stringToEnum<T>(String s, List<T> values) {
//   return values.firstWhere((v) => v.toString().split('.').last == s, orElse: () => values.first);
// }
