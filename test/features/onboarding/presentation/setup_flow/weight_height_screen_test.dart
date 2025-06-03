import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/weight_height_screen.dart';
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
  const double cmToFeetFactor = 1 / 30.48;

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Default stubs for ViewModel state (base units: kg, cm)
    // Screen's initState will set these if null, so tests can override if needed.
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // Default 70kg
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // Default 170cm
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');

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

  testWidgets('renders number pickers and unit selectors with initial values', (WidgetTester tester) async {
    // ViewModel returns 70kg and 170cm
    await pumpWeightHeightScreen(tester);

    // Check for DecimalNumberPicker for weight
    expect(find.byType(DecimalNumberPicker), findsOneWidget); // For weight
    // Check for NumberPicker for height (cm is default)
    expect(find.byType(NumberPicker), findsOneWidget); // For height in CM

    // Verify displayed values (this requires finding the NumberPicker's current value text)
    // This is hard as NumberPicker internals are not exposed.
    // We'll trust it displays the value passed to it (`currentDisplayValue` in screen logic).
    // The screen calculates `_currentDisplayWeight` as 70.0 for kg, `_currentDisplayHeight` as 170 for cm.
    // These values are passed to the pickers.

    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(find.text('Height (cm)'), findsOneWidget);

    expect(find.byType(CupertinoSlidingSegmentedControl), findsNWidgets(2));
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lbs'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('ft'), findsOneWidget); // Changed from 'ft/in'
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('interacting with weight picker updates ViewModel with correct kg value', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // 70kg initially
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightHeightScreen(tester);

    // Simulate dragging the DecimalNumberPicker for weight
    // This is hard to do precisely. A common way is to find a specific number string if visible,
    // or use `tester.drag` on the picker itself.
    // For `DecimalNumberPicker`, let's assume an interaction that results in `onChanged(75.5)`.
    // We'll call the `onChanged` of the picker directly after finding it.

    final weightPicker = find.byType(DecimalNumberPicker);
    expect(weightPicker, findsOneWidget);

    // Get the onChanged callback from the widget
    final pickerWidget = tester.widget<DecimalNumberPicker>(weightPicker);
    pickerWidget.onChanged(75.5); // Simulate selecting 75.5 kg
    await tester.pumpAndSettle();

    // ViewModel stores in kg, value was 75.5 kg
    verify(mockSetupFlowViewModel.updateWeight(75.5.toPrecision(1))).called(1);
  });

  testWidgets('interacting with height picker (cm) updates ViewModel with cm value', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // 170cm initially
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpWeightHeightScreen(tester);

    final heightPicker = find.byType(NumberPicker); // cm uses NumberPicker
    expect(heightPicker, findsOneWidget);

    final pickerWidget = tester.widget<NumberPicker>(heightPicker);
    pickerWidget.onChanged(175); // Simulate selecting 175 cm
    await tester.pumpAndSettle();

    // ViewModel stores in cm
    verify(mockSetupFlowViewModel.updateHeight(175.0)).called(1);
  });

  testWidgets('changing weight unit to lbs updates picker display and ViewModel calls', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(70.0); // Initial 70 kg
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');
    await pumpWeightHeightScreen(tester);

    // Verify initial display (around 70 for kg)
    // Let's assume the picker is showing 70.0

    // Change unit to lbs
    when(mockSetupFlowViewModel.weightUnit).thenReturn('lbs'); // This will be set by onValueChanged
                                                          // The build method will use this new unit.
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle(); // Rebuild with new unit

    verify(mockSetupFlowViewModel.setWeightUnit('lbs')).called(1);
    // The ViewModel's stored weight (70kg) should NOT change on unit toggle, only display does.

    // Now, the picker should display the lbs equivalent of 70kg (approx 154.3 lbs)
    // And its min/max range should be for lbs.
    expect(find.text('Weight (lbs)'), findsOneWidget);
    // Hard to verify picker's actual displayed value without specific text finders for picker numbers.
    // But we can test that if we now change the value in lbs, it's converted to kg for storage.

    final weightPickerLbs = find.byType(DecimalNumberPicker);
    final pickerWidgetLbs = tester.widget<DecimalNumberPicker>(weightPickerLbs);

    pickerWidgetLbs.onChanged(150.0); // User selects 150.0 lbs
    await tester.pumpAndSettle();

    double expectedKg = (150.0 / kgToLbsFactor).toPrecision(1);
    verify(mockSetupFlowViewModel.updateWeight(expectedKg)).called(1);
  });

  testWidgets('changing height unit to ft updates picker display and ViewModel calls', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // Initial 170 cm
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpWeightHeightScreen(tester);

    // Change unit to ft
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft'); // This will be set by onValueChanged
    await tester.tap(find.text('ft'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.setHeightUnit('ft')).called(1);
    expect(find.text('Height (ft)'), findsOneWidget);
    // Height picker should now be DecimalNumberPicker
    expect(find.byType(DecimalNumberPicker), findsOneWidget);

    // Now, the picker should display the ft equivalent of 170cm (approx 5.57 ft)
    // If user changes this to, say, 5.5 ft
    final heightPickerFt = find.byType(DecimalNumberPicker);
    final pickerWidgetFt = tester.widget<DecimalNumberPicker>(heightPickerFt);

    pickerWidgetFt.onChanged(5.5); // User selects 5.5 ft
    await tester.pumpAndSettle();

    double expectedCm = (5.5 / cmToFeetFactor).toPrecision(1);
    verify(mockSetupFlowViewModel.updateHeight(expectedCm)).called(1);
  });


  testWidgets('"Next" button navigates to /setup/fitness-goal if values are set', (WidgetTester tester) async {
    // ViewModel already has default 70kg and 170cm from setUp
    await pumpWeightHeightScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    // ViewModel updateWeight/Height are called in initState if null, and by pickers.
    // No explicit updateWeight/Height in _onNext anymore.
    verify(mockGoRouter.go('/setup/fitness-goal')).called(1);
  });

   testWidgets('"Next" button shows SnackBar if weight is null', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.weight).thenReturn(null); // Weight not set
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // Height is set
    await pumpWeightHeightScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please ensure weight and height are selected.'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
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
