import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/workout_exercise.dart';

class WorkoutExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final ValueChanged<bool?> onChanged;

  const WorkoutExerciseCard({
    Key? key,
    required this.exercise,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: exercise.isCompleted,
            onChanged: onChanged,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${exercise.sets} sets × ${exercise.reps} reps',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.right_chevron, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
