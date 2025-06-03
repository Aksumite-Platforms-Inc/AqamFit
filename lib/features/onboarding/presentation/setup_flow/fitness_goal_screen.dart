import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class FitnessGoalScreen extends StatefulWidget {
  const FitnessGoalScreen({super.key});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  final List<String> _fitnessGoals = [
    "Lose Weight",
    "Build Muscle",
    "Maintenance",
    "Improve Endurance",
    "Overall Health",
  ];
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedGoal from ViewModel if already set
    _selectedGoal = context.read<SetupFlowViewModel>().fitnessGoal;
  }

  void _onNext() {
    if (_selectedGoal != null) {
      context.read<SetupFlowViewModel>().updateFitnessGoal(_selectedGoal);
      context.go('/setup/experience-level');
    } else {
      // Optionally show a snackbar or alert if no goal is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fitness goal.')),
      );
    }
  }

  void _onBack() {
    // Save current selection before going back, in case user returns
    context.read<SetupFlowViewModel>().updateFitnessGoal(_selectedGoal);
    if (Navigator.canPop(context)) {
      context.pop();
    } else {
      // Fallback if direct navigation or deep link
      context.go('/setup/weight-height');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _selectedGoal = context.watch<SetupFlowViewModel>().fitnessGoal; // Keep selection in sync

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
                itemCount: _fitnessGoals.length,
                itemBuilder: (context, index) {
                  final goal = _fitnessGoals[index];
                  final isSelected = goal == _selectedGoal;
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
                          _selectedGoal = goal;
                        });
                        // Update ViewModel immediately on tap as well
                        context.read<SetupFlowViewModel>().updateFitnessGoal(goal);
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        child: Center(
                          child: Text(
                            goal,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
