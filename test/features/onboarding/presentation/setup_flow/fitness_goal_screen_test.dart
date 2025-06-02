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
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]);


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

    for (final goal in fitnessGoals) {
      expect(find.text(goal), findsOneWidget);
    }
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('selecting a goal updates its appearance and ViewModel', (WidgetTester tester) async {
    await pumpFitnessGoalScreen(tester);

    final targetGoal = fitnessGoals[1]; // "Build Muscle"
    
    // Stub the getter to reflect the change for UI update
    // This simulates that after `updateFitnessGoal` is called and `notifyListeners` fires,
    // the getter for `fitnessGoal` will return the new value.
    when(mockSetupFlowViewModel.fitnessGoal).thenAnswer((_) => targetGoal);

    await tester.tap(find.text(targetGoal));
    await tester.pumpAndSettle(); // For UI changes (elevation, border)

    verify(mockSetupFlowViewModel.updateFitnessGoal(targetGoal)).called(2); // Once in initState (null), once on tap. Or just 1 if initState doesn't call.
                                                                        // The screen's initState reads, but doesn't call update.
                                                                        // The screen's build method reads via watch.
                                                                        // The tap calls setState and then read.updateFitnessGoal.
                                                                        // So, 1 direct call from tap, then the watch updates.
                                                                        // Let's refine: updateFitnessGoal is called on tap.
    
    // To verify appearance change, we'd need to inspect Card properties.
    // This is harder without specific keys or more detailed finder.
    // For now, trust that selection calls the ViewModel.
    // A simple check: the selected card might have a different text style (e.g. bold).
    // The FitnessGoalScreen uses `fontWeight: isSelected ? FontWeight.bold : FontWeight.normal`
    final textFinder = find.text(targetGoal);
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontWeight, FontWeight.bold);

    // Verify other goals are not bold (if they were boldable)
     final unselectedGoal = fitnessGoals[0];
     final unselectedTextWidget = tester.widget<Text>(find.text(unselectedGoal));
     expect(unselectedTextWidget.style?.fontWeight, FontWeight.normal);
  });


  testWidgets('"Next" button navigates if a goal is selected', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.fitnessGoal).thenReturn(fitnessGoals[0]); // Pre-select a goal

    await pumpFitnessGoalScreen(tester);
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    // Verify that updateFitnessGoal was called with the selected goal by _onNext
    verify(mockSetupFlowViewModel.updateFitnessGoal(fitnessGoals[0])).called(1);
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
