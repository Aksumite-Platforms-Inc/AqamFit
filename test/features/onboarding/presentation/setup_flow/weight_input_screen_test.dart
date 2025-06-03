import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/weight_input_screen.dart'; // Changed import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:numberpicker/numberpicker.dart'; // Import NumberPicker
import 'package:provider/provider.dart';
import 'dart:math'; // For pow

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

    expect(find.byType(DecimalNumberPicker), findsOneWidget); // For weight
    expect(find.text('Weight (kg)'), findsOneWidget);

    // Check only for one CupertinoSlidingSegmentedControl (for weight)
    expect(find.byType(CupertinoSlidingSegmentedControl), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);
    // Ensure height related texts/widgets are NOT present
    expect(find.text('Height (cm)'), findsNothing);
    expect(find.text('cm'), findsNothing);
    expect(find.text('ft'), findsNothing);

    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('interacting with weight picker updates ViewModel with correct kg value', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    final weightPicker = find.byType(DecimalNumberPicker);
    expect(weightPicker, findsOneWidget);

    final pickerWidget = tester.widget<DecimalNumberPicker>(weightPicker);
    pickerWidget.onChanged(75.5); // Simulate selecting 75.5 kg
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateWeight(75.5.toPrecision(1))).called(1);
  });

  // Removed height picker interaction test

  testWidgets('changing weight unit to lbs updates picker display and ViewModel calls', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightInputScreen(tester);

    when(mockSetupFlowViewModel.weightUnit).thenReturn('lbs');
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.setWeightUnit('lbs')).called(1);
    expect(find.text('Weight (lbs)'), findsOneWidget);

    final weightPickerLbs = find.byType(DecimalNumberPicker);
    final pickerWidgetLbs = tester.widget<DecimalNumberPicker>(weightPickerLbs);

    pickerWidgetLbs.onChanged(150.0); // User selects 150.0 lbs
    await tester.pumpAndSettle();

    double expectedKg = (150.0 / kgToLbsFactor).toPrecision(1);
    verify(mockSetupFlowViewModel.updateWeight(expectedKg)).called(1);
  });

  // Removed height unit change test

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
