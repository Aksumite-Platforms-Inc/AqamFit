import 'package:aksumfit/features/onboarding/presentation/setup_flow/fitness_goal_screen.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
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
  const List<String> fitnessGoals = [ // Must match the ones in FitnessGoalScreen
    "Lose Weight", "Build Muscle", "Maintenance", "Improve Endurance", "Overall Health",
  ];

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Default stubs for ViewModel
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(null);
    // Ensure other properties accessed by any screen are given default values if necessary
    // For FitnessGoalScreen, only fitnessGoal is directly relevant from the ViewModel for its primary function.

    // Default stub for go_router's canPop
    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpFitnessGoalScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-fitness-goal',
            routes: [
              GoRoute(
                path: '/test-fitness-goal',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const FitnessGoalScreen()).configuration,
                  state: GoRouterState(uri: Uri.parse('/test-fitness-goal'), pathParameters: const {}, configuration: GoRoute(path: '/', builder: (_, __) => const FitnessGoalScreen()).configuration),
                  router: mockGoRouter,
                  child: const FitnessGoalScreen(),
                ),
              ),
              GoRoute(path: '/setup/experience-level', builder: (context, state) => const Scaffold(body: Text("Mock Experience Level"))),
              GoRoute(path: '/setup/weight-height', builder: (context, state) => const Scaffold(body: Text("Mock Weight Height"))),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders fitness goal cards', (WidgetTester tester) async {
    await pumpFitnessGoalScreen(tester);

    for (final goalTitle in fitnessGoals) {
      expect(find.text(goalTitle), findsOneWidget);
      // Also check for an icon within the card containing this text.
      // This assumes a Column structure: Card -> InkWell -> Padding -> Column -> [Icon, SizedBox, Text]
      final cardFinder = find.ancestor(of: find.text(goalTitle), matching: find.byType(Card));
      expect(find.descendant(of: cardFinder, matching: find.byType(Icon)), findsOneWidget);
    }
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('selecting a goal updates its appearance (text, icon color) and ViewModel', (WidgetTester tester) async {
    await pumpFitnessGoalScreen(tester);

    final targetGoalTitle = fitnessGoals[1]; // "Build Muscle"

    // Before selection
    Text unselectedTextWidget = tester.widget<Text>(find.text(targetGoalTitle));
    expect(unselectedTextWidget.style?.fontWeight, FontWeight.normal);

    final cardFinderUnselected = find.ancestor(of: find.text(targetGoalTitle), matching: find.byType(Card));
    Icon unselectedIconWidget = tester.widget<Icon>(find.descendant(of: cardFinderUnselected, matching: find.byType(Icon)));
    // Assuming default icon color is onSurfaceVariant based on screen code
    expect(unselectedIconWidget.color, Theme.of(tester.element(cardFinderUnselected)).colorScheme.onSurfaceVariant);


    // Simulate ViewModel update for UI check
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(targetGoalTitle);

    await tester.tap(find.text(targetGoalTitle));
    // The screen uses setState for _selectedGoalTitle, then calls viewmodel.
    // The watch on viewModel.fitnessGoal will then rebuild with the updated value from viewmodel.
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateFitnessGoal(targetGoalTitle)).called(1);

    // After selection
    final Text selectedTextWidget = tester.widget<Text>(find.text(targetGoalTitle));
    expect(selectedTextWidget.style?.fontWeight, FontWeight.bold);
    expect(selectedTextWidget.style?.color, Theme.of(tester.element(find.text(targetGoalTitle))).colorScheme.primary);

    final cardFinderSelected = find.ancestor(of: find.text(targetGoalTitle), matching: find.byType(Card));
    final Icon selectedIconWidget = tester.widget<Icon>(find.descendant(of: cardFinderSelected, matching: find.byType(Icon)));
    expect(selectedIconWidget.color, Theme.of(tester.element(cardFinderSelected)).colorScheme.primary);

    // Verify another goal is not selected
    final unselectedGoalTitle = fitnessGoals[0];
    final Text stillUnselectedTextWidget = tester.widget<Text>(find.text(unselectedGoalTitle));
    expect(stillUnselectedTextWidget.style?.fontWeight, FontWeight.normal);
     final cardFinderStillUnselected = find.ancestor(of: find.text(unselectedGoalTitle), matching: find.byType(Card));
    final Icon stillUnselectedIconWidget = tester.widget<Icon>(find.descendant(of: cardFinderStillUnselected, matching: find.byType(Icon)));
    expect(stillUnselectedIconWidget.color, Theme.of(tester.element(cardFinderStillUnselected)).colorScheme.onSurfaceVariant);
  });


  testWidgets('"Next" button navigates if a goal is selected', (WidgetTester tester) async {
    final selectedGoal = fitnessGoals[0];
    // Screen's initState reads this, then `_onNext` also reads it from local state `_selectedGoalTitle`
    // which should have been set by a tap or pre-filled from viewmodel.
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(selectedGoal);

    await pumpFitnessGoalScreen(tester);

    // Ensure the local state _selectedGoalTitle is set, mimicking a selection or initState behavior
    // This is needed because _onNext uses the local _selectedGoalTitle.
    // If we rely on initState, it's fine. If we want to simulate a fresh selection:
    // await tester.tap(find.text(selectedGoal));
    // await tester.pumpAndSettle();
    // The when(mockGoRouter.fitnessGoal) will make the UI reflect selection.

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    // _onNext calls updateFitnessGoal with its local _selectedGoalTitle.
    // If _selectedGoalTitle was set from viewModel.fitnessGoal in initState/build, this is correct.
    verify(mockSetupFlowViewModel.updateFitnessGoal(selectedGoal)).called(1);
    verify(mockGoRouter.go('/setup/experience-level')).called(1);
  });

  testWidgets('"Next" button shows SnackBar if no goal is selected', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(null); // No goal selected

    await pumpFitnessGoalScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle(); // For SnackBar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please select a fitness goal.'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });

  testWidgets('AppBar "Back" button pops or navigates to /setup/weight-height', (WidgetTester tester) async {
    await pumpFitnessGoalScreen(tester);

    // Case 1: Can pop
    when(mockGoRouter.canPop()).thenReturn(true);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    // _onBack calls updateFitnessGoal(currentSelection) then context.pop()
    verify(mockSetupFlowViewModel.updateFitnessGoal(null)).called(1); // Assuming null was initial selection
    verify(mockGoRouter.pop()).called(1);
    clearInteractions(mockGoRouter); // Clear for next verification
    clearInteractions(mockSetupFlowViewModel);


    // Case 2: Cannot pop
    when(mockGoRouter.canPop()).thenReturn(false);
    // If a goal was selected before this navigation
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(fitnessGoals[0]);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockSetupFlowViewModel.updateFitnessGoal(fitnessGoals[0])).called(1);
    verify(mockGoRouter.go('/setup/weight-height')).called(1);
  });
}
