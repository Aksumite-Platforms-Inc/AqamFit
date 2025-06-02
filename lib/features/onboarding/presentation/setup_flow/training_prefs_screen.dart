import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class TrainingPrefsScreen extends StatefulWidget {
  const TrainingPrefsScreen({super.key});

  @override
  State<TrainingPrefsScreen> createState() => _TrainingPrefsScreenState();
}

class _TrainingPrefsScreenState extends State<TrainingPrefsScreen> {
// Helper class for day data
class DayPreference {
  final String abbr; // e.g., "M"
  final String fullName; // e.g., "Monday"

  DayPreference({required this.abbr, required this.fullName});
}

class _TrainingPrefsScreenState extends State<TrainingPrefsScreen> {
  final List<DayPreference> _days = [
    DayPreference(abbr: "S", fullName: "Sunday"), // Assuming S M T W T F S order
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
        title: const Text('Training Days'), // Updated AppBar title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // No need to save here as selections are updated instantly
            context.pop();
          },
        ),
        centerTitle: true, // Center AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // For button to stretch
          children: <Widget>[
            Text(
              'Which days do you typically train?', // New centered title
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute days evenly
              children: _days.map((day) {
                final isSelected = viewModel.preferredTrainingDays.contains(day.fullName);
                return GestureDetector(
                  onTap: () {
                    viewModel.toggleTrainingDay(day.fullName);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, // Circular button size
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : [],
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
            const Spacer(), // Pushes navigation buttons to the bottom
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
            const SizedBox(height: 8), // Space for back button or other elements
             TextButton( // Using TextButton for "Back" for a less prominent look if preferred
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
