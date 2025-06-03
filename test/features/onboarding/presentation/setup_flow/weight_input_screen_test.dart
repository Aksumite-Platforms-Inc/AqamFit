import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/weight_input_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
// import 'package:numberpicker/numberpicker.dart'; // No longer using numberpicker
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../../mocks/mock_view_models.dart';
import '../../../../mocks/mock_router.dart';

// Helper extension from the screen itself, useful for tests too
extension DoublePrecision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

void main() {
  late MockSetupFlowViewModel mockSetupFlowViewModel;
  late MockGoRouter mockGoRouter;

  // Conversion factors from the screen
  const double kgToLbsFactor = 2.20462;
  // const double cmToFeetFactor = 1 / 30.48; // Not needed for weight input screen

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Default stubs for ViewModel state (base units: kg)
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // Default 70kg
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    // Height related stubs are not strictly necessary here but good for safety if mock is shared
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');


    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpWeightInputScreen(WidgetTester tester) async { // Renamed pump function
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-weight-input', // Updated initial location
            routes: [
              GoRoute(
                path: '/test-weight-input',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const WeightInputScreen()).configuration, // Use WeightInputScreen
                  state: GoRouterState(configuration: GoRoute(path: '/', builder: (_, __) => const WeightInputScreen()).configuration, uri: Uri.parse('/test-weight-input'), pathParameters: const {}),
                  router: mockGoRouter,
                  child: const WeightInputScreen(), // Use WeightInputScreen
                ),
              ),
              GoRoute(path: '/setup/height-input', builder: (context, state) => const Scaffold(body: Text("Mock Height Input"))), // Updated next route
              GoRoute(path: '/main', builder: (context, state) => const Scaffold(body: Text("Mock Main"))),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders weight picker and unit selector with initial values', (WidgetTester tester) async {
    await pumpWeightInputScreen(tester);

    // Check for new UI components
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

    // Check for the text display of weight (e.g., "70.0 kg")
    // The text format is `_currentDisplayWeight.toStringAsFixed(displayWeightDecimalPlaces)} ${_viewModel.weightUnit}`
    // Initial is 70.0 kg (displayWeightDecimalPlaces = 1 for kg)
    expect(find.text('70.0 kg'), findsOneWidget);

    // Unit selector still present
    expect(find.byType(CupertinoSlidingSegmentedControl), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('interacting with Slider updates ViewModel and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    // Simulate Slider change
    final Slider sliderWidget = tester.widget(slider);
    sliderWidget.onChanged!(75.5); // User slides to 75.5 kg

    // Mock the viewmodel state change for the next pump
    when(mockSetupFlowViewModel.weight).thenReturn(75.5);
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(75.5.toPrecision(1))).called(1);
    expect(find.text('75.5 kg'), findsOneWidget); // Text display should update
  });

  testWidgets('tapping + IconButton updates ViewModel and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    // Expected value after increment (70.0 + 0.1 = 70.1)
    when(mockSetupFlowViewModel.weight).thenReturn(70.1);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(70.1.toPrecision(1))).called(1);
    expect(find.text('70.1 kg'), findsOneWidget);
  });

  testWidgets('tapping - IconButton updates ViewModel and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    // Expected value after decrement (70.0 - 0.1 = 69.9)
    when(mockSetupFlowViewModel.weight).thenReturn(69.9);
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(69.9.toPrecision(1))).called(1);
    expect(find.text('69.9 kg'), findsOneWidget);
  });


  testWidgets('changing weight unit to lbs updates text display, Slider, and ViewModel calls', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // 70kg
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    expect(find.text('70.0 kg'), findsOneWidget);

    // Change unit to lbs
    when(mockSetupFlowViewModel.weightUnit).thenReturn('lbs');
    // When unit changes, the build method re-calculates _currentDisplayWeight
    // 70kg * 2.20462 = 154.3234, toPrecision(1) = 154.3
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // VM still stores 70kg

    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.setWeightUnit('lbs')).called(1);
    expect(find.text('154.3 lbs'), findsOneWidget); // Check converted display

    // Interact with slider in lbs
    final sliderLbs = find.byType(Slider);
    final Slider sliderWidgetLbs = tester.widget(sliderLbs);
    sliderWidgetLbs.onChanged!(150.0); // User slides to 150.0 lbs

    // Mock the viewmodel update for the next pump
    double expectedKgFromLbs = (150.0 / kgToLbsFactor).toPrecision(1);
    when(mockSetupFlowViewModel.weight).thenReturn(expectedKgFromLbs); // VM stores this new kg value
    // when(mockSetupFlowViewModel.weightUnit).thenReturn('lbs'); // unit is already lbs

    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(expectedKgFromLbs)).called(1);
    expect(find.text('150.0 lbs'), findsOneWidget); // Display updates to 150.0 lbs
  });


  testWidgets('"Next" button navigates to /setup/height-input if values are set', (WidgetTester tester) async {
    await pumpWeightInputScreen(tester); // ViewModel has default weight

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockGoRouter.go('/setup/height-input')).called(1); // Updated navigation
  });

   testWidgets('"Next" button shows SnackBar if weight is null', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(null);
    // when(mockSetupFlowViewModel.height).thenReturn(170.0); // Not relevant for this screen
    await pumpWeightInputScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please ensure weight is selected.'), findsOneWidget); // Updated message
    verifyNever(mockGoRouter.go(any));
  });


  testWidgets('AppBar "Back" button pops or goes to /main', (WidgetTester tester) async {
    await pumpWeightInputScreen(tester);

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
