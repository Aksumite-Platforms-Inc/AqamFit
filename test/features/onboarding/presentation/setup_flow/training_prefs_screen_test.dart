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

  group('Pill & Switch Day Selection Tests', () {
    testWidgets('renders day pills with text and switch', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);

      for (final dayMap in dayPreferences) {
        final dayPillFinder = find.widgetWithText(Container, dayMap["fullName"]!);
        expect(dayPillFinder, findsOneWidget); // Finds the Container (pill)
        expect(find.descendant(of: dayPillFinder, matching: find.byType(Switch)), findsOneWidget);
      }
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Back'), findsOneWidget);
    });

    testWidgets('tapping a Switch toggles selection, updates ViewModel, and clears preset', (WidgetTester tester) async {
      const initialPreset = "3 days/week";
      final presetDays = SetupFlowViewModel.frequencyPresets[initialPreset]!;
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(initialPreset);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(presetDays)); // e.g., Mon, Wed, Fri

      await pumpTrainingPrefsScreen(tester);

      final mondayFullName = "Monday";
      final mondaySwitchFinder = find.ancestor(
        of: find.text(mondayFullName),
        matching: find.byType(Row), // The Switch is in a Row with the Text
      ).last; // find the Row, then find the Switch in it.
      final switchFinder = find.descendant(of: mondaySwitchFinder, matching: find.byType(Switch));

      // Initial state: Monday is selected via preset
      Switch mondaySwitch = tester.widget<Switch>(switchFinder);
      expect(mondaySwitch.value, isTrue);

      // Tap Monday's Switch to deselect it
      final expectedDaysAfterToggle = List<String>.from(presetDays)..remove(mondayFullName);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(expectedDaysAfterToggle);
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(null); // toggleDay clears preset

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.toggleTrainingDay(mondayFullName)).called(1);

      // Verify Monday Switch is now off
      mondaySwitch = tester.widget<Switch>(switchFinder);
      expect(mondaySwitch.value, isFalse);

      // Verify preset chip is unselected
      final presetChipFinder = find.widgetWithText(ChoiceChip, initialPreset);
      ChoiceChip presetChipWidget = tester.widget(presetChipFinder);
      expect(presetChipWidget.selected, isFalse);

      // Tap Monday's Switch again to select it
      final expectedDaysAfterSecondToggle = List<String>.from(expectedDaysAfterToggle)..add(mondayFullName);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(expectedDaysAfterSecondToggle);
      // selectedFrequencyPreset should still be null (custom selection)

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      verify(mockSetupFlowViewModel.toggleTrainingDay(mondayFullName)).called(1); // Called again

      mondaySwitch = tester.widget<Switch>(switchFinder);
      expect(mondaySwitch.value, isTrue);
    });
  });

  group('Preset Frequency Tests', () {
    testWidgets('renders predefined frequency ChoiceChips', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);
      for (final presetName in SetupFlowViewModel.frequencyPresets.keys) {
        expect(find.widgetWithText(ChoiceChip, presetName), findsOneWidget);
      }
    });

    testWidgets('selecting a preset updates ViewModel, chip appearance, and day Switches', (WidgetTester tester) async {
      await pumpTrainingPrefsScreen(tester);

      final presetToSelect = SetupFlowViewModel.frequencyPresets.keys.first; // "3 days/week"
      final expectedDaysForPreset = SetupFlowViewModel.frequencyPresets[presetToSelect]!;

      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(presetToSelect);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(expectedDaysForPreset));

      await tester.tap(find.widgetWithText(ChoiceChip, presetToSelect));
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.selectFrequencyPreset(presetToSelect)).called(1);

      final ChoiceChip selectedChipWidget = tester.widget(find.widgetWithText(ChoiceChip, presetToSelect));
      expect(selectedChipWidget.selected, isTrue);

      // Verify day Switches reflect the preset
      for (final dayPref in dayPreferences) {
        final dayPillFinder = find.widgetWithText(Container, dayPref.fullName!);
         final switchFinder = find.descendant(of: dayPillFinder, matching: find.byType(Switch));
        final Switch daySwitch = tester.widget<Switch>(switchFinder);
        final bool isDayInPreset = expectedDaysForPreset.contains(dayPref.fullName);

        expect(daySwitch.value, isDayInPreset,
               reason: "${dayPref.fullName} Switch state is ${daySwitch.value}, expected ${isDayInPreset} for preset $presetToSelect");
      }
    });

    testWidgets('transition from custom selection to preset selection', (WidgetTester tester) async {
      final customDays = ["Tuesday", "Saturday"];
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(customDays);
      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(null);

      await pumpTrainingPrefsScreen(tester);

      // Verify initial custom day Switch selection
      final tuesdayPill = find.widgetWithText(Container, "Tuesday");
      final tueSwitch = tester.widget<Switch>(find.descendant(of: tuesdayPill, matching: find.byType(Switch)));
      expect(tueSwitch.value, isTrue);

      final presetToSelect = "4 days/week";
      final expectedDaysForPreset = SetupFlowViewModel.frequencyPresets[presetToSelect]!;

      when(mockSetupFlowViewModel.selectedFrequencyPreset).thenReturn(presetToSelect);
      when(mockSetupFlowViewModel.preferredTrainingDays).thenReturn(List.from(expectedDaysForPreset));

      await tester.tap(find.widgetWithText(ChoiceChip, presetToSelect));
      await tester.pumpAndSettle();

      verify(mockSetupFlowViewModel.selectFrequencyPreset(presetToSelect)).called(1);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, presetToSelect)).selected, isTrue);

      // Verify day Switches now reflect the preset
      final updatedTuesdayPill = find.widgetWithText(Container, "Tuesday");
      final updatedTueSwitch = tester.widget<Switch>(find.descendant(of: updatedTuesdayPill, matching: find.byType(Switch)));
      final isTuesdayInNewPreset = expectedDaysForPreset.contains("Tuesday");
      expect(updatedTueSwitch.value, isTuesdayInNewPreset);

      final saturdayPill = find.widgetWithText(Container, "Saturday");
      final updatedSatSwitch = tester.widget<Switch>(find.descendant(of: saturdayPill, matching: find.byType(Switch)));
      final isSaturdayInNewPreset = expectedDaysForPreset.contains("Saturday");
      expect(updatedSatSwitch.value, isSaturdayInNewPreset);
    });
  });

  testWidgets('"Next" button navigates to /setup/additional-info', (WidgetTester tester) async {
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
