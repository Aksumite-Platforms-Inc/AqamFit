import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key});

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class ExperienceLevel {
  final String name;
  final IconData icon;

  ExperienceLevel({required this.name, required this.icon});
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  final List<ExperienceLevel> _experienceLevels = [
    ExperienceLevel(name: "Beginner", icon: Icons.energy_savings_leaf_outlined), // Placeholder, consider better icons
    ExperienceLevel(name: "Intermediate", icon: Icons.trending_up_outlined),
    ExperienceLevel(name: "Advanced", icon: Icons.shield_moon_outlined), // Placeholder, consider better icons
  ];
  String? _selectedLevelName;

  @override
  void initState() {
    super.initState();
    _selectedLevelName = context.read<SetupFlowViewModel>().experienceLevel;
  }

  void _onNext() {
    if (_selectedLevelName != null) {
      context.read<SetupFlowViewModel>().updateExperienceLevel(_selectedLevelName);
      context.go('/setup/training-prefs'); // Navigate to the next step
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an experience level.')),
      );
    }
  }

  void _onBack() {
    context.read<SetupFlowViewModel>().updateExperienceLevel(_selectedLevelName);
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      // Fallback, should go to fitness goal screen
      context.go('/setup/fitness-goal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch for external changes to the experienceLevel in ViewModel
    _selectedLevelName = context.watch<SetupFlowViewModel>().experienceLevel;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Level'),
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
              'How would you describe your fitness experience?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              // Using a GridView for a different layout example, can be ListView too
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // One card per row for larger cards
                  childAspectRatio: 3.5 / 1, // Adjust aspect ratio for card height
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                ),
                itemCount: _experienceLevels.length,
                itemBuilder: (context, index) {
                  final level = _experienceLevels[index];
                  final isSelected = level.name == _selectedLevelName;
                  return Card(
                    elevation: isSelected ? 8.0 : 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.5),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLevelName = level.name;
                        });
                        context.read<SetupFlowViewModel>().updateExperienceLevel(level.name);
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column( // Use column for icon and text
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              level.icon,
                              size: 30,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              level.name,
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
