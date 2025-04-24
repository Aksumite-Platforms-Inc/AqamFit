import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

class WorkoutInProgress extends StatelessWidget {
  const WorkoutInProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('Duration', style: AppTypography.body1),
              Spacer(),
              Text('Volume', style: AppTypography.body1),
              Spacer(),
              Text('Sets', style: AppTypography.body1),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              // TODO: Implement exercise list
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () {
              // TODO: Implement add exercise
            },
            child: const Text('ADD EXERCISES'),
          ),
        ),
      ],
    );
  }
}
