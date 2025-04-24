import 'package:flutter/material.dart';
import '../../../core/widgets/base_screen.dart';
import '../widgets/workout_empty_state.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Workout',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
      body: const WorkoutEmptyState(),
    );
  }
}
