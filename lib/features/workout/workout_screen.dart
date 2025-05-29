import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:aksumfit/features/workout/widgets/exercise_timer_widget.dart';
import 'package:aksumfit/features/workout/widgets/weight_rep_logger_widget.dart'; // Import the logger widget

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _currentExerciseIndex = 0;
  // Updated _exercises data
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'Jumping Jacks', 'duration': '30s', 'imagePlaceholder': Icons.accessibility_new_rounded},
    {'name': 'Push Ups', 'reps': '10-12', 'sets': '3', 'imagePlaceholder': Icons.fitness_center},
    {'name': 'Squats', 'reps': '12-15', 'sets': '3', 'imagePlaceholder': Icons.boy_rounded},
    {'name': 'Plank', 'duration': '60s', 'imagePlaceholder': Icons.self_improvement},
  ];

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  int _getExerciseDuration() {
    final Map<String, dynamic> currentExercise = _exercises[_currentExerciseIndex];
    if (currentExercise.containsKey('duration')) {
      final String durationString = currentExercise['duration'] as String;
      if (durationString.endsWith('s')) {
        return int.tryParse(durationString.replaceAll('s', '')) ?? 0;
      }
    }
    return 0; // Default to 0 if no duration or rep-based
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, dynamic> currentExercise = _exercises[_currentExerciseIndex];
    final int exerciseDuration = _getExerciseDuration();
    final bool isStrengthExercise = currentExercise.containsKey('reps') && !currentExercise.containsKey('duration');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Active Workout",
          style: GoogleFonts.inter(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        leading: IconButton( // Use leading for back/close button if appropriate
          icon: const Icon(Icons.close),
          onPressed: () async { // Made onPressed async for showDialog
            final bool? shouldFinish = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(
                    "Finish Workout?",
                    style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
                  ),
                  content: Text(
                    "Are you sure you want to end your workout?",
                    style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                  backgroundColor: theme.colorScheme.surfaceVariant, // Themed background
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel", style: GoogleFonts.inter(color: theme.colorScheme.primary)),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Pops dialog, returns false
                      },
                    ),
                    TextButton(
                      child: Text("Finish", style: GoogleFonts.inter(color: theme.colorScheme.error)), // Using error color for finish
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true); // Pops dialog, returns true
                      },
                    ),
                  ],
                );
              },
            );

            if (shouldFinish == true && context.mounted) { // Check if context is still mounted
              context.go('/workout-summary');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Current Exercise:",
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.headlineSmall?.fontSize,
                fontWeight: FontWeight.w600, // Make it a bit more prominent
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentExercise['name']!,
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.headlineMedium?.fontSize,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                currentExercise['imagePlaceholder'] as IconData? ?? Icons.image_not_supported_outlined,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Target: ${currentExercise['duration'] ?? currentExercise['reps'] ?? 'N/A'}", // Changed label to "Target"
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 20), // Spacing before timer
            Expanded(
              child: Center(
                child: isStrengthExercise
                    ? WeightRepLoggerWidget(
                        key: ValueKey("logger_$_currentExerciseIndex"), // Ensure widget rebuilds on exercise change
                        targetSets: int.tryParse(currentExercise['sets']?.toString() ?? '3') ?? 3,
                        targetReps: currentExercise['reps']?.toString() ?? 'N/A',
                        onSetLogged: (set, weight, reps) {
                          print("Set $set logged: ${weight}kg x $reps reps for ${currentExercise['name']}");
                          // TODO: Store this data
                          // Optionally, auto-advance to next set or exercise
                          if (set == (int.tryParse(currentExercise['sets']?.toString() ?? '3') ?? 3)) {
                             // If all sets are done, maybe show a small delay then call _nextExercise()
                             Future.delayed(const Duration(seconds: 1), () {
                               if (mounted) _nextExercise();
                             });
                          }
                        },
                      )
                    : ExerciseTimerWidget(
                        key: ValueKey("timer_$_currentExerciseIndex"), // Ensure widget rebuilds on exercise change
                        durationInSeconds: exerciseDuration,
                        onTimerComplete: () {
                          print("Timer complete for ${currentExercise['name']}!");
                          // TODO: Handle auto-advance or sound cue
                          // Potentially call _nextExercise() if auto-advance is desired
                           _nextExercise(); // Auto-advance for timed exercises
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16), // Spacing before AI Form Checker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  "AI Form Analysis: Coming Soon!",
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Spacing after AI Form Checker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentExerciseIndex == 0 ? null : _previousExercise,
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: _currentExerciseIndex == _exercises.length - 1 ? null : _nextExercise,
                  child: const Text("Next"),
                ),
              ],
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}
