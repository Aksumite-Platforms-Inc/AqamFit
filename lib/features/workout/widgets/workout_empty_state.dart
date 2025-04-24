import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

class WorkoutEmptyState extends StatelessWidget {
  const WorkoutEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Your library is empty', style: AppTypography.headline2),
          const SizedBox(height: 8),
          Text(
            'Build your library with workout routines so\nyou know what to do when you hit the gym.',
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Create your first program'),
          ),
        ],
      ),
    );
  }
}
