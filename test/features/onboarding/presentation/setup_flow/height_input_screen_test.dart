import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/height_input_screen.dart'; // Changed import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:numberpicker/numberpicker.dart';
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

  const double cmToFeetFactor = 1 / 30.48;

  setUp(() {
    mockSetupFlowViewModel = MockSetupFlowViewModel();
    mockGoRouter = MockGoRouter();

    // Default stubs for ViewModel state (base units: cm for height)
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // Default 170cm
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    // Weight related stubs are not strictly necessary here but good for safety
    when(mockSetupFlowViewModel.weight).thenReturn(70.0);
    when(mockSetupFlowViewModel.weightUnit).thenReturn('kg');

    when(mockGoRouter.canPop()).thenReturn(true);
  });

  Future<void> pumpHeightInputScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: mockSetupFlowViewModel),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/test-height-input',
            routes: [
              GoRoute(
                path: '/test-height-input',
                builder: (context, state) => RouterScope.override(
                  context,
                  configuration: GoRoute(path: '/', builder: (_, __) => const HeightInputScreen()).configuration,
                  state: GoRouterState(configuration: GoRoute(path: '/', builder: (_, __) => const HeightInputScreen()).configuration, uri: Uri.parse('/test-height-input'), pathParameters: const {}),
                  router: mockGoRouter,
                  child: const HeightInputScreen(),
                ),
              ),
              GoRoute(path: '/setup/fitness-goal', builder: (context, state) => const Scaffold(body: Text("Mock Fitness Goal"))),
              GoRoute(path: '/setup/weight-input', builder: (context, state) => const Scaffold(body: Text("Mock Weight Input"))), // For back navigation
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders height picker (cm initially) and unit selector with initial values', (WidgetTester tester) async {
    await pumpHeightInputScreen(tester);

    // Check for NumberPicker for height (cm is default)
    expect(find.byType(NumberPicker), findsOneWidget);
    expect(find.text('Height (cm)'), findsOneWidget);

    expect(find.byType(CupertinoSlidingSegmentedControl), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('ft'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });

  testWidgets('renders height picker (ft) if unit is ft', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft');
    // Adjust height to be a typical ft value if needed for display consistency, ViewModel stores cm.
    // Display value for 5.57ft (170cm) would be 5.6 after toPrecision(1) in screen.
    // The picker itself will use the _currentDisplayHeight calculated in build().
    await pumpHeightInputScreen(tester);

    expect(find.byType(DecimalNumberPicker), findsOneWidget); // For height in FT
    expect(find.text('Height (ft)'), findsOneWidget);
  });


  testWidgets('interacting with height picker (cm) updates ViewModel with cm value', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpHeightInputScreen(tester);

    final heightPicker = find.byType(NumberPicker);
    expect(heightPicker, findsOneWidget);

    final pickerWidget = tester.widget<NumberPicker>(heightPicker);
    pickerWidget.onChanged(175); // Simulate selecting 175 cm
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateHeight(175.0)).called(1);
  });

  testWidgets('interacting with height picker (ft) updates ViewModel with correct cm value', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // 170cm initially ~ 5.577 ft
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft'); // Set unit to ft
    await pumpHeightInputScreen(tester);

    final heightPicker = find.byType(DecimalNumberPicker);
    expect(heightPicker, findsOneWidget);

    final pickerWidget = tester.widget<DecimalNumberPicker>(heightPicker);
    pickerWidget.onChanged(5.5); // Simulate user selecting 5.5 ft
    await tester.pumpAndSettle();

    double expectedCm = (5.5 / cmToFeetFactor).toPrecision(1);
    verify(mockSetupFlowViewModel.updateHeight(expectedCm)).called(1);
  });


  testWidgets('changing height unit to ft updates picker display and type', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpHeightInputScreen(tester);

    expect(find.text('Height (cm)'), findsOneWidget);
    expect(find.byType(NumberPicker), findsOneWidget);

    // Change unit to ft
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft');
    await tester.tap(find.text('ft'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.setHeightUnit('ft')).called(1);
    expect(find.text('Height (ft)'), findsOneWidget);
    expect(find.byType(DecimalNumberPicker), findsOneWidget); // Picker type should change
    expect(find.byType(NumberPicker), findsNothing); // Old picker should be gone
  });

  testWidgets('"Next" button navigates to /setup/fitness-goal if values are set', (WidgetTester tester) async {
    await pumpHeightInputScreen(tester); // ViewModel has default height

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockGoRouter.go('/setup/fitness-goal')).called(1);
  });

   testWidgets('"Next" button shows SnackBar if height is null', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(null);
    await pumpHeightInputScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please ensure height is selected.'), findsOneWidget);
    verifyNever(mockGoRouter.go(any));
  });

  testWidgets('AppBar "Back" button pops or goes to /setup/weight-input', (WidgetTester tester) async {
    await pumpHeightInputScreen(tester);

    // Case 1: Can pop
    when(mockGoRouter.canPop()).thenReturn(true);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockGoRouter.pop()).called(1);
    clearInteractions(mockGoRouter);

    // Case 2: Cannot pop (should ideally not happen if pushed from weight_input_screen)
    when(mockGoRouter.canPop()).thenReturn(false);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    verify(mockGoRouter.go('/setup/weight-input')).called(1);
  });
}
