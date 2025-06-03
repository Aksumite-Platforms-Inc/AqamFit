import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class DayPreference {
  final String abbr; // e.g., "M"
  final String fullName; // e.g., "Monday"

  DayPreference({required this.abbr, required this.fullName});
}

class TrainingPrefsScreen extends StatefulWidget {
  const TrainingPrefsScreen({super.key});

  @override
  State<TrainingPrefsScreen> createState() => _TrainingPrefsScreenState();
}

class _TrainingPrefsScreenState extends State<TrainingPrefsScreen> {
  final List<DayPreference> _days = [
    DayPreference(abbr: "S", fullName: "Sunday"),
    DayPreference(abbr: "M", fullName: "Monday"),
    DayPreference(abbr: "T", fullName: "Tuesday"),
    DayPreference(abbr: "W", fullName: "Wednesday"),
    DayPreference(abbr: "T", fullName: "Thursday"),
    DayPreference(abbr: "F", fullName: "Friday"),
    DayPreference(abbr: "S", fullName: "Saturday"),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupFlowViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Days'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Which days do you typically train?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Choose a preset or select days below:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 4.0,
              children: SetupFlowViewModel.frequencyPresets.keys.map((presetName) {
                final isSelected = viewModel.selectedFrequencyPreset == presetName;
                return ChoiceChip(
                  label: Text(presetName),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      viewModel.selectFrequencyPreset(presetName);
                    } else {
                      viewModel.selectFrequencyPreset(null);
                    }
                  },
                  selectedColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              "Or select individual days:",
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _days.map((day) {
                final isSelected = viewModel.preferredTrainingDays.contains(day.fullName);
                return GestureDetector(
                  onTap: () {
                    viewModel.toggleTrainingDay(day.fullName);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.abbr,
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.go('/setup/additional-info');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text('Next'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Back',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
