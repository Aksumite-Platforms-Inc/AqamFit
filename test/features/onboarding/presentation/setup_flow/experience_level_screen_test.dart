import 'package:aksumfit/features/onboarding/presentation/setup_flow/experience_level_screen.dart';
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

  // The ExperienceLevel class is simple, using real one.
  // Match names with those in ExperienceLevelScreen
  final List<String> experienceLevelNames = ["Beginner", "Intermediate", "Advanced"];
  final List<IconData> experienceLevelIcons = [
    Icons.energy_savings_leaf_outlined, Icons.trending_up_outlined, Icons.shield_moon_outlined
  ];


  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    when(mockSetupFlowViewModel.experienceLevel).thenReturn(null);
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]);


    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpExperienceLevelScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-exp-level',
            routes: [
              GoRoute(
                path: '/test-exp-level',
                builder: (context, state) => RouterScope.override(
                  context,
                   configuration: GoRoute(path: '/', builder: (_, __) => const ExperienceLevelScreen()).configuration,
                  state: GoRouterState(uri: Uri.parse('/test-exp-level'), pathParameters: const {}, configuration: GoRoute(path: '/', builder: (_, __) => const ExperienceLevelScreen()).configuration),
                  router: mockGoRouter,
                  child: const ExperienceLevelScreen(),
                ),
              ),
              GoRoute(path: '/setup/training-prefs', builder: (context, state) => const Scaffold(body: Text("Mock Training Prefs"))),
              GoRoute(path: '/setup/fitness-goal', builder: (context, state) => const Scaffold(body: Text("Mock Fitness Goal"))),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders experience level cards with icons', (WidgetTester tester) async {
    await pumpExperienceLevelScreen(tester);

    for (int i = 0; i < experienceLevelNames.length; i++) {
      expect(find.text(experienceLevelNames[i]), findsOneWidget);
      expect(find.byIcon(experienceLevelIcons[i]), findsOneWidget);
    }
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('selecting an experience level updates its appearance and ViewModel', (WidgetTester tester) async {
    await pumpExperienceLevelScreen(tester);

    final targetLevelName = experienceLevelNames[1]; // Intermediate
    final targetLevelIcon = experienceLevelIcons[1];

    // Simulate ViewModel update for UI check
    when(mockSetupFlowViewModel.experienceLevel).thenReturn(targetLevelName);

    await tester.tap(find.text(targetLevelName));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateExperienceLevel(targetLevelName)).called(1);
    
    // Check text style (bold)
    final textWidget = tester.widget<Text>(find.text(targetLevelName));
    expect(textWidget.style?.fontWeight, FontWeight.bold);

    // Check icon color (primary)
    // Finding the specific Icon widget associated with the selected card can be tricky
    // if there are multiple instances of the same icon or if icons are not unique.
    // Here, icons are unique.
    final iconWidget = tester.widget<Icon>(find.byIcon(targetLevelIcon));
    expect(iconWidget.color, Theme.of(tester.element(find.text(targetLevelName))).colorScheme.primary);

    // Check unselected item
    final unselectedLevelName = experienceLevelNames[0];
    final unselectedTextWidget = tester.widget<Text>(find.text(unselectedLevelName));
    expect(unselectedTextWidget.style?.fontWeight, FontWeight.normal);
    final unselectedIconWidget = tester.widget<Icon>(find.byIcon(experienceLevelIcons[0]));
    expect(unselectedIconWidget.color, Theme.of(tester.element(find.text(unselectedLevelName))).colorScheme.onSurfaceVariant);
  });

  testWidgets('"Next" button navigates if a level is selected', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.experienceLevel).thenReturn(experienceLevelNames[0]);

    await pumpExperienceLevelScreen(tester);
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateExperienceLevel(experienceLevelNames[0])).called(1);
    verify(mockGoRouter.go('/setup/training-prefs')).called(1);
  });

  testWidgets('"Next" button shows SnackBar if no level is selected', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.experienceLevel).thenReturn(null);

    await pumpExperienceLevelScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please select an experience level.'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });

  testWidgets('AppBar "Back" button pops or navigates to /setup/fitness-goal', (WidgetTester tester) async {
    await pumpExperienceLevelScreen(tester);

    // Case 1: Can pop
    when(mockGoRouter.canPop()).thenReturn(true);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockSetupFlowViewModel.updateExperienceLevel(null)).called(1);
    verify(mockGoRouter.pop()).called(1);
    clearInteractions(mockGoRouter);
    clearInteractions(mockSetupFlowViewModel);

    // Case 2: Cannot pop
    when(mockGoRouter.canPop()).thenReturn(false);
    when(mockSetupFlowViewModel.experienceLevel).thenReturn(experienceLevelNames[0]);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockSetupFlowViewModel.updateExperienceLevel(experienceLevelNames[0])).called(1);
    verify(mockGoRouter.go('/setup/fitness-goal')).called(1);
  });
}
