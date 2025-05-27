import 'package:flutter/material.dart';

import '../models/workout_exercise.dart';
import '../widgets/workout_exercise_card.dart';
import '../widgets/workout_category_card.dart';
import '../widgets/recent_workout_item.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool isWorkoutActive = false;
  int workoutTime = 0;
  late DateTime workoutStartTime;

  List<WorkoutExercise> currentWorkout = [
    WorkoutExercise('Push-ups', 3, 15, false),
    WorkoutExercise('Squats', 3, 20, false),
    WorkoutExercise('Plank', 3, 60, false),
    WorkoutExercise('Burpees', 3, 10, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts'),
        actions: [IconButton(icon: Icon(Icons.history), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Recommended Workout
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'AI Recommended',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Upper Body Strength',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '30 min • 4 exercises • Intermediate',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isWorkoutActive = !isWorkoutActive;
                        if (isWorkoutActive) {
                          workoutStartTime = DateTime.now();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF43A047),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isWorkoutActive ? 'Pause Workout' : 'Start Workout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Current Workout Progress
            if (isWorkoutActive) ...[
              Text(
                'Current Workout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 16),
              ...currentWorkout.map((exercise) => WorkoutExerciseCard(
                    exercise: exercise,
                    onChanged: (value) {
                      setState(() {
                        exercise.isCompleted = value ?? false;
                      });
                    },
                  )),
              SizedBox(height: 24),
            ],

            // Workout Categories
            Text(
              'Workout Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                WorkoutCategoryCard(
                  title: 'Strength',
                  icon: Icons.fitness_center,
                  color: Color(0xFFE53E3E),
                  onTap: () {},
                ),
                WorkoutCategoryCard(
                  title: 'Cardio',
                  icon: Icons.favorite,
                  color: Color(0xFFD53F8C),
                  onTap: () {},
                ),
                WorkoutCategoryCard(
                  title: 'Yoga',
                  icon: Icons.self_improvement,
                  color: Color(0xFF805AD5),
                  onTap: () {},
                ),
                WorkoutCategoryCard(
                  title: 'HIIT',
                  icon: Icons.flash_on,
                  color: Color(0xFFDD6B20),
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 24),

            // Recent Workouts
            Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            RecentWorkoutItem(
                name: 'Full Body Blast', duration: '45 min', date: 'Yesterday'),
            RecentWorkoutItem(
                name: 'Morning Yoga', duration: '30 min', date: '2 days ago'),
            RecentWorkoutItem(
                name: 'HIIT Cardio', duration: '25 min', date: '3 days ago'),
          ],
        ),
      ),
    );
  }

  // _buildExerciseCard removed

  // _buildCategoryCard removed

  // _buildRecentWorkout removed
}
