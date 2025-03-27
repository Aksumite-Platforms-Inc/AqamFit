#!/bin/bash

# Script to set up the AxumFit Flutter project

# Exit on any error
set -e

# Define project name and paths
PROJECT_NAME="axumfit"
FLUTTER_PROJECT_DIR="$PWD/$PROJECT_NAME"
LIB_DIR="$FLUTTER_PROJECT_DIR/lib"
SCREENS_DIR="$LIB_DIR/screens"
WIDGETS_DIR="$LIB_DIR/widgets"
MODELS_DIR="$LIB_DIR/models"
SERVICES_DIR="$LIB_DIR/services"

# Step 1: Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed. Please install Flutter and try again."
    exit 1
fi

echo "Flutter found: $(flutter --version)"

# Step 2: Create a new Flutter project
echo "Creating new Flutter project: $PROJECT_NAME..."
flutter create $PROJECT_NAME

# Step 3: Navigate to the project directory
cd $FLUTTER_PROJECT_DIR

# Step 4: Add necessary dependencies to pubspec.yaml
echo "Adding dependencies to pubspec.yaml..."
# Remove existing dependencies section and add new ones
sed -i '/dependencies:/,/^ *$/d' pubspec.yaml
cat <<EOL >> pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2  # State management
  fl_chart: ^0.68.0  # For progress charts
  http: ^1.2.1      # For API calls
  sqflite: ^2.3.3   # Local database
  firebase_core: ^3.3.0  # Firebase for cloud sync
  firebase_auth: ^5.1.4  # Firebase authentication

dev_dependencies:
  flutter_test:
    sdk: flutter
EOL

# Step 5: Get dependencies
echo "Fetching dependencies..."
flutter pub get

# Step 6: Create folder structure
echo "Creating folder structure..."
mkdir -p $SCREENS_DIR $WIDGETS_DIR $MODELS_DIR $SERVICES_DIR

# Step 7: Create initial files
# main.dart
echo "Creating main.dart..."
cat <<EOL > $LIB_DIR/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/workout_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF009688), // Teal
        scaffoldBackgroundColor: Color(0xFFF0F0F0), // Light Gray
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF009688), // Teal buttons
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
EOL

# screens/home_screen.dart
echo "Creating home_screen.dart..."
cat <<EOL > $SCREENS_DIR/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_provider.dart';
import '../widgets/workout_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('AxumFit'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Workout of the Day',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workoutProvider.workouts.length,
              itemBuilder: (context, index) {
                return WorkoutCard(workout: workoutProvider.workouts[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
EOL

# models/workout.dart
echo "Creating workout.dart model..."
cat <<EOL > $MODELS_DIR/workout.dart
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
EOL

# services/workout_provider.dart
echo "Creating workout_provider.dart..."
cat <<EOL > $SERVICES_DIR/workout_provider.dart
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
EOL

# widgets/workout_card.dart
echo "Creating workout_card.dart..."
cat << 'EOL' > $WIDGETS_DIR/workout_card.dart
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
EOL

# Step 8: Run the app to ensure setup is correct
echo "Running the app to verify setup..."
flutter run -d chrome # Use Chrome for initial testing; change to your preferred device

# Step 9: Notify user of completion
echo "AxumFit project setup complete! Navigate to $FLUTTER_PROJECT_DIR to start development."
echo "Next steps: Implement workout details screen, progress tracking, and trainer support."
