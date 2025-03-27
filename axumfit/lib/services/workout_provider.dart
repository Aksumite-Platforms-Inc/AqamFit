import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [
    Workout(
      id: 1,
      title: 'How Great You Are',
      duration: '45 mins',
      level: 'Intermediate',
      exercises: [
        Exercise(name: 'Ab Roll Outs', sets: 1, reps: 10, imageUrl: ''),
        Exercise(name: 'Alternating Bicep Curls', sets: 1, reps: 12, imageUrl: ''),
      ],
    ),
  ];

  List<Workout> get workouts => _workouts;

  void toggleWorkoutCompletion(int id) {
    final index = _workouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _workouts[index].completed = !_workouts[index].completed;
      notifyListeners();
    }
  }
}
