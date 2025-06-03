import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/height_input_screen.dart';
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

    // Check for new UI components
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

    // Initial display is 170 cm (decimalPlaces = 0 for cm)
    expect(find.text('170 cm'), findsOneWidget); // No decimal for cm
    expect(find.text('Height (cm)'), findsOneWidget); // Title above value (not part of value)

    expect(find.byType(CupertinoSlidingSegmentedControl), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('ft'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
  });


  testWidgets('interacting with Slider (cm) updates ViewModel and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpHeightInputScreen(tester);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    final Slider sliderWidget = tester.widget(slider);
    sliderWidget.onChanged!(175.0); // User slides to 175 cm

    when(mockSetupFlowViewModel.height).thenReturn(175.0);
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateHeight(175.0.toPrecision(0))).called(1); // cm stored with 0 precision
    expect(find.text('175 cm'), findsOneWidget);
  });

  testWidgets('interacting with Slider (ft) updates ViewModel (in cm) and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0); // 170cm
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft'); // Display in ft
    await pumpHeightInputScreen(tester);

    // Initial display for 170cm in ft (170 * 0.0328084).toPrecision(1) = 5.6 ft
    expect(find.text('5.6 ft'), findsOneWidget);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    final Slider sliderWidget = tester.widget(slider);
    sliderWidget.onChanged!(5.5); // User slides to 5.5 ft

    double expectedCm = (5.5 / cmToFeetFactor).toPrecision(1);
    when(mockSetupFlowViewModel.height).thenReturn(expectedCm); // Update mock for next build
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateHeight(expectedCm)).called(1);
    expect(find.text('5.5 ft'), findsOneWidget);
  });

  testWidgets('tapping + IconButton (cm) updates ViewModel and text display', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpHeightInputScreen(tester);

    when(mockSetupFlowViewModel.height).thenReturn(171.0);
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateHeight(171.0.toPrecision(0))).called(1);
    expect(find.text('171 cm'), findsOneWidget);
  });

  testWidgets('tapping - IconButton (ft) updates ViewModel (in cm) and text display', (WidgetTester tester) async {
    // initial 170cm, display as 5.6ft. Decrement by 0.1ft to 5.5ft
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft');
    await pumpHeightInputScreen(tester);

    double expectedCm = (5.5 / cmToFeetFactor).toPrecision(1);
    when(mockSetupFlowViewModel.height).thenReturn(expectedCm);

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.updateHeight(expectedCm)).called(1);
    expect(find.text('5.5 ft'), findsOneWidget);
  });


  testWidgets('changing height unit to ft updates text display and Slider', (WidgetTester tester) async {
    when(mockSetupFlowViewModel.height).thenReturn(170.0);
    when(mockSetupFlowViewModel.heightUnit).thenReturn('cm');
    await pumpHeightInputScreen(tester);

    expect(find.text('170 cm'), findsOneWidget);

    // Change unit to ft
    when(mockSetupFlowViewModel.heightUnit).thenReturn('ft');
    // VM still stores 170.0 (cm). Display will convert this.
    // 170cm * 0.0328084 = 5.577... ft, toPrecision(1) = 5.6 ft
    await tester.tap(find.text('ft'));
    await tester.pumpAndSettle();

    verify(mockSetupFlowViewModel.setHeightUnit('ft')).called(1);
    expect(find.text('5.6 ft'), findsOneWidget); // Check converted display
    // Slider's value, min, max should also reflect feet.
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
