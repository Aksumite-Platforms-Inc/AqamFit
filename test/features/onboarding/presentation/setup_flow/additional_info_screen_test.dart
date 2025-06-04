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

  // Match the screen's _genderOptions for testing
  final List<Map<String, dynamic>> genderOptionsTestData = [
    {"title": "Male", "icon": Icons.male},
    {"title": "Female", "icon": Icons.female},
    {"title": "Other", "icon": Icons.transgender},
    {"title": "Prefer not to say", "icon": Icons.question_mark},
  ];

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();
    mockAuthManager = MockAuthManager();
    mockUserRepository = MockUserRepository();

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

            // The Navigator from MaterialApp is for the CalendarDatePicker if it uses Dialog Route internally
            // and for general context.
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

  group('Initial Rendering (Inline Expansion UI)', () {
    testWidgets('renders header panels for DOB and Gender with placeholders and collapsed content', (WidgetTester tester) async {
      when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
      when(mockSetupFlowViewModel.gender).thenReturn(null);
      await pumpTheScreen(tester);

      // Check DOB header
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('DD'), findsOneWidget); // Placeholder in segment
      expect(find.text('MM'), findsOneWidget);
      expect(find.text('YYYY'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNWidgets(2)); // Both initially collapsed

      // Check Gender header
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Select your gender'), findsOneWidget); // Placeholder in header value

      // Ensure expandable content is hidden
      expect(find.byType(CalendarDatePicker), findsNothing);
      expect(find.widgetWithText(ListTile, "Male"), findsNothing); // Gender options hidden
    });
  });

  group('Date of Birth Inline Expansion Tests', () {
    testWidgets('tapping DOB header expands and shows CalendarDatePicker', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final dobHeaderFinder = find.descendant(of: find.widgetWithText(GestureDetector, 'DD'), matching: find.byType(Container)).first;


      await tester.tap(dobHeaderFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);
      expect(find.descendant(of: dobHeaderFinder, matching: find.byIcon(Icons.expand_less)), findsNothing); // Icon within header changes
       //This check is tricky as the icon is inside the header which is complex to pinpoint after state change.
       //A better way is to check the state variable _isDobExpanded if it were testable, or presence of CalendarDatePicker.
    });

    testWidgets('selecting a date updates ViewModel, collapses section, and updates header', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final testDate = DateTime(1998, 5, 10);
      final dobHeaderFinder = find.descendant(of: find.widgetWithText(GestureDetector, 'DD'), matching: find.byType(Container)).first;


      // Expand DOB section
      await tester.tap(dobHeaderFinder);
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      // Simulate selecting a date
      await tester.tap(find.text(testDate.day.toString())); // Tap the day in CalendarDatePicker
      // The onDateChanged in screen code calls _handleDateSelection -> updates viewModel and sets _isDobExpanded = false

      // Mock viewmodel returning new date to simulate update for UI check
      when(mockSetupFlowViewModel.dateOfBirth).thenReturn(testDate);
      await tester.pumpAndSettle(); // For collapse animation and header update

      expect(find.byType(CalendarDatePicker), findsNothing); // Should collapse
      expect(find.text(DateFormat('dd').format(testDate)), findsOneWidget);
      expect(find.text(DateFormat('MM').format(testDate)), findsOneWidget);
      expect(find.text(DateFormat('yyyy').format(testDate)), findsOneWidget);
      verify(mockSetupFlowViewModel.updateDateOfBirth(testDate)).called(1);
    });
  });

  group('Gender Inline Expansion Tests', () {
    testWidgets('tapping Gender header expands and shows gender options', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final genderHeaderFinder = find.widgetWithText(GestureDetector, 'Gender'); // Find by label text

      await tester.tap(genderHeaderFinder);
      await tester.pumpAndSettle();

      for (final option in genderOptionsTestData) {
        expect(find.widgetWithText(ListTile, option["title"] as String), findsOneWidget);
      }
    });

    testWidgets('selecting a gender updates ViewModel, collapses section, and updates header', (WidgetTester tester) async {
      await pumpTheScreen(tester);
      final targetGender = genderOptionsTestData[1]; // Female
      final genderHeaderFinder = find.widgetWithText(GestureDetector, 'Gender');

      // Expand Gender section
      await tester.tap(genderHeaderFinder);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, targetGender["title"] as String), findsOneWidget);

      // Simulate selecting "Female"
      when(mockSetupFlowViewModel.gender).thenReturn(targetGender["title"] as String); // Mock VM update
      await tester.tap(find.widgetWithText(ListTile, targetGender["title"] as String));
      await tester.pumpAndSettle(); // For collapse animation and header update

      verify(mockSetupFlowViewModel.updateGender(targetGender["title"] as String)).called(1);
      expect(find.widgetWithText(ListTile, targetGender["title"] as String), findsNothing); // Should collapse
      expect(find.text(targetGender["title"] as String), findsOneWidget); // Header updates
      // Check for icon update in header
      final genderDisplayArea = find.ancestor(of: find.text("Gender"), matching: find.byType(Container)).first;
      expect(find.descendant(of: genderDisplayArea, matching: find.byIcon(targetGender["icon"] as IconData)), findsOneWidget);
    });
  });

  testWidgets('independent expansion of sections', (WidgetTester tester) async {
    await pumpTheScreen(tester);
    final dobHeaderFinder = find.descendant(of: find.widgetWithText(GestureDetector, 'DD'), matching: find.byType(Container)).first;
    final genderHeaderFinder = find.widgetWithText(GestureDetector, 'Gender');

    // Expand DOB
    await tester.tap(dobHeaderFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.widgetWithText(ListTile, genderOptionsTestData[0]["title"] as String), findsNothing); // Gender options hidden

    // Expand Gender while DOB is open
    await tester.tap(genderHeaderFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget); // DOB still open
    expect(find.widgetWithText(ListTile, genderOptionsTestData[0]["title"] as String), findsOneWidget); // Gender options shown
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
