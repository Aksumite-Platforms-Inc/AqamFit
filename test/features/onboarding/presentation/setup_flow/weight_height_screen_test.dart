import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/weight_height_screen.dart';
import 'package:flutter/cupertino.dart';
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

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Default stubs for ViewModel state
    when(mockSetupFlowViewModel.weight).thenReturn(null);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    when(mockSetupFlowViewModel.height).thenReturn(null);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]); // For other screens if they share this mock by mistake

    // Default stub for go_router's canPop
    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpWeightHeightScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-weight-height',
            routes: [
              GoRoute(
                path: '/test-weight-height',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const WeightHeightScreen()).configuration,
                  state: GoRouterState(configuration: GoRoute(path: '/', builder: (_, __) => const WeightHeightScreen()).configuration, uri: Uri.parse('/test-weight-height'), pathParameters: const {}),
                  router: mockGoRouter,
                  child: const WeightHeightScreen(),
                ),
              ),
              GoRoute(path: '/setup/fitness-goal', builder: (context, state) => const Scaffold(body: Text("Mock Fitness Goal"))),
              GoRoute(path: '/main', builder: (context, state) => const Scaffold(body: Text("Mock Main"))),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders input fields and unit selectors', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    expect(find.widgetWithText(TextFormField, 'Enter your weight'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Enter your height'), findsOneWidget);
    expect(find.byType(CupertinoSlidingSegmentedControl), findsNWidgets(2));
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('ft/in'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('entering valid weight and height updates ViewModel', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your weight'), '70');
    await tester.pump(); // Let listeners fire
    verify(mockSetupFlowViewModel.updateWeight(70.0)).called(1);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your height'), '175');
    await tester.pump();
    verify(mockSetupFlowViewModel.updateHeight(175.0)).called(1);
  });

  testWidgets('shows validation error for empty weight', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your height'), '175'); // Fill height to isolate weight
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle(); // For validation messages

    expect(find.text('Please enter your weight'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });

  testWidgets('shows validation error for invalid weight (non-numeric)', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your weight'), 'abc');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your height'), '175');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid number'), findsOneWidget); // For weight
    verifyNever(mockGoRouter.go(any));
  });

   testWidgets('shows validation error for zero/negative weight', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your weight'), '0');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your height'), '175');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Weight must be positive'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your weight'), '-10');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Weight must be positive'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });


  testWidgets('unit selection updates ViewModel and UI label', (WidgetTester tester) async {
    // Stub the view model to reflect changes for UI update (labelText)
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg'); // Initial
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm'); // Initial

    await pumpWeightHeightScreen(tester);

    // Check initial label for weight
    expect(find.text('Weight (kg)'), findsOneWidget);

    // Change weight unit to lbs
    when(mockSetupFlowViewModel.weightUnit).thenReturn('lbs'); // Simulate ViewModel update
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle(); // Rebuild with new state from ViewModel

    verify(mockSetupFlowViewModel.setWeightUnit('lbs')).called(1);
    // To test the label change, the ViewModel provider needs to actually trigger a rebuild.
    // The mock SetupFlowViewModel's notifyListeners() should be effective.
    // If the labelText is built using `_viewModel.weightUnit` directly, it should update.
    // Pumping the screen again after the tap sometimes helps reflect changes driven by watched providers.
    // For this test, we are testing that the `onValueChanged` calls the viewmodel.
    // The UI label update itself depends on how `WeightHeightScreen` rebuilds on viewmodel changes.
    // Let's assume the `watch` in the build method + `notifyListeners` in mock handles this.
    // Re-pump the whole screen to simulate a rebuild triggered by notifyListeners
    // This is a bit heavy-handed; typically, `tester.pump()` is enough if `watch` is used.
    // await pumpWeightHeightScreen(tester); // This would reset state unless mock holds it.
    // The key is that the `context.watch` should cause a rebuild.

    // We will re-pump the specific part or the whole widget if needed.
    // For now, verify the call. UI update check can be more complex with mocks.
    // If the widget directly uses `viewModel.weightUnit` in `InputDecoration`, `pumpAndSettle` should be enough.
    expect(find.text('Weight (lbs)'), findsOneWidget);


    // Check initial label for height
    expect(find.text('Height (cm)'), findsOneWidget);
    // Change height unit to ft
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft'); // Simulate ViewModel update
    await tester.tap(find.text('ft/in')); // Tap the 'ft/in' text in CupertinoSegmentedControl
    await tester.pumpAndSettle();
    verify(mockSetupFlowViewModel.setHeightUnit('ft')).called(1); // Assuming 'ft' is the value for 'ft/in'
    expect(find.text('Height (ft)'), findsOneWidget);
  });

  testWidgets('"Next" button navigates to /setup/fitness-goal if form is valid', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your weight'), '70');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter your height'), '175');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(70.0)).called(1);
    verify(mockSetupFlowViewModel.updateHeight(175.0)).called(1);
    verify(mockGoRouter.go('/setup/fitness-goal')).called(1);
  });

  testWidgets('AppBar "Back" button pops or goes to /main', (WidgetTester tester) async {
    await pumpWeightHeightScreen(tester);

    // Case 1: Can pop
    when(mockGoRouter.canPop()).thenReturn(true);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockGoRouter.pop()).called(1);

    // Case 2: Cannot pop
    when(mockGoRouter.canPop()).thenReturn(false);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockGoRouter.go('/main')).called(1);
  });
}
