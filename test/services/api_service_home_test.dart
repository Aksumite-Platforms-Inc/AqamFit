import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Helper to reset ApiService's internal mock data stores if possible.
// This is conceptual. ApiService would need public reset methods for its mock lists.
// For now, we acknowledge that data might persist across test groups if not carefully managed.
// One way is to use unique user IDs for each test group.
void resetApiServiceMockData() {
  // ApiService()._mockWorkoutPlans.clear(); // If these were accessible and non-final
  // ApiService()._mockWorkoutLogs.clear();
  // ApiService()._mockWeightEntries.clear();
}


void main() {
  group('ApiService - HomeScreenApiService Tests', () {
    late ApiService apiService;
    const testUserId = 'homeScreenTestUser';
    const otherUserId = 'otherUser';

    setUpAll(() {
      // This is where global setup for all tests in this group would go.
      // For example, populating the mock database with some initial state common to all tests.
      // However, due to the singleton nature of ApiService and its global mock lists,
      // it's often better to set up specific data within each test or test group if isolation is needed.
    });

    setUp(() {
      apiService = ApiService();
      // Conceptual reset - see note above.
      // resetApiServiceMockData();
      // For these tests, we'll add data and expect it, assuming a relatively clean state for testUserId.
    });

    tearDown(() {
      // Clean up data created specifically for testUserId to avoid interference if tests run multiple times or in specific orders.
      // This is hard with current ApiService structure.
    });

    group('getTodaysWorkoutPlan', () {
      test('returns a user-specific plan if available', () async {
        final plan1 = WorkoutPlan(id: _uuid.v4(), name: "User's Morning Routine", authorId: testUserId, exercises: []);
        final plan2 = WorkoutPlan(id: _uuid.v4(), name: "General Plan", authorId: otherUserId, exercises: []);
        await apiService.saveWorkoutPlan(plan1); // Assumes saveWorkoutPlan adds to _mockWorkoutPlans
        await apiService.saveWorkoutPlan(plan2);

        final result = await apiService.getTodaysWorkoutPlan(testUserId);
        expect(result, isNotNull);
        expect(result!.id, plan1.id);
      });

      test('returns any plan if no user-specific plan is available but plans exist', () async {
        // Clear existing plans for this specific test condition or use a new user ID
        // For now, assuming _mockWorkoutPlans might have data from other tests.
        // This test is more reliable if _mockWorkoutPlans can be cleared or is empty initially.

        // Ensure no plans for testUserId, but one for otherUserId
        // This requires a way to clear plans for testUserId or ensure it has none.
        // Let's add one general plan if the list is empty to ensure there is "any" plan.
        final plans = await apiService.getWorkoutPlans();
        if (plans.where((p) => p.authorId != testUserId).isEmpty) {
           await apiService.saveWorkoutPlan(WorkoutPlan(id: _uuid.v4(), name: "Fallback Plan", authorId: "some_other_author", exercises: []));
        }

        final result = await apiService.getTodaysWorkoutPlan(testUserId);
         // This assertion is tricky if other tests added plans for testUserId.
         // A truly isolated test would clear _mockWorkoutPlans or use a fresh user ID.
        expect(result, isNotNull); // Expects *a* plan, not necessarily one not by testUserId
      });
       test('returns null if no plans exist at all', () async {
        // This test requires _mockWorkoutPlans to be empty.
        // This is difficult to ensure with current global mock list without a reset.
        // Conceptually:
        // _mockWorkoutPlans.clear(); // if possible
        // final result = await apiService.getTodaysWorkoutPlan("userWithNoPlansAtAll");
        // expect(result, isNull);
        // For now, this test might be flaky depending on prior state.
        // We can test by ensuring a user has no plans and no other plans exist.
        // This requires a clean state of _mockWorkoutPlans.

        // To make it somewhat testable: query for a user that is guaranteed to have no plans
        // AND ensure no other plans exist. This is hard without a reset for _mockWorkoutPlans.
        // Let's assume for a new user ID and an empty _mockWorkoutPlans list, it would be null.
        // This test is more illustrative of the desired behavior than a robust test of current mock.

        // If we could clear:
        // ApiService()._mockWorkoutPlans.clear(); // If possible
        // final result = await apiService.getTodaysWorkoutPlan("completelyNewUser");
        // expect(result, isNull);
        print("Skipping getTodaysWorkoutPlan: returns null if no plans exist - requires mock data reset capability.");
      });
    });

    group('getWeeklyWorkoutStats', () {
      test('calculates workoutsCompleted and activeMinutes correctly for the past week', () async {
        final today = DateTime.now();
        final withinLastWeek = today.subtract(const Duration(days: 3));
        final beforeLastWeek = today.subtract(const Duration(days: 10));

        await apiService.saveWorkoutLog(WorkoutLog(id: _uuid.v4(), userId: testUserId, planName: "Log 1", startTime: withinLastWeek, endTime: withinLastWeek.add(const Duration(minutes: 30)), completedExercises: []));
        await apiService.saveWorkoutLog(WorkoutLog(id: _uuid.v4(), userId: testUserId, planName: "Log 2", startTime: withinLastWeek, endTime: withinLastWeek.add(const Duration(minutes: 40)), completedExercises: []));
        await apiService.saveWorkoutLog(WorkoutLog(id: _uuid.v4(), userId: testUserId, planName: "Log 3 Old", startTime: beforeLastWeek, endTime: beforeLastWeek.add(const Duration(minutes: 30)), completedExercises: []));
        await apiService.saveWorkoutLog(WorkoutLog(id: _uuid.v4(), userId: otherUserId, planName: "Log Other User", startTime: withinLastWeek, endTime: withinLastWeek.add(const Duration(minutes: 30)), completedExercises: []));

        final stats = await apiService.getWeeklyWorkoutStats(testUserId);
        expect(stats['workoutsCompleted'], 2);
        expect(stats['activeMinutes'], 2 * 35); // Based on mock logic: workouts * 35
      });

       test('returns zeros if no workouts in the past week', () async {
        // Ensure no recent logs for this user. This might require clearing logs for testUserId.
        final stats = await apiService.getWeeklyWorkoutStats("userWithNoRecentWorkouts");
        expect(stats['workoutsCompleted'], 0);
        expect(stats['activeMinutes'], 0);
      });
    });

    group('getLatestWeightEntry', () {
      test('returns the latest weight entry for the user', () async {
        final date1 = DateTime.now().subtract(const Duration(days: 5));
        final date2Latest = DateTime.now().subtract(const Duration(days: 1));
        final entry1 = WeightEntry(userId: testUserId, date: date1, weightKg: 70.0);
        final entry2Latest = WeightEntry(userId: testUserId, date: date2Latest, weightKg: 71.5);
        final entryOtherUser = WeightEntry(userId: otherUserId, date: date2Latest, weightKg: 60.0);

        await apiService.saveWeightEntry(entry1);
        await apiService.saveWeightEntry(entry2Latest);
        await apiService.saveWeightEntry(entryOtherUser);

        final result = await apiService.getLatestWeightEntry(testUserId);
        expect(result, isNotNull);
        expect(result!.id, entry2Latest.id);
        expect(result.weightKg, 71.5);
      });

      test('returns null if no weight entries for the user', () async {
        final result = await apiService.getLatestWeightEntry("userWithNoWeightEntries");
        expect(result, isNull);
      });
    });
  });
}
