import 'package:flutter/material.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('This Week'),
          SizedBox(height: 16),
          Text('No workouts yet'),
        ],
      ),
    );
  }
}
