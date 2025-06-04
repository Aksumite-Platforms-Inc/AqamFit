import 'package:aksumfit/features/onboarding/presentation/setup_flow/additional_info_screen.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/repositories/user_repository.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart'; // For potential Cupertino dialogs if showDatePicker uses them by default on iOS style.

import '../../../../mocks/mock_view_models.dart';
import '../../../../mocks/mock_router.dart';
import '../../../../mocks/mock_services.dart';

// No longer mocking showDatePicker globally here, as CalendarDatePicker is used directly.

void main() {
  late MockSetupFlowViewModel mockSetupFlowViewModel;
  late MockGoRouter mockGoRouter;
  late MockAuthManager mockAuthManager;
  late MockUserRepository mockUserRepository;

  final testUser = User(id: 'test-user-id', email: 'test@example.com', username: 'testuser', hasCompletedOnboarding: false, hasCompletedSetup: false);
  final updatedTestUser = testUser.copyWith(hasCompletedSetup: true);


  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();
    mockAuthManager = MockAuthManager();
    mockUserRepository = MockUserRepository();

    // Default stubs for ViewModel
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
    when(mockSetupFlowViewModel.gender).thenReturn(null);
    // Provide other viewmodel defaults if they are read during build
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn('Lose Weight');
    when(mockSetupFlowViewModel.experienceLevel).thenReturn('Beginner');
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(['Monday']);


    // Default stubs for AuthManager
    when(mockAuthManager.currentUser).thenReturn(testUser);

    // Default stubs for GoRouter
    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpAdditionalInfoScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
          Provider<AuthManager>.value(value: mockAuthManager),
          Provider<UserRepository>.value(value: mockUserRepository),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-additional-info',
            routes: [
              GoRoute(
                path: '/test-additional-info',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration,
                  state: GoRouterState(uri: Uri.parse('/test-additional-info'), pathParameters: const {},configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration),
                  router: mockGoRouter,
                  child: const AdditionalInfoScreen(),
                ),
              ),
              GoRoute(path: '/main', builder: (context, state) => const Scaffold(body: Text("Mock Main Page"))),
            ],
          ),
        ),
      ),
    );
  }

  // This list should match the _genderOptions in the screen for titles
  final List<String> genderTitlesFromScreen = [
    "Male", "Female", "Other", "Prefer not to say"
  ];


  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();
    mockAuthManager = MockAuthManager();
    mockUserRepository = MockUserRepository();
    // showDatePickerMockResponse = null; // No longer needed

    // Default stubs for ViewModel
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
    when(mockSetupFlowViewModel.gender).thenReturn(null);
    // Other ViewModel properties are not directly tested by this screen but might be needed by _finishSetup
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn('Lose Weight');
    when(mockSetupFlowViewModel.experienceLevel).thenReturn('Beginner');
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(['Monday']);


    when(mockAuthManager.currentUser).thenReturn(testUser);
    when(mockGoRouter.canPop()).thenReturn(true);
  });

  // Re-usable pumper function for this test suite
  Future<void> pumpTheScreen(WidgetTester tester) async {
    // For showDatePicker mocking, we need a Navigator above the screen.
    // The screen itself doesn't have one if it's part of a GoRouter route.
    // So, we wrap with MaterialApp for the test.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
          Provider<AuthManager>.value(value: mockAuthManager),
          Provider<UserRepository>.value(value: mockUserRepository),
        ],
        child: MaterialApp( // MaterialApp provides a Navigator
          home: RouterScope.override( // Still use RouterScope for context.go
            // A bit contrived to get a context for RouterScope here.
            // Ideally, the GoRouter instance itself would be injectable for testing.
            // For simplicity, we'll assume context.go() will find this.
            // This context for RouterScope.override might not be perfectly analogous to real app.
            // However, `context.go` is the main concern for mocking here.
            // Note: `tester.element(find.byType(AdditionalInfoScreen))` could provide a context,
            // but that's after the first pump.
            // A simpler MaterialApp.router setup might be better if not for showDatePicker.
            // Let's use a simpler pump that assumes GoRouter is available via Provider or similar.
            // The previous complex pump was an attempt to solve showDatePicker context issues.
            // Given we are mocking showDatePicker globally, a simpler pump is fine.
            // The `RouterScope.override` is mainly for `context.go`.
            // The `Navigator` from `MaterialApp` is for `showDatePicker`.

            // Using a simple MaterialApp and providing GoRouter via Provider for `context.go`
            // This is a common pattern if not testing deep GoRouter functionalities.
            // Using a simple MaterialApp and providing GoRouter via RouterScope.override
            // for `context.go` and `context.pop`.
            // The Navigator from MaterialApp is for showModalBottomSheet.
            child: RouterScope.override(
              configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration,
              state: GoRouterState(uri: Uri.parse('/'), pathParameters: const {}, configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration),
              router: mockGoRouter,
              child: const AdditionalInfoScreen()
            )
          ),
        ),
      ),
    );
  }

  group('Main Screen Rendering (Bottom Sheet UI)', () {
    testWidgets('renders tappable areas for DOB and Gender with placeholders', (WidgetTester tester) async {
      when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
      when(mockSetupFlowViewModel.gender).thenReturn(null);
      await pumpTheScreen(tester);

      // Check DOB display
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Select your date of birth'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);

      // Check Gender display
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Select your gender'), findsOneWidget);
      expect(find.byIcon(Icons.wc), findsOneWidget); // Default icon for gender

      expect(find.widgetWithText(ElevatedButton, 'Finish Setup'), findsOneWidget);
    });

    testWidgets('renders formatted date and selected gender when available', (WidgetTester tester) async {
      final testDate = DateTime(1995, 7, 20);
      const testGender = "Female";
      when(mockSetupFlowViewModel.dateOfBirth).thenReturn(testDate);
      when(mockSetupFlowViewModel.gender).thenReturn(testGender);
      await pumpTheScreen(tester);

      expect(find.text(DateFormat('MMMM d, yyyy').format(testDate)), findsOneWidget);
      expect(find.text(testGender), findsOneWidget);
      expect(find.byIcon(Icons.female), findsOneWidget); // Icon specific to "Female"
    });
  });

  group('Bottom Sheet Interactions', () {
    testWidgets('tapping DOB area opens bottom sheet and updates ViewModel on date selection', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final testDate = DateTime(1998, 5, 10);

      // Tap the DOB selection button
      await tester.tap(find.text('Date of Birth'));
      await tester.pumpAndSettle(); // Wait for bottom sheet to animate in

      // Verify bottom sheet content (CalendarDatePicker)
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.text('Select Date of Birth'), findsOneWidget); // Title in sheet

      // Simulate selecting a date in CalendarDatePicker
      // This is the tricky part. CalendarDatePicker's onDateChanged is internal.
      // We'll find a date and tap it. This assumes default calendar view.
      // For more robust test, keys on CalendarDatePicker elements might be needed.
      await tester.tap(find.text(testDate.day.toString())); // Tap the day
      await tester.pumpAndSettle(); // Wait for sheet to close & main screen to update

      // Verify ViewModel was updated and sheet is closed
      verify(mockSetupFlowViewModel.updateDateOfBirth(any)).called(1); // `any` because exact DateTime object might differ slightly
      expect(find.byType(CalendarDatePicker), findsNothing);

      // Verify main screen display updated (requires mock to return new date)
      when(mockSetupFlowViewModel.dateOfBirth).thenReturn(testDate);
      await tester.pumpAndSettle(); // Rebuild screen with new ViewModel state
      expect(find.text(DateFormat('MMMM d, yyyy').format(testDate)), findsOneWidget);
    });

    testWidgets('tapping Gender area opens bottom sheet and updates ViewModel on gender selection', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final targetGender = genderTitlesFromScreen[1]; // "Female"

      await tester.tap(find.text('Gender'));
      await tester.pumpAndSettle();

      // Verify bottom sheet content (ListView of gender options)
      expect(find.text('Select Gender'), findsOneWidget); // Title in sheet
      for (final genderTitle in genderTitlesFromScreen) {
        expect(find.widgetWithText(ListTile, genderTitle), findsOneWidget);
      }

      // Tap the "Female" ListTile
      await tester.tap(find.widgetWithText(ListTile, targetGender));
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.updateGender(targetGender)).called(1);
      expect(find.byType(ListView), findsNothing); // Sheet should be closed

      // Verify main screen display updated
      when(mockSetupFlowViewModel.gender).thenReturn(targetGender);
      await tester.pumpAndSettle();
      expect(find.text(targetGender), findsOneWidget);
      expect(find.byIcon(Icons.female), findsOneWidget); // Check for specific icon update
    });
  });

  testWidgets('validation: shows SnackBar if fields are empty on Finish', (WidgetTester tester) async {
    await pumpAdditionalInfoScreen(tester);
    // Ensure viewmodel returns null for date and gender to trigger validation
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
    when(mockSetupFlowViewModel.gender).thenReturn(null);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish Setup'));
    await tester.pumpAndSettle();

    // Expect first SnackBar for date of birth
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please select your date of birth.'), findsOneWidget);
    verifyNever(mockUserRepository.updateUserProfileSetup(any)); // Should not proceed

    // Now set date of birth, but keep gender null
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(DateTime.now());
    // Must clear the previous SnackBar by pumping it away or triggering a rebuild that removes it.
    await tester.pump(const Duration(seconds: 1)); // Let SnackBar display
    await tester.pump(const Duration(seconds: 1)); // Let SnackBar hide (default is 4s)
    await tester.pumpAndSettle(); // Ensure it's gone

    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish Setup'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please select your gender.'), findsOneWidget);
    verifyNever(mockUserRepository.updateUserProfileSetup(any));
  });

  testWidgets('"Finish Setup" button calls repo and auth manager on success, then navigates', (WidgetTester tester) async {
    final selectedDate = DateTime(1990, 1, 1);
    final selectedGender = "Male";

    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(selectedDate);
    when(mockSetupFlowViewModel.gender).thenReturn(selectedGender);
    when(mockUserRepository.updateUserProfileSetup(
      userId: testUser.id,
      weight: anyNamed('weight'),
      weightUnit: anyNamed('weightUnit'),
      height: anyNamed('height'),
      heightUnit: anyNamed('heightUnit'),
      fitnessGoal: anyNamed('fitnessGoal'),
      experienceLevel: anyNamed('experienceLevel'),
      preferredTrainingDays: anyNamed('preferredTrainingDays'),
      dateOfBirth: selectedDate,
      gender: selectedGender,
    )).thenAnswer((_) async => updatedTestUser);
    when(mockAuthManager.completeOnboardingSetup(updatedTestUser)).thenAnswer((_) async {});

    await pumpAdditionalInfoScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish Setup'));
    await tester.pump(); // Show loading indicator

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle(); // Complete async operations

    verify(mockUserRepository.updateUserProfileSetup(
      userId: testUser.id,
      weight: mockSetupFlowViewModel.weight,
      weightUnit: mockSetupFlowViewModel.weightUnit,
      height: mockSetupFlowViewModel.height,
      heightUnit: mockSetupFlowViewModel.heightUnit,
      fitnessGoal: mockSetupFlowViewModel.fitnessGoal,
      experienceLevel: mockSetupFlowViewModel.experienceLevel,
      preferredTrainingDays: mockSetupFlowViewModel.preferredTrainingDays,
      dateOfBirth: selectedDate,
      gender: selectedGender,
    )).called(1);
    verify(mockAuthManager.completeOnboardingSetup(updatedTestUser)).called(1);
    verify(mockGoRouter.go('/main')).called(1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('"Finish Setup" shows SnackBar on repository failure', (WidgetTester tester) async {
    final selectedDate = DateTime(1990, 1, 1);
    final selectedGender = "Male";
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(selectedDate);
    when(mockSetupFlowViewModel.gender).thenReturn(selectedGender);
    when(mockUserRepository.updateUserProfileSetup(any)).thenAnswer((_) async => null); // Simulate failure

    await pumpAdditionalInfoScreen(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish Setup'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Failed to save profile. Please try again.'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });

   testWidgets('"Finish Setup" shows SnackBar on exception', (WidgetTester tester) async {
    final selectedDate = DateTime(1990, 1, 1);
    final selectedGender = "Male";
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(selectedDate);
    when(mockSetupFlowViewModel.gender).thenReturn(selectedGender);
    final exceptionMessage = 'Network error';
    when(mockUserRepository.updateUserProfileSetup(any)).thenThrow(Exception(exceptionMessage));

    await pumpAdditionalInfoScreen(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish Setup'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('An error occurred: Exception: $exceptionMessage'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });


  testWidgets('AppBar "Back" button pops', (WidgetTester tester) async {
    await pumpAdditionalInfoScreen(tester);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockGoRouter.pop()).called(1);
  });

  testWidgets('Text "Back" button pops', (WidgetTester tester) async {
    await pumpAdditionalInfoScreen(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();
    verify(mockGoRouter.pop()).called(1);
  });
}
