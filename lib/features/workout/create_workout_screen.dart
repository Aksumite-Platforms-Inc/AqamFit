import 'package:aksumfit/models/exercise.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/models/workout_plan_exercise.dart';
import 'package:aksumfit/features/explore/presentation/screens/exercise_library_screen.dart'; // To pick exercises
import 'package:aksumfit/services/auth_manager.dart'; // To get current user ID for authorId
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final theme = Theme.of(context);
    bool isStrength = widget.exerciseDetails.type == ExerciseType.strength ||
                      widget.exerciseDetails.type == ExerciseType.plyometrics; // Plyo might have reps
    bool isTimed = widget.exerciseDetails.type == ExerciseType.cardio ||
                   widget.exerciseDetails.type == ExerciseType.stretch ||
                   _editingExercise.durationSeconds != null ;


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(CupertinoIcons.flame_fill, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(widget.exerciseDetails.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: Text(
          "${widget.exerciseDetails.type.toString().split('.').last.capitalize()} - ${widget.exerciseDetails.muscleGroups.take(2).join(', ')}",
          style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: IconButton(
          icon: Icon(CupertinoIcons.delete_simple, color: theme.colorScheme.error),
          onPressed: widget.onRemove,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(top: 0),
            child: Column(
              children: [
                if (isStrength) ...[
                  _buildTextField(_setsController, "Sets (e.g., 3)", TextInputType.number),
                  _buildTextField(_repsController, "Reps (e.g., 8-12 or AMRAP)"),
                  _buildTextField(_weightController, "Weight (kg, optional)", TextInputType.numberWithOptions(decimal: true)),
                ],
                if (isTimed || widget.exerciseDetails.type == ExerciseType.strength) // Allow duration for strength sets too (e.g. timed plank)
                  _buildTextField(_durationController, "Duration (seconds, optional)", TextInputType.number),

                _buildTextField(_restController, "Rest between sets (seconds, optional)", TextInputType.number),
                _buildTextField(_notesController, "Notes (e.g., tempo, form cues)", TextInputType.text, maxLines: 2),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _updatePlanExercise,
                  child: const Text("Update Exercise Details"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType, int? maxLines]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        // No onEditingComplete or onChanged here to avoid frequent updates, user will click "Update"
      ),
    );
  }
}


class CreateWorkoutScreen extends StatefulWidget {
  final WorkoutPlan? existingPlan; // To allow editing existing plans

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

  // For fetching actual exercises by ID when loading an existing plan
  // This is a placeholder; in a real app, you'd fetch from a service/DB.
  final Map<String, Exercise> _exerciseCache = {};

  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final String currentUserId = authManager.currentUser?.id ?? "default_user";

    if (widget.existingPlan != null) {
      _workoutPlan = widget.existingPlan!.copyWith(); // Make a mutable copy
      _planNameController.text = _workoutPlan.name;
      _planDescriptionController.text = _workoutPlan.description ?? '';
      // Populate cache for existing exercises (mocked)
      for (var pExercise in _workoutPlan.exercises) {
        if (pExercise.exerciseDetails != null) {
           _exerciseCache[pExercise.exerciseId] = pExercise.exerciseDetails!;
        } else {
          // In a real app, you might need to fetch details if not embedded
          // For now, we'll assume if not embedded, it's an issue or needs a placeholder
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
      id: _uuid.v4(), // Unique ID for this entry in the plan
      exerciseId: exercise.id,
      order: _workoutPlan.exercises.length,
      exerciseDetails: exercise, // Embed full details for easier UI building
      // Default sets/reps/etc. can be set here or in the PlanExerciseEditTile
    );
    setState(() {
      _workoutPlan = _workoutPlan.copyWith(
        exercises: [..._workoutPlan.exercises, newPlanExercise],
      );
      _exerciseCache[exercise.id] = exercise; // Cache it
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

  void _saveWorkoutPlan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        // Update the _workoutPlan object with the latest from controllers before saving
        _workoutPlan = _workoutPlan.copyWith(
          name: _planNameController.text,
          description: _planDescriptionController.text,
          updatedAt: DateTime.now(),
        );
      });

      try {
        final savedPlan = await ApiService().saveWorkoutPlan(_workoutPlan);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${savedPlan.name} saved successfully!')),
        );
        Navigator.of(context).pop(savedPlan); // Return the saved/updated plan
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingPlan == null ? "Create Workout Plan" : "Edit Workout Plan",
          style: GoogleFonts.inter(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.check_mark_circled),
            onPressed: _saveWorkoutPlan,
            tooltip: "Save Plan",
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView( // Changed to ListView for better scrolling with many exercises
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _planNameController,
              decoration: const InputDecoration(labelText: "Plan Name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a plan name";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _planDescriptionController,
              decoration: const InputDecoration(
                labelText: "Description (Optional)",
                hintText: "e.g., Focus on upper body strength, 3 times a week.",
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Exercises (${_workoutPlan.exercises.length})",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text("Add Exercise"),
                  onPressed: () async {
                    // Navigate to ExerciseLibraryScreen and wait for result
                    final selectedExercise = await Navigator.push<Exercise>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseLibraryScreen(isPickerMode: true),
                      ),
                    );
                    if (selectedExercise != null) {
                      _addExerciseToPlan(selectedExercise);
                    }
                    // No else needed here, if user cancels, selectedExercise will be null.
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_workoutPlan.exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Center(
                  child: Text(
                    "No exercises added yet. Click 'Add Exercise' to begin.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
                itemCount: _workoutPlan.exercises.length,
                itemBuilder: (context, index) {
                  final planExercise = _workoutPlan.exercises[index];
                  // Fetch full exercise details (assuming they were embedded or cached)
                  final exerciseDetails = planExercise.exerciseDetails ?? _exerciseCache[planExercise.exerciseId];

                  if (exerciseDetails == null) {
                    // This case should ideally not happen if data is handled correctly
                    return Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        title: Text("Error: Exercise details missing for ID ${planExercise.exerciseId}", style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                        trailing: IconButton(
                          icon: Icon(CupertinoIcons.delete, color: theme.colorScheme.onErrorContainer),
                          onPressed: () => _removeExerciseFromPlan(index),
                        ),
                      ),
                    );
                  }

                  return PlanExerciseEditTile(
                    key: ValueKey(planExercise.id), // Important for stateful list items
                    planExercise: planExercise,
                    exerciseDetails: exerciseDetails,
                    onUpdate: (updated) => _updatePlannedExercise(index, updated),
                    onRemove: () => _removeExerciseFromPlan(index),
                  );
                },
              ),
            const SizedBox(height: 30),
            // Summary (optional) could go here:
            // Text("Total Exercises: ${_workoutPlan.exercises.length}", style: theme.textTheme.titleMedium),
            // Text("Estimated Duration: ${_workoutPlan.estimatedDurationMinutes ?? 'N/A'} min", style: theme.textTheme.titleMedium),
            // const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _saveWorkoutPlan,
              child: Text(widget.existingPlan == null ? "Save Workout Plan" : "Update Workout Plan", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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
