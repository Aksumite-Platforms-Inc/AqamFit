import 'package:aksumfit/models/exercise.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/models/logged_exercise.dart';
import 'package:aksumfit/models/logged_set.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/services/api_service.dart'; // For saving workout log
import 'package:aksumfit/services/auth_manager.dart'; // For getting userId
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:aksumfit/features/workout/widgets/exercise_timer_widget.dart';
import 'package:aksumfit/features/workout/widgets/weight_rep_logger_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class WorkoutScreen extends StatefulWidget {
  final WorkoutPlan plan;

  const WorkoutScreen({super.key, required this.plan});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _currentPlanExerciseIndex = 0;
  late WorkoutPlanExercise _currentPlanExercise;
  Exercise? _currentExerciseDetails; // Full details of the current exercise

  List<LoggedExercise> _completedWorkoutExercises = []; // Renamed from _loggedExercises for clarity
  LoggedExercise? _currentActiveLoggedExercise; // Holds data for the exercise currently being performed
  DateTime _workoutStartTime = DateTime.now();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _workoutStartTime = DateTime.now();
    _loadExerciseData();
  }

  void _loadExerciseData() {
    if (widget.plan.exercises.isNotEmpty && _currentPlanExerciseIndex < widget.plan.exercises.length) {
      _currentPlanExercise = widget.plan.exercises[_currentPlanExerciseIndex];
      _currentExerciseDetails = _currentPlanExercise.exerciseDetails;

      // Initialize a new LoggedExercise for the current exercise
      _currentActiveLoggedExercise = LoggedExercise(
        id: _uuid.v4(), // This ID is for the log entry of this specific exercise instance
        exerciseId: _currentPlanExercise.exerciseId,
        exerciseName: _currentExerciseDetails?.name ?? "Unknown Exercise",
        sets: [], // Initialize with empty sets
        // durationAchievedSeconds will be set on completion if it's a timed exercise
      );
    } else {
      _currentActiveLoggedExercise = null; // Should not happen if plan is valid and not empty
    }
  }

  void _finalizeCurrentExerciseLog() {
    if (_currentActiveLoggedExercise != null) {
       // Ensure all sets are captured or duration is set before adding.
       // For strength exercises, this might mean checking if the WeightRepLoggerWidget's state needs one final flush.
       // For timed, it's usually set at onTimerComplete.
      if ((_currentActiveLoggedExercise!.sets.isNotEmpty && _currentActiveLoggedExercise!.sets.any((s) => s.isCompleted)) ||
          _currentActiveLoggedExercise!.durationAchievedSeconds != null) {
        _completedWorkoutExercises.add(_currentActiveLoggedExercise!);
      }
      _currentActiveLoggedExercise = null;
    }
  }

  void _moveToExercise(int index) {
    _finalizeCurrentExerciseLog(); // Log the completed/partially completed current exercise

    if (index >= 0 && index < widget.plan.exercises.length) {
      setState(() {
        _currentPlanExerciseIndex = index;
        _loadExerciseData(); // This will also create a new _currentActiveLoggedExercise
      });
    } else if (index >= widget.plan.exercises.length) {
      _finishWorkout();
    }
  }

  void _handleSetLogged(int setNumber, double weight, int reps) {
    if (_currentActiveLoggedExercise == null) return;

    final newSet = LoggedSet(
      setNumber: setNumber,
      weightUsedKg: weight,
      repsAchieved: reps,
      isCompleted: true, // Mark set as completed when logged
    );

    setState(() {
      // Find if this set was already logged (e.g., user corrected a previous entry - though current logger doesn't support editing past sets easily)
      final existingSetIndex = _currentActiveLoggedExercise!.sets.indexWhere((s) => s.setNumber == setNumber);
      if (existingSetIndex != -1) {
        _currentActiveLoggedExercise!.sets[existingSetIndex] = newSet; // Update if exists
      } else {
        _currentActiveLoggedExercise!.sets.add(newSet); // Add if new
      }
      // Ensure sets are ordered, as they might be logged out of order if editing was allowed.
      _currentActiveLoggedExercise!.sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));
    });

    // Check if all target sets for the current exercise are now logged
    final int targetSetsCount = _currentPlanExercise.sets ?? 0;
    bool allDesignatedSetsCompleted = _currentActiveLoggedExercise!.sets.where((s) => s.isCompleted).length >= targetSetsCount && targetSetsCount > 0;

    if (allDesignatedSetsCompleted) {
       // All sets for the current exercise are done.
       // Consider a brief delay or user confirmation before auto-advancing
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text("${_currentExerciseDetails?.name ?? "Exercise"} completed!"),
           duration: const Duration(seconds: 2),
         ),
       );
       // Optionally, trigger _moveToExercise after a short delay
       // Future.delayed(const Duration(seconds: 1), () {
       //   if (mounted) {
       //     _moveToExercise(_currentPlanExerciseIndex + 1);
       //   }
       // });
    }
  }

  void _handleTimedExerciseComplete() {
    if (_currentActiveLoggedExercise == null) return;
    setState(() {
      _currentActiveLoggedExercise = _currentActiveLoggedExercise!.copyWith(
        durationAchievedSeconds: _currentPlanExercise.durationSeconds, // Log the target duration
      );
    });
    // _finalizeCurrentExerciseLog(); // Log it immediately
    _moveToExercise(_currentPlanExerciseIndex + 1); // Auto-advance
  }

  Future<void> _finishWorkout() async {
    _finalizeCurrentExerciseLog(); // Ensure the last exercise is logged

    final endTime = DateTime.now();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final userId = authManager.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not logged in. Cannot save workout.")),
      );
      return;
    }

    // Dialog to add overall workout notes
    String? overallWorkoutNotes;
    if (mounted) { // Check if the widget is still in the tree
      overallWorkoutNotes = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          final TextEditingController notesController = TextEditingController();
          return AlertDialog(
            title: const Text("Workout Notes"),
            content: TextField(
              controller: notesController,
              decoration: const InputDecoration(hintText: "Any notes for this workout? (e.g., how you felt, PRs)"),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                child: const Text("Skip"),
                onPressed: () => Navigator.of(dialogContext).pop(null),
              ),
              TextButton(
                child: const Text("Save Notes"),
                onPressed: () => Navigator.of(dialogContext).pop(notesController.text),
              ),
            ],
          );
        },
      );
    }


    final workoutLog = WorkoutLog(
      id: _uuid.v4(),
      userId: userId,
      planId: widget.plan.id,
      planName: widget.plan.name,
      startTime: _workoutStartTime,
      endTime: endTime,
      completedExercises: _completedWorkoutExercises,
      notes: overallWorkoutNotes?.isNotEmpty == true ? overallWorkoutNotes : null,
    );

    try {
      // Note: saveWorkoutLog was already added to ApiService in a previous step
      final savedLog = await ApiService().saveWorkoutLog(workoutLog);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${savedLog.planName} workout logged successfully!")),
      );
      if (mounted) context.go('/workout-summary', extra: savedLog);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving workout log: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (widget.plan.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Empty Workout Plan")),
        body: const Center(child: Text("This workout plan has no exercises.")),
      );
    }

    // Fallback if details are somehow null, though _loadExerciseData should prevent this if plan is valid
    final exerciseName = _currentExerciseDetails?.name ?? "Loading...";
    final exerciseImage = _currentExerciseDetails?.imageUrl;
    final exerciseType = _currentExerciseDetails?.type ?? ExerciseType.strength;

    // Determine if the current exercise is strength-based or timed
    // This logic might need refinement based on WorkoutPlanExercise fields (e.g. if duration is set for a strength exercise like Plank)
    bool isStrengthExercise = exerciseType == ExerciseType.strength && (_currentPlanExercise.sets ?? 0) > 0;
    bool isTimedExercise = (_currentPlanExercise.durationSeconds ?? 0) > 0;
    if(isStrengthExercise && isTimedExercise) isStrengthExercise = false; // Prioritize timed if both are set (e.g. timed plank)


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name, style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () async {
            final bool? shouldQuit = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) => CupertinoAlertDialog(
                title: const Text("Quit Workout?"),
                content: const Text("Are you sure you want to end this workout session? Progress may not be saved."),
                actions: <Widget>[
                  CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(dialogContext).pop(false)),
                  CupertinoDialogAction(child: const Text("Quit"), isDestructiveAction: true, onPressed: () => Navigator.of(dialogContext).pop(true)),
                ],
              ),
            );
            if (shouldQuit == true && mounted) {
              context.pop(); // Go back from whence it came
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.check_mark_circled_solid),
            tooltip: "Finish Workout",
            onPressed: _finishWorkout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Indicator (e.g., Exercise 1 of 5)
            Text(
              "Exercise ${_currentPlanExerciseIndex + 1} of ${widget.plan.exercises.length}",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: theme.textTheme.titleMedium?.fontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Text(
              exerciseName,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: theme.textTheme.headlineMedium?.fontSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.0),
                image: exerciseImage != null && exerciseImage.isNotEmpty
                    ? DecorationImage(image: NetworkImage(exerciseImage), fit: BoxFit.cover)
                    : null,
              ),
              child: (exerciseImage == null || exerciseImage.isEmpty)
                  ? Icon(CupertinoIcons.flame_fill, size: 100, color: theme.colorScheme.primary)
                  : null,
            ),
            const SizedBox(height: 20),

            // Display target sets/reps or duration from _currentPlanExercise
            Text(
              "Target: ${isStrengthExercise ? '${_currentPlanExercise.sets} sets, ${_currentPlanExercise.reps} reps' : ''}${isTimedExercise ? '${_currentPlanExercise.durationSeconds} seconds' : ''}",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: theme.textTheme.titleLarge?.fontSize),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: isStrengthExercise
                    ? WeightRepLoggerWidget(
                        key: ValueKey("logger_${_currentPlanExercise.id}_${_currentActiveLoggedExercise?.id}"), // More unique key
                        targetSets: _currentPlanExercise.sets ?? 3,
                        targetReps: _currentPlanExercise.reps ?? "N/A",
                        onSetLogged: _handleSetLogged,
                      )
                    : isTimedExercise
                        ? ExerciseTimerWidget(
                            key: ValueKey("timer_${_currentPlanExercise.id}_${_currentActiveLoggedExercise?.id}"), // More unique key
                            durationInSeconds: _currentPlanExercise.durationSeconds!,
                            onTimerComplete: _handleTimedExerciseComplete,
                          )
                        : Text(
                            _currentExerciseDetails == null && widget.plan.exercises.isNotEmpty
                                ? "Loading exercise details..."
                                : "Unsupported exercise type or configuration.",
                            style: GoogleFonts.inter(color: _currentExerciseDetails == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error),
                          ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.back),
                  label: const Text("Previous"),
                  onPressed: _currentPlanExerciseIndex == 0 ? null : () => _moveToExercise(_currentPlanExerciseIndex - 1),
                ),
                ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.forward),
                  label: Text(_currentPlanExerciseIndex == widget.plan.exercises.length - 1 ? "Finish" : "Next"),
                  onPressed: () => _moveToExercise(_currentPlanExerciseIndex + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension (if not already defined globally)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
