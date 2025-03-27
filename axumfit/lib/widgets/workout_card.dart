import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
        title: Text(workout.title),
        subtitle: Text('\${workout.duration} | \${workout.level}'),
        trailing: Icon(
          workout.completed ? Icons.check_circle : Icons.circle_outlined,
          color: workout.completed ? Colors.green : Colors.grey,
        ),
        onTap: () {
          // Navigate to workout details screen (to be implemented)
        },
      ),
    );
  }
}
