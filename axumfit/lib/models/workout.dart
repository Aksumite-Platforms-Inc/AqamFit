class Workout {
  final int id;
  final String title;
  final String duration;
  final String level;
  final List<Exercise> exercises;
  bool completed;

  Workout({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.exercises,
    this.completed = false,
  });
}

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final String imageUrl;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.imageUrl,
  });
}
