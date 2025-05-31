import 'package:aksumfit/models/daily_meal_log.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/features/nutrition/data/mock_food_database.dart'; // To access the mock data directly for comparison
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart'; // For date formatting in keys
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

void main() {
  group('ApiService - NutritionApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
      // It's important to note that ApiService uses global lists for mocks (_mockDailyMealLogs, etc.)
      // These lists will persist state between tests within this file unless cleared.
      // For more isolated tests, these global lists would need to be reset here,
      // or the ApiService refactored to allow injecting mock data stores.
      // For this scope, we'll test based on current state and known mock_food_database.

      // Clear any persisted mock data if necessary. This is tricky with current ApiService structure as data is global.
      // This is a limitation of testing singletons with global static mock data.
      // For now, tests will rely on the known initial state of mockFoodDatabase and add to _mockDailyMealLogs.
    });

    group('searchFoodItems', () {
      test('returns a few items (10) when query is empty', () async {
        final results = await apiService.searchFoodItems('');
        expect(results.length, mockFoodDatabase.take(10).length);
      });

      test('returns items matching name query (case-insensitive)', () async {
        final results = await apiService.searchFoodItems('apple');
        expect(results, isNotEmpty);
        expect(results.every((item) => item.name.toLowerCase().contains('apple')), isTrue);
      });

      test('returns items matching brand query (case-insensitive)', () async {
        // Assuming some items in mockFoodDatabase have brands
        // Add a branded item to the mock database for this test if one doesn't exist.
        // For now, this will pass if "Generic" items are found or if no brand matches.
        // This test depends on the content of mock_food_database.dart.
        // Let's assume an item with brand "Generic" exists.
        final results = await apiService.searchFoodItems('Generic');
        expect(results, isNotEmpty);
        expect(results.any((item) => item.brand.toLowerCase().contains('generic')), isTrue);
      });

      test('returns empty list if no match found', () async {
        final results = await apiService.searchFoodItems('NonExistentFoodItem123');
        expect(results, isEmpty);
      });
    });

    group('getFoodItemById', () {
      test('returns correct FoodItem if ID exists in mock database', () async {
        final firstItem = mockFoodDatabase.first;
        final result = await apiService.getFoodItemById(firstItem.id);
        expect(result, isNotNull);
        expect(result!.id, firstItem.id);
        expect(result.name, firstItem.name);
      });

      test('returns null if ID does not exist', () async {
        final result = await apiService.getFoodItemById('non-existent-id');
        expect(result, isNull);
      });
    });

    group('DailyMealLog Management', () {
      const testUserId = 'testUser123';
      final testDate = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(testDate);
      final storageKey = "${testUserId}_$dateKey";

      // Helper to clear the specific log entry for testing, due to global mock data
      Future<void> clearTestLog() async {
         // This is a conceptual way to clear. Direct modification of _mockDailyMealLogs
         // isn't possible from here without making it non-final or providing a clear method.
         // For now, we accept that logs might persist if not overwritten.
         // A better approach would be a reset method in ApiService for its mock stores.
      }

      setUp(() async {
        await clearTestLog(); // Attempt to clear before each sub-test
      });

      test('saveDailyMealLog and getDailyMealLog work correctly', () async {
        final mealLog = DailyMealLog(
          id: _uuid.v4(),
          userId: testUserId,
          date: testDate,
          meals: [], // Empty meals for simplicity
        );

        final savedLog = await apiService.saveDailyMealLog(mealLog);
        expect(savedLog.userId, testUserId);
        expect(savedLog.date, testDate);

        final fetchedLog = await apiService.getDailyMealLog(testUserId, testDate);
        expect(fetchedLog, isNotNull);
        expect(fetchedLog!.id, savedLog.id);
        expect(fetchedLog.dailyTotalCalories, 0); // Based on empty meals
      });

      test('getDailyMealLog returns null if no log for date/user', () async {
        final futureDate = DateTime.now().add(const Duration(days: 365)); // A date unlikely to have a log
        final fetchedLog = await apiService.getDailyMealLog(testUserId, futureDate);
        expect(fetchedLog, isNull);
      });

      test('getDailyMealLogsDateRange fetches logs within range', () async {
        final log1Date = DateTime(2023, 1, 1);
        final log2Date = DateTime(2023, 1, 2);
        final log3Date = DateTime(2023, 1, 5); // Outside typical initial range test

        final log1 = DailyMealLog(userId: testUserId, date: log1Date, meals: []);
        final log2 = DailyMealLog(userId: testUserId, date: log2Date, meals: []);
        final log3 = DailyMealLog(userId: testUserId, date: log3Date, meals: []);

        await apiService.saveDailyMealLog(log1);
        await apiService.saveDailyMealLog(log2);
        await apiService.saveDailyMealLog(log3);

        final results = await apiService.getDailyMealLogsDateRange(testUserId, log1Date, log2Date);
        expect(results.length, 2);
        expect(results.any((log) => log.date == log1Date), isTrue);
        expect(results.any((log) => log.date == log2Date), isTrue);
        expect(results.every((log) => log.date.isBefore(log2Date.add(const Duration(days:1))) &&
                                     log.date.isAfter(log1Date.subtract(const Duration(days:1)))), isTrue);
      });
    });
  });
}
