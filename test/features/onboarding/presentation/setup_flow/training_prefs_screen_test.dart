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

    // Initial state for ViewModel
    when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn([]);
    when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(null);

    when(mockGoRouter.canPop()).thenReturn(true);
  });

  // Helper to provide the screen with necessary mocks
  Future<void> pumpTrainingPrefsScreen(WidgetTester tester, {MockSetupFlowViewModel? viewModel}) async {
    final vmToUse = viewModel ?? mockSetupFlowViewModel;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SetupFlowViewModel>.value(value: vmToUse),
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
            ],
          ),
        ),
      ),
    );
  }

  group('Original Day Selection Tests', () {
    testWidgets('renders circular weekday buttons', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);

      // Find the Row containing the day buttons. This assumes it's the only Row directly under the main Column's children that contains GestureDetectors.
      // Or, be more specific if other Rows are added.
      // The preset chips are in a Wrap, day buttons in a Row.
      final dayButtonsRowFinder = find.descendant(
        of: find.byType(Column), // Main column
        matching: find.byType(Row) // Find Row specifically for day buttons
      );
      // Ensure we find the correct Row (there's only one for day buttons)
      expect(dayButtonsRowFinder, findsOneWidget);


      for (final dayMap in dayPreferences) {
        expect(find.widgetWithText(AnimatedContainer, dayMap["abbr"]!).
          matching((finder) => finder.evaluate().any((e) => dayButtonsRowFinder.evaluate().contains(e.visitAncestorElements((element) => element == dayButtonsRowFinder.evaluate().first.widget ? false : true) as Element?))),
          findsWidgets); // Check they exist within the day buttons row
      }
      expect(find.descendant(of: dayButtonsRowFinder, matching: find.byType(GestureDetector)), findsNWidgets(dayPreferences.length));
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
    });

    testWidgets('tapping a day button toggles selection, updates ViewModel, and clears preset', (WidgetTester tester) async {
      // Initially, a preset is selected
      const initialPreset = "3 days/week";
      final presetDays = SetupFlowViewModel.frequencyPresets[initialPreset]!;
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(initialPreset);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(presetDays));

      await pumpTrainingPrefsScreen(tester);

      final mondayFullName = "Monday"; // A day part of "3 days/week" preset

      // Find Monday button
      final dayButtonFinders = find.descendant(of: find.byType(Row).last, matching: find.byType(GestureDetector));
      final mondayButtonFinder = dayButtonFinders.at(1); // Monday

      // Tap Monday (which is already selected by preset) to deselect it
      // ViewModel should now have Monday removed and preset cleared
      final expectedDaysAfterToggle = List<String>.from(presetDays)..remove(mondayFullName);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(expectedDaysAfterToggle);
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(null); // toggleDay clears preset

      await tester.tap(mondayButtonFinder);
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.toggleTrainingDay(mondayFullName)).called(1);
      // The mock's toggleTrainingDay already sets selectedFrequencyPreset to null.

      // Verify Monday is now visually unselected
      AnimatedContainer mondayContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: mondayButtonFinder, matching: find.byType(AnimatedContainer))
      );
      BoxDecoration decoration = mondayContainer.decoration as BoxDecoration;
      expect(decoration.color, Theme.of(tester.element(mondayButtonFinder)).colorScheme.surfaceContainerHighest.withOpacity(0.5));

      // Verify preset chip is unselected
      final presetChipFinder = find.widgetWithText(ChoiceChip, initialPreset);
      final ChoiceChip presetChipWidget = tester.widget(presetChipFinder);
      expect(presetChipWidget.selected, isFalse);
    });
  });

  group('Preset Frequency Tests', () {
    testWidgets('renders predefined frequency ChoiceChips', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);
      for (final presetName in SetupFlowViewModel.frequencyPresets.keys) {
        expect(find.widgetWithText(ChoiceChip, presetName), findsOneWidget);
      }
    });

    testWidgets('selecting a preset updates ViewModel, chip appearance, and day buttons', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);

      final presetToSelect = SetupFlowViewModel.frequencyPresets.keys.first; // "3 days/week"
      final expectedDaysForPreset = SetupFlowViewModel.frequencyPresets[presetToSelect]!;

      // Mock ViewModel behavior after preset selection
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(presetToSelect);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(expectedDaysForPreset));

      await tester.tap(find.widgetWithText(ChoiceChip, presetToSelect));
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.selectFrequencyPreset(presetToSelect)).called(1);

      // Verify preset chip is selected
      final ChoiceChip selectedChipWidget = tester.widget(find.widgetWithText(ChoiceChip, presetToSelect));
      expect(selectedChipWidget.selected, isTrue);

      // Verify day buttons reflect the preset
      for (final dayPref in dayPreferences) {
        final dayButtonFinder = find.descendant(
          of: find.byType(Row).last, // Day buttons are in the last Row
          matching: find.byElementPredicate((element) {
            // Find by text inside the AnimatedContainer
            if (element.widget is AnimatedContainer) {
              final textFinder = find.descendant(of: find.byWidget(element.widget), matching: find.text(dayPref.abbr));
              return textFinder.evaluate().isNotEmpty;
            }
            return false;
          })
        ).first; // This finder is complex, ensure it works or simplify by index.

        // A simpler way for day buttons, assuming fixed order S,M,T,W,T,F,S
        final dayIndex = dayPreferences.indexWhere((dp) => dp.fullName == dayPref.fullName);
        final specificDayButtonGestureDetector = find.descendant(of: find.byType(Row).last, matching: find.byType(GestureDetector)).at(dayIndex);


        final AnimatedContainer dayContainer = tester.widget(
          find.descendant(of: specificDayButtonGestureDetector, matching: find.byType(AnimatedContainer))
        );
        final BoxDecoration decoration = dayContainer.decoration as BoxDecoration;
        final bool isDayInPreset = expectedDaysForPreset.contains(dayPref.fullName);

        expect(decoration.color == Theme.of(tester.element(specificDayButtonGestureDetector)).colorScheme.primary, isDayInPreset,
               reason: "${dayPref.fullName} selection state is ${isDayInPreset ? '' : 'not '}as expected for preset $presetToSelect. Color was ${decoration.color}");
      }
    });

    testWidgets('transition from custom selection to preset selection', (WidgetTester tester) async {
      // Initial: custom days selected, no preset
      final customDays = ["Tuesday", "Saturday"];
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(customDays);
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(null);

      await pumpTrainingPrefsScreen(tester);

      // Verify initial custom day selection
      final tuesdayButton = find.descendant(of: find.byType(Row).last, matching: find.byType(GestureDetector)).at(2); // Tuesday
      AnimatedContainer tueContainer = tester.widget(find.descendant(of: tuesdayButton, matching: find.byType(AnimatedContainer)));
      expect((tueContainer.decoration as BoxDecoration).color, Theme.of(tester.element(tuesdayButton)).colorScheme.primary);

      // Now, select a preset
      final presetToSelect = "4 days/week";
      final expectedDaysForPreset = SetupFlowViewModel.frequencyPresets[presetToSelect]!;

      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(presetToSelect);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(expectedDaysForPreset));

      await tester.tap(find.widgetWithText(ChoiceChip, presetToSelect));
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.selectFrequencyPreset(presetToSelect)).called(1);

      // Verify preset chip is selected
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, presetToSelect)).selected, isTrue);

      // Verify day buttons now reflect the preset, not the old custom selection
      tueContainer = tester.widget(find.descendant(of: tuesdayButton, matching: find.byType(AnimatedContainer)));
      final isTuesdayInNewPreset = expectedDaysForPreset.contains("Tuesday");
      expect((tueContainer.decoration as BoxDecoration).color == Theme.of(tester.element(tuesdayButton)).colorScheme.primary, isTuesdayInNewPreset);

      final saturdayButton = find.descendant(of: find.byType(Row).last, matching: find.byType(GestureDetector)).at(6); // Saturday
      AnimatedContainer satContainer = tester.widget(find.descendant(of: saturdayButton, matching: find.byType(AnimatedContainer)));
      final isSaturdayInNewPreset = expectedDaysForPreset.contains("Saturday");
      expect((satContainer.decoration as BoxDecoration).color == Theme.of(tester.element(saturdayButton)).colorScheme.primary, isSaturdayInNewPreset);

    });

  });


  // Original navigation tests (should still pass)
  testWidgets('Original "Next" button navigates to /setup/additional-info', (WidgetTester tester) async {
    await pumpTrainingPrefsScreen(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    verify(mockGoRouter.go('/setup/additional-info')).called(1);
  });

  group('Navigation Tests (Bottom Buttons)', () {
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
