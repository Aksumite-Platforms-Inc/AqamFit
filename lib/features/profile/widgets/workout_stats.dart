import 'package:flutter/material.dart';

class WorkoutStats extends StatelessWidget {
  const WorkoutStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Workouts\n0'),
            Text('Duration\n0min'),
            Text('Volume\n0kg'),
          ],
        ),
      ),
    );
  }
}
