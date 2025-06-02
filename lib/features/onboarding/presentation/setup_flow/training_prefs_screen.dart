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
  // Define the days of the week
  final List<String> _daysOfWeek = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupFlowViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // Changed to Column to structure content better
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Select Your Preferred Training Days:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0, // Gap between adjacent chips.
              runSpacing: 4.0, // Gap between lines.
              children: _daysOfWeek.map((day) {
                final isSelected = viewModel.preferredTrainingDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    viewModel.toggleTrainingDay(day);
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    )
                  ),
                );
              }).toList(),
            ),
            const Spacer(), // Pushes navigation buttons to the bottom
            Padding( // Add padding for the buttons row
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context.pop();
                    },
                     style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // No specific validation needed here unless there's a min/max days requirement
                      // ViewModel is already updated by ChoiceChip's onSelected
                      context.go('/setup/additional-info');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
