import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class FitnessGoalScreen extends StatefulWidget {
  const FitnessGoalScreen({super.key});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

// Simple class to hold goal title and icon
class _FitnessGoalItem {
  final String title;
  final IconData icon;

  _FitnessGoalItem({required this.title, required this.icon});
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  final List<_FitnessGoalItem> _fitnessGoalItems = [
    _FitnessGoalItem(title: "Lose Weight", icon: Icons.local_fire_department_outlined),
    _FitnessGoalItem(title: "Build Muscle", icon: Icons.fitness_center_outlined),
    _FitnessGoalItem(title: "Maintenance", icon: Icons.check_circle_outline),
    _FitnessGoalItem(title: "Improve Endurance", icon: Icons.directions_run_outlined),
    _FitnessGoalItem(title: "Overall Health", icon: Icons.favorite_border_outlined),
  ];
  String? _selectedGoalTitle; // Store the title of the selected goal

  @override
  void initState() {
    super.initState();
    // Initialize _selectedGoalTitle from ViewModel if already set
    _selectedGoalTitle = context.read<SetupFlowViewModel>().fitnessGoal;
  }

  void _onNext() {
    if (_selectedGoalTitle != null) {
      context.read<SetupFlowViewModel>().updateFitnessGoal(_selectedGoalTitle);
      context.go('/setup/experience-level');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fitness goal.')),
      );
    }
  }

  void _onBack() {
    // Save current selection before going back, in case user returns
    context.read<SetupFlowViewModel>().updateFitnessGoal(_selectedGoalTitle);
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      // Fallback if direct navigation or deep link
      context.go('/setup/weight-height');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Keep selection in sync with ViewModel, especially if it can change from elsewhere
    // or to ensure correct state on rebuild after pop.
    _selectedGoalTitle = context.watch<SetupFlowViewModel>().fitnessGoal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Goal'),
        centerTitle: true, // Center AppBar title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent padding
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What is your primary fitness goal?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _fitnessGoalItems.length,
                itemBuilder: (context, index) {
                  final goalItem = _fitnessGoalItems[index];
                  final isSelected = goalItem.title == _selectedGoalTitle;
                  return Card(
                    elevation: isSelected ? 8.0 : 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.5),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGoalTitle = goalItem.title;
                        });
                        context.read<SetupFlowViewModel>().updateFitnessGoal(goalItem.title);
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        child: Column( // Use Column for Icon and Text
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              goalItem.icon,
                              size: 40, // Adjust size as needed
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12), // Spacing between icon and text
                            Text(
                              goalItem.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onNext,
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
          ],
        ),
      ),
    );
  }
}
