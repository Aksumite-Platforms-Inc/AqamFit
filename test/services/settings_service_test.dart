import 'package:aksumfit/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    // Mock SharedPreferences values
    Map<String, Object> mockValues = {};

    setUpAll(() async {
      // Required to mock MethodChannel for SharedPreferences
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Initialize SharedPreferences with mock values for each test
      mockValues = {}; // Reset mock values for each test
      SharedPreferences.setMockInitialValues(mockValues);
      settingsService = SettingsService();
    });

    test('getThemeMode returns system default if no preference saved', () async {
      expect(await settingsService.getThemeMode(), ThemeMode.system);
    });

    test('setThemeMode and getThemeMode work correctly', () async {
      await settingsService.setThemeMode(ThemeMode.dark);
      expect(await settingsService.getThemeMode(), ThemeMode.dark);

      await settingsService.setThemeMode(ThemeMode.light);
      expect(await settingsService.getThemeMode(), ThemeMode.light);
    });

    test('getWeightUnit returns kg default if no preference saved', () async {
      expect(await settingsService.getWeightUnit(), WeightUnit.kg);
    });

    test('setWeightUnit and getWeightUnit work correctly', () async {
      await settingsService.setWeightUnit(WeightUnit.lbs);
      expect(await settingsService.getWeightUnit(), WeightUnit.lbs);

      await settingsService.setWeightUnit(WeightUnit.kg);
      expect(await settingsService.getWeightUnit(), WeightUnit.kg);
    });

    test('getDistanceUnit returns km default if no preference saved', () async {
      expect(await settingsService.getDistanceUnit(), DistanceUnit.km);
    });

    test('setDistanceUnit and getDistanceUnit work correctly', () async {
      await settingsService.setDistanceUnit(DistanceUnit.miles);
      expect(await settingsService.getDistanceUnit(), DistanceUnit.miles);

      await settingsService.setDistanceUnit(DistanceUnit.km);
      expect(await settingsService.getDistanceUnit(), DistanceUnit.km);
    });

    test('getAllSettings returns correct map of settings', () async {
      await settingsService.setThemeMode(ThemeMode.dark);
      await settingsService.setWeightUnit(WeightUnit.lbs);
      await settingsService.setDistanceUnit(DistanceUnit.miles);

      final allSettings = await settingsService.getAllSettings();

      expect(allSettings['themeMode'], ThemeMode.dark);
      expect(allSettings['weightUnit'], WeightUnit.lbs);
      expect(allSettings['distanceUnit'], DistanceUnit.miles);
    });
  });
}
