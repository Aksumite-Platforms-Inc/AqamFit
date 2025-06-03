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

// Helper to mock showDatePicker
// This is a common pattern. You'd typically put this in a test utility file.
Future<DateTime?> mockShowDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  Widget? builder, // Added to match signature if screen uses it
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType, // Added
  DateTime? currentDate, // Added
}) {
  return showDatePickerMockResponse ?? Future.value(null); // Default to null if not overridden
}

DateTime? showDatePickerMockResponse;


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

  final List<String> gendersList = ["Male", "Female", "Other", "Prefer not to say"];


  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();
    mockAuthManager = MockAuthManager();
    mockUserRepository = MockUserRepository();
    showDatePickerMockResponse = null; // Reset mock response

    // Default stubs for ViewModel
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(null);
    when(mockSetupFlowViewModel.gender).thenReturn(null);
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
                  // Override showDatePicker for this widget tree
                  child: Builder(
                    builder: (context) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: MediaQuery( // DatePicker needs MediaQuery
                          data: MediaQueryData(),
                          child: Navigator( // DatePicker needs Navigator
                            onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const AdditionalInfoScreen()),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
              GoRoute(path: '/main', builder: (context, state) => const Scaffold(body: Text("Mock Main Page"))),
            ],
          ),
        ),
      ),
    );
  }

  // It's tricky to use the above pumpHelper with a custom showDatePicker override that's not global.
  // For showDatePicker mocking, it's often easier to mock it at a higher level or ensure
  // the context used by showDatePicker can be influenced, or test the callback.
  // The screen calls `_selectDate(context, viewModel)` which calls `showDatePicker`.
  // We can test that tapping the ListTile calls `_selectDate`.
  // For testing the *result* of `_selectDate`, we'd need to control `showDatePicker`.

  // Let's simplify the pump helper for showDatePicker mocking by not nesting RouterScope + Navigator for it.
  // We will rely on the global mock for showDatePicker.
   Future<void> pumpAdditionalInfoScreenForDatePickerTest(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
          Provider<AuthManager>.value(value: mockAuthManager),
          Provider<UserRepository>.value(value: mockUserRepository),
        ],
        child: MaterialApp( // Use simple MaterialApp for date picker test
          home: RouterScope.override( // Still need RouterScope for context.go
             context: tester.element(find.byType(MaterialApp)) , // This context might be tricky
             router: mockGoRouter,
             state: GoRouterState(uri: Uri.parse('/'), pathParameters: const {}, configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration),
             configuration: GoRoute(path: '/', builder: (_, __) => const AdditionalInfoScreen()).configuration,
            child: const AdditionalInfoScreen()),
        ),
      ),
    );
  }


  testWidgets('renders ListTile for DOB and ChoiceChips for Gender', (WidgetTester tester) async {
    await pumpAdditionalInfoScreen(tester);

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Select your date of birth'), findsOneWidget); // Initial text in ListTile
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    for (final gender in gendersList) {
      expect(find.widgetWithText(ChoiceChip, gender), findsOneWidget);
    }
    expect(find.byIcon(Icons.wc), findsNothing); // Prefix icon removed from Dropdown
    expect(find.widgetWithText(ElevatedButton, 'Finish Setup'), findsOneWidget);
  });

  testWidgets('tapping ListTile for DOB eventually calls ViewModel update if date selected', (WidgetTester tester) async {
    // This test relies on a global override or a way to mock showDatePicker.
    // For this example, we'll assume a simplified global mock `showDatePickerMockResponse`.
    final testDate = DateTime(2000, 1, 15);
    showDatePickerMockResponse = Future.value(testDate); // Mock showDatePicker to return this date

    await pumpAdditionalInfoScreenForDatePickerTest(tester); // Use specialized pumper if needed

    // Stub what the ViewModel's dateOfBirth getter will return *after* it's updated
    when(mockSetupFlowViewModel.dateOfBirth).thenReturn(testDate);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle(); // Allow for state changes after date picker (mocked) closes

    verify(mockSetupFlowViewModel.updateDateOfBirth(testDate)).called(1);
    expect(find.text(DateFormat('MMMM d, yyyy').format(testDate)), findsOneWidget);

    showDatePickerMockResponse = null; // Clean up
  });

  testWidgets('selecting Gender ChoiceChip updates ViewModel and UI', (WidgetTester tester) async {
    await pumpAdditionalInfoScreen(tester);
    final String testGender = gendersList[1]; // "Female"

    // Simulate ViewModel update for UI check
    when(mockSetupFlowViewModel.gender).thenReturn(testGender);

    await tester.tap(find.widgetWithText(ChoiceChip, testGender));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateGender(testGender)).called(1);

    // Check if the chip is selected
    final ChoiceChip chip = tester.widget(find.widgetWithText(ChoiceChip, testGender));
    expect(chip.selected, isTrue);
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
    await tester.pumpAndSettle(); // Clear previous snackbar

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
