import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/training_prefs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../mocks/mock_view_models.dart';
import '../../../../mocks/mock_router.dart';

void main() {
  late MockSetupFlowViewModel mockSetupFlowViewModel;
  late MockGoRouter mockGoRouter;

  // Helper data matching the screen's _days list
  final List<Map<String, String>> dayPreferences = [
    {"abbr": "S", "fullName": "Sunday"},
    {"abbr": "M", "fullName": "Monday"},
    {"abbr": "T", "fullName": "Tuesday"},
    {"abbr": "W", "fullName": "Wednesday"},
    {"abbr": "T", "fullName": "Thursday"},
    {"abbr": "F", "fullName": "Friday"},
    {"abbr": "S", "fullName": "Saturday"},
  ];

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Initial state: no days selected
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]);
    
    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpTrainingPrefsScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-training-prefs',
            routes: [
              GoRoute(
                path: '/test-training-prefs',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const TrainingPrefsScreen()).configuration,
                  state: GoRouterState(uri: Uri.parse('/test-training-prefs'), pathParameters: const {}, configuration: GoRoute(path: '/', builder: (_, __) => const TrainingPrefsScreen()).configuration),
                  router: mockGoRouter,
                  child: const TrainingPrefsScreen(),
                ),
              ),
              GoRoute(path: '/setup/additional-info', builder: (context, state) => const Scaffold(body: Text("Mock Additional Info"))),
              // Add previous route if needed for back button testing, e.g. /setup/experience-level
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders circular weekday buttons', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);

    for (final dayMap in dayPreferences) {
      // Need to be careful with duplicate abbreviations "S" and "T"
      // Finding by text might find multiple. We expect one for each instance.
      expect(find.widgetWithText(AnimatedContainer, dayMap["abbr"]!), findsWidgets);
    }
    // Check total count of day buttons
    expect(find.byType(GestureDetector).descendantOf(find.byType(Row).first), findsNWidgets(dayPreferences.length));
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
  });

  testWidgets('tapping a day button toggles selection and updates ViewModel', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);

    final mondayAbbr = dayPreferences[1]["abbr"]!; // "M"
    final mondayFullName = dayPreferences[1]["fullName"]!; // "Monday"

    // Simulate ViewModel returning empty list initially for "isSelected" check
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]);
    await tester.pumpAndSettle(); // Re-pump after stubbing if needed, or ensure initial stub is set.

    // Find the specific GestureDetector for Monday
    // This is tricky due to duplicate abbreviations. We might need more specific finders if this fails.
    // A safer way is to find all GestureDetectors in the Row and tap the Nth one.
    final dayButtonFinders = find.descendant(
      of: find.byType(Row).at(0), // Assuming days are in the first Row
      matching: find.byType(GestureDetector)
    );
    expect(dayButtonFinders, findsNWidgets(7));
    final mondayButtonFinder = dayButtonFinders.at(1); // Monday is the 2nd item (index 1)

    // Initial state: Monday is not selected
    // We check the color of the AnimatedContainer's decoration
    AnimatedContainer mondayContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: mondayButtonFinder, matching: find.byType(AnimatedContainer))
    );
    BoxDecoration decoration = mondayContainer.decoration as BoxDecoration;
    expect(decoration.color, Theme.of(tester.element(mondayButtonFinder)).colorScheme.surfaceVariant.withOpacity(0.5));


    // Tap Monday to select it
    // Simulate ViewModel updating and returning the new list
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([mondayFullName]);
    await tester.tap(mondayButtonFinder);
    await tester.pumpAndSettle(); // For animation and rebuild

    verify(mockSetupFlowViewModel.toggleTrainingDay(mondayFullName)).called(1);
    
    // Verify Monday is selected (e.g., color change)
    mondayContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: mondayButtonFinder, matching: find.byType(AnimatedContainer))
    );
    decoration = mondayContainer.decoration as BoxDecoration;
    expect(decoration.color, Theme.of(tester.element(mondayButtonFinder)).colorScheme.primary);

    // Tap Monday again to deselect it
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]); // Now it's empty again
    await tester.tap(mondayButtonFinder);
    await tester.pumpAndSettle();
    
    verify(mockSetupFlowViewModel.toggleTrainingDay(mondayFullName)).called(1); // Called again

    // Verify Monday is not selected
     mondayContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: mondayButtonFinder, matching: find.byType(AnimatedContainer))
    );
    decoration = mondayContainer.decoration as BoxDecoration;
    expect(decoration.color, Theme.of(tester.element(mondayButtonFinder)).colorScheme.surfaceVariant.withOpacity(0.5));
  });

  testWidgets('"Next" button navigates to /setup/additional-info', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockGoRouter.go('/setup/additional-info')).called(1);
  });

  testWidgets('TextButton "Back" button pops the current route', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);
    
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();

    verify(mockGoRouter.pop()).called(1);
  });

  testWidgets('AppBar "Back" button pops the current route', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);
    
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    verify(mockGoRouter.pop()).called(1);
  });
}
