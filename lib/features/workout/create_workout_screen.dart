import 'package:aksumfit/models/exercise.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/features/explore/presentation/screens/exercise_library_screen.dart'; // To pick exercises
import 'package:aksumfit/services/auth_manager.dart'; // To get current user ID for authorId
import 'package:aksumfit/core/extensions/string_extensions.dart'; // Import for capitalize
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for MaterialPageRoute & showCupertinoDialog
import 'package:provider/provider.dart'; // Example: using Provider for AuthManager
import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:uuid/uuid.dart';

// Widget to edit details of a WorkoutPlanExercise
class PlanExerciseEditTile extends StatefulWidget {
  final WorkoutPlanExercise planExercise;
  final Exercise exerciseDetails; // Full exercise details
  final Function(WorkoutPlanExercise) onUpdate;
  final VoidCallback onRemove;

  const PlanExerciseEditTile({
    super.key,
    required this.planExercise,
    required this.exerciseDetails,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<PlanExerciseEditTile> createState() => _PlanExerciseEditTileState();
}

class _PlanExerciseEditTileState extends State<PlanExerciseEditTile> {
  late WorkoutPlanExercise _editingExercise;
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _restController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editingExercise = widget.planExercise.copyWith(); // Create a mutable copy

    _setsController.text = _editingExercise.sets?.toString() ?? '';
    _repsController.text = _editingExercise.reps ?? '';
    _weightController.text = _editingExercise.weightKg?.toString() ?? '';
    _durationController.text = _editingExercise.durationSeconds?.toString() ?? '';
    _restController.text = _editingExercise.restBetweenSetsSeconds?.toString() ?? '';
    _notesController.text = _editingExercise.notes ?? '';
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePlanExercise() {
    widget.onUpdate(_editingExercise.copyWith(
      sets: int.tryParse(_setsController.text),
      reps: _repsController.text.isNotEmpty ? _repsController.text : null,
      weightKg: double.tryParse(_weightController.text),
      durationSeconds: int.tryParse(_durationController.text),
      restBetweenSetsSeconds: int.tryParse(_restController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    bool isStrength = widget.exerciseDetails.type == ExerciseType.strength ||
                      widget.exerciseDetails.type == ExerciseType.plyometrics;
    bool isTimed = widget.exerciseDetails.type == ExerciseType.cardio ||
                   widget.exerciseDetails.type == ExerciseType.stretch ||
                   _editingExercise.durationSeconds != null;

    return CupertinoListTile.notched(
      leading: CircleAvatar(
        backgroundColor: cupertinoTheme.primaryColor.withOpacity(0.1),
        child: Icon(CupertinoIcons.flame_fill, color: cupertinoTheme.primaryColor, size: 20),
      ),
      title: Text(widget.exerciseDetails.name, style: cupertinoTheme.textTheme.navTitleTextStyle),
      subtitle: Text(
        "${widget.exerciseDetails.type.toString().split('.').last.capitalize()} - ${widget.exerciseDetails.muscleGroups.take(2).join(', ')}",
        style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.delete_simple, color: CupertinoColors.destructiveRed),
        onPressed: widget.onRemove,
      ),
      additionalInfo: Padding( // Using additionalInfo for expandable content
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0), // Adjust padding as needed
        child: Column(
          children: [
            if (isStrength) ...[
              _buildCupertinoTextField(_setsController, "Sets (e.g., 3)", TextInputType.number),
              _buildCupertinoTextField(_repsController, "Reps (e.g., 8-12 or AMRAP)"),
              _buildCupertinoTextField(_weightController, "Weight (kg, optional)", const TextInputType.numberWithOptions(decimal: true)),
            ],
            if (isTimed || widget.exerciseDetails.type == ExerciseType.strength)
              _buildCupertinoTextField(_durationController, "Duration (seconds, optional)", TextInputType.number),
            _buildCupertinoTextField(_restController, "Rest between sets (seconds, optional)", TextInputType.number),
            _buildCupertinoTextField(_notesController, "Notes (e.g., tempo, form cues)", TextInputType.text, givenMaxLines: 2),
            const SizedBox(height: 10),
            CupertinoButton(
              child: const Text("Update Exercise Details"),
              onPressed: _updatePlanExercise,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoTextField(TextEditingController controller, String placeholder, [TextInputType? keyboardType, int? maxLines]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical padding
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        minLines: 1,
        maxLines: (keyboardType == TextInputType.multiline) ? maxLines : 1, // Use givenMaxLines for multiline, else 1
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjusted padding
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.inactiveGray),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class CreateWorkoutScreen extends StatefulWidget {
  final WorkoutPlan? existingPlan;

  const CreateWorkoutScreen({super.key, this.existingPlan});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late WorkoutPlan _workoutPlan;
  final Uuid _uuid = const Uuid();
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _planDescriptionController = TextEditingController();
  final Map<String, Exercise> _exerciseCache = {};

  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final String currentUserId = authManager.currentUser?.id ?? "default_user";

    if (widget.existingPlan != null) {
      _workoutPlan = widget.existingPlan!.copyWith();
      _planNameController.text = _workoutPlan.name;
      _planDescriptionController.text = _workoutPlan.description ?? '';
      for (var pExercise in _workoutPlan.exercises) {
        if (pExercise.exerciseDetails != null) {
           _exerciseCache[pExercise.exerciseId] = pExercise.exerciseDetails!;
        }
      }
    } else {
      _workoutPlan = WorkoutPlan(
        id: _uuid.v4(),
        name: '',
        authorId: currentUserId,
        exercises: [],
      );
    }
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planDescriptionController.dispose();
    super.dispose();
  }

  void _addExerciseToPlan(Exercise exercise) {
    final newPlanExercise = WorkoutPlanExercise(
      id: _uuid.v4(),
      exerciseId: exercise.id,
      order: _workoutPlan.exercises.length,
      exerciseDetails: exercise,
    );
    setState(() {
      _workoutPlan = _workoutPlan.copyWith(
        exercises: [..._workoutPlan.exercises, newPlanExercise],
      );
      _exerciseCache[exercise.id] = exercise;
    });
  }

  void _updatePlannedExercise(int index, WorkoutPlanExercise updatedPlanExercise) {
    setState(() {
      final newExercises = List<WorkoutPlanExercise>.from(_workoutPlan.exercises);
      newExercises[index] = updatedPlanExercise;
      _workoutPlan = _workoutPlan.copyWith(exercises: newExercises);
    });
  }

  void _removeExerciseFromPlan(int index) {
    setState(() {
      final newExercises = List<WorkoutPlanExercise>.from(_workoutPlan.exercises);
      newExercises.removeAt(index);
      _workoutPlan = _workoutPlan.copyWith(exercises: newExercises);
    });
  }

  Future<void> _saveWorkoutPlan() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _workoutPlan = _workoutPlan.copyWith(
          name: _planNameController.text,
          description: _planDescriptionController.text,
          updatedAt: DateTime.now(),
        );
      });

      try {
        final savedPlan = await ApiService().saveWorkoutPlan(_workoutPlan);
        // Show Cupertino success dialog
         if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("Plan Saved"),
              content: Text('${savedPlan.name} saved successfully!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Pop dialog
                    Navigator.of(context).pop(savedPlan); // Pop screen, return plan
                  },
                )
              ],
            ),
          );
        }
      } catch (e) {
         if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("Error"),
              content: Text('Error saving plan: ${e.toString()}'),
              actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.existingPlan == null ? "Create Workout Plan" : "Edit Workout Plan"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.check_mark_circled),
          onPressed: _saveWorkoutPlan,
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Added vertical padding
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Plan Details"),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _planNameController,
                  prefix: const Text("Name"),
                  placeholder: "Enter plan name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a plan name";
                    }
                    return null;
                  },
                ),
                CupertinoTextFormFieldRow(
                  controller: _planDescriptionController,
                  prefix: const Text("Description"),
                  placeholder: "e.g., Focus on upper body",
                  maxLines: 3,
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Exercises (${_workoutPlan.exercises.length})", style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(children: [Icon(CupertinoIcons.add), SizedBox(width: 4), Text("Add")]),
                    onPressed: () async {
                      final selectedExercise = await Navigator.push<Exercise>(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ExerciseLibraryScreen(isPickerMode: true),
                          fullscreenDialog: true,
                        ),
                      );
                      if (selectedExercise != null) {
                        _addExerciseToPlan(selectedExercise);
                      }
                    },
                  ),
                ],
              ),
              children: _workoutPlan.exercises.isEmpty
                  ? [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "No exercises added yet. Click 'Add' to begin.",
                            textAlign: TextAlign.center,
                            style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel),
                          ),
                        ),
                      )
                    ]
                  : List.generate(_workoutPlan.exercises.length, (index) {
                      final planExercise = _workoutPlan.exercises[index];
                      final exerciseDetails = planExercise.exerciseDetails ?? _exerciseCache[planExercise.exerciseId];
                      if (exerciseDetails == null) {
                        return CupertinoListTile(
                          title: Text("Error: Exercise details missing for ID ${planExercise.exerciseId}",
                              style: const TextStyle(color: CupertinoColors.destructiveRed)),
                          trailing: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
                            onPressed: () => _removeExerciseFromPlan(index),
                          ),
                        );
                      }
                      return PlanExerciseEditTile(
                        key: ValueKey(planExercise.id),
                        planExercise: planExercise,
                        exerciseDetails: exerciseDetails,
                        onUpdate: (updated) => _updatePlannedExercise(index, updated),
                        onRemove: () => _removeExerciseFromPlan(index),
                      );
                    }),
            ),
            const SizedBox(height: 30),
            Padding( // Add padding for the save button
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoButton.filled(
                onPressed: _saveWorkoutPlan,
                child: Text(widget.existingPlan == null ? "Save Workout Plan" : "Update Workout Plan"),
              ),
            ),
             const SizedBox(height: 30), // Ensure scrollability if keyboard is up
          ],
        ),
      ),
    );
  }
}
