import 'package:aksumfit/models/exercise.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/models/logged_exercise.dart';
import 'package:aksumfit/models/logged_set.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/services/api_service.dart'; // For saving workout log
import 'package:aksumfit/models/exercise.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/models/logged_exercise.dart';
import 'package:aksumfit/models/logged_set.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/services/api_service.dart'; // For saving workout log
import 'package:aksumfit/services/auth_manager.dart'; // For getting userId
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for ScaffoldMessenger & showDialog with AlertDialog
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
    final cupertinoTheme = CupertinoTheme.of(context);

    if (widget.plan.exercises.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text("Empty Workout Plan")),
        child: const Center(child: Text("This workout plan has no exercises.")),
      );
    }

    final exerciseName = _currentExerciseDetails?.name ?? "Loading...";
    final exerciseImage = _currentExerciseDetails?.imageUrl;
    final exerciseType = _currentExerciseDetails?.type ?? ExerciseType.strength;

    bool isStrengthExercise = exerciseType == ExerciseType.strength && (_currentPlanExercise.sets ?? 0) > 0;
    bool isTimedExercise = (_currentPlanExercise.durationSeconds ?? 0) > 0;
    if (isStrengthExercise && isTimedExercise) isStrengthExercise = false;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.plan.name),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark),
          onPressed: () async {
            final bool? shouldQuit = await showCupertinoDialog<bool>(
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
              context.pop();
            }
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.check_mark_circled_solid),
          onPressed: _finishWorkout,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Exercise ${_currentPlanExerciseIndex + 1} of ${widget.plan.exercises.length}",
                textAlign: TextAlign.center,
                style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(height: 10),
              Text(
                exerciseName,
                textAlign: TextAlign.center,
                style: cupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(color: CupertinoColors.label),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemFill,
                  borderRadius: BorderRadius.circular(12.0),
                  image: exerciseImage != null && exerciseImage.isNotEmpty
                      ? DecorationImage(image: NetworkImage(exerciseImage), fit: BoxFit.cover)
                      : null,
                ),
                child: (exerciseImage == null || exerciseImage.isEmpty)
                    ? Icon(CupertinoIcons.flame_fill, size: 100, color: cupertinoTheme.primaryColor)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                "Target: ${isStrengthExercise ? '${_currentPlanExercise.sets} sets, ${_currentPlanExercise.reps} reps' : ''}${isTimedExercise ? '${_currentPlanExercise.durationSeconds} seconds' : ''}",
                textAlign: TextAlign.center,
                style: cupertinoTheme.textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: isStrengthExercise
                      ? WeightRepLoggerWidget(
                          key: ValueKey("logger_${_currentPlanExercise.id}_${_currentActiveLoggedExercise?.id}"),
                          targetSets: _currentPlanExercise.sets ?? 3,
                          targetReps: _currentPlanExercise.reps ?? "N/A",
                          onSetLogged: _handleSetLogged,
                        )
                      : isTimedExercise
                          ? ExerciseTimerWidget(
                              key: ValueKey("timer_${_currentPlanExercise.id}_${_currentActiveLoggedExercise?.id}"),
                              durationInSeconds: _currentPlanExercise.durationSeconds!,
                              onTimerComplete: _handleTimedExerciseComplete,
                            )
                          : Text(
                              _currentExerciseDetails == null && widget.plan.exercises.isNotEmpty
                                  ? "Loading exercise details..."
                                  : "Unsupported exercise type or configuration.",
                              style: cupertinoTheme.textTheme.textStyle.copyWith(
                                  color: _currentExerciseDetails == null ? CupertinoColors.secondaryLabel : CupertinoColors.destructiveRed),
                            ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Row(children: [Icon(CupertinoIcons.back), SizedBox(width: 4), Text("Previous")]),
                    onPressed: _currentPlanExerciseIndex == 0 ? null : () => _moveToExercise(_currentPlanExerciseIndex - 1),
                  ),
                  CupertinoButton.filled(
                    child: Row(children: [
                      Text(_currentPlanExerciseIndex == widget.plan.exercises.length - 1 ? "Finish" : "Next"),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.forward)
                    ]),
                    onPressed: () => _moveToExercise(_currentPlanExerciseIndex + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension (if not already defined globally)

