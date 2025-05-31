import 'package:aksumfit/models/exercise.dart'; // Updated import
import 'package:aksumfit/core/extensions/string_extensions.dart'; // Import for capitalize
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs for sample data

// Placeholder for Exercise Detail Screen
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final bool isPickerMode; // To show a select button if in picker mode

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.isPickerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(exercise.name),
        previousPageTitle: "Library", // Assuming back navigation to library
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    exercise.imageUrl!,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: CupertinoColors.secondarySystemFill,
                      child: const Icon(CupertinoIcons.photo,
                          size: 100, color: CupertinoColors.systemGrey),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                exercise.name,
                style: cupertinoTheme.textTheme.navLargeTitleTextStyle
                    .copyWith(color: CupertinoColors.label),
              ),
              const SizedBox(height: 12),
              Text(
                exercise.description.isNotEmpty
                    ? exercise.description
                    : "No description available.",
                style: cupertinoTheme.textTheme.textStyle
                    .copyWith(color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(height: 20),
              _buildDetailRowCupertino(cupertinoTheme, "Type:",
                  exercise.type.toString().split('.').last),
              _buildDetailRowCupertino(
                  cupertinoTheme, "Muscle Groups:", exercise.muscleGroups.join(', ')),
              _buildDetailRowCupertino(
                  cupertinoTheme, "Equipment:", exercise.equipment.join(', ')),
              if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.play_rectangle_fill),
                      SizedBox(width: 8),
                      Text('Watch Video'),
                    ],
                  ),
                  onPressed: () {
                    // TODO: Implement video player logic
                    showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                              title: const Text("Video Unavailable"),
                              content: Text(
                                  "Video playback for ${exercise.videoUrl} is not yet implemented."),
                              actions: [
                                CupertinoDialogAction(
                                    child: const Text("OK"),
                                    onPressed: () => Navigator.pop(context))
                              ],
                            ));
                  },
                ),
              ],
              if (isPickerMode) ...[
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(CupertinoIcons.check_mark_circled_solid),
                       SizedBox(width: 8),
                       Text('Select Exercise'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(exercise);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRowCupertino(
      CupertinoThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: theme.textTheme.navTitleTextStyle
                .copyWith(color: CupertinoColors.label),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "N/A",
              style: theme.textTheme.textStyle
                  .copyWith(color: CupertinoColors.secondaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseLibraryScreen extends StatefulWidget {
  final bool isPickerMode;

  const ExerciseLibraryScreen({super.key, this.isPickerMode = false});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final Uuid _uuid = const Uuid();
  late List<Exercise> _allExercises;
  List<Exercise> _filteredExercises = [];
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _muscleGroupFilters = [];
  final List<String> _equipmentFilters = [];

  final List<String> _availableMuscleGroups = [
    "Chest", "Back", "Legs", "Shoulders", "Biceps", "Triceps", "Abs", "Full Body"
  ];
  final List<String> _availableEquipment = [
    "Barbell", "Dumbbell", "Kettlebell", "Machine", "Bodyweight", "Bands"
  ];

  @override
  void initState() {
    super.initState();
    _allExercises = _generateSampleExercises();
    _filteredExercises = List.from(_allExercises);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _filterExercises();
      });
    });
  }

  List<Exercise> _generateSampleExercises() {
    // Same as before
    return [
      Exercise(id: _uuid.v4(), name: "Bench Press", description: "Compound chest exercise.", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: ["Barbell", "Bench"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YmVuY2glMjBwcmVzc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Squat", description: "Compound leg exercise.", muscleGroups: ["Legs", "Glutes", "Core"], equipment: ["Barbell"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1599058917212-d750089bc07e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8c3F1YXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Deadlift", description: "Full body compound exercise.", muscleGroups: ["Back", "Legs", "Glutes", "Core", "Full Body"], equipment: ["Barbell"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Overhead Press", description: "Compound shoulder exercise.", muscleGroups: ["Shoulders", "Triceps"], equipment: ["Barbell"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Pull Up", description: "Upper body pulling exercise.", muscleGroups: ["Back", "Biceps"], equipment: ["Bodyweight", "Pull-up bar"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1574283800482-727484c8b99e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHVsbCUyMHVwfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Push Up", description: "Upper body pushing exercise.", muscleGroups: ["Chest", "Triceps", "Shoulders", "Core"], equipment: ["Bodyweight"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Dumbbell Row", description: "Unilateral back exercise.", muscleGroups: ["Back", "Biceps"], equipment: ["Dumbbell", "Bench"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Plank", description: "Core stability exercise.", muscleGroups: ["Abs", "Core"], equipment: ["Bodyweight"], type: ExerciseType.strength, durationSeconds: 60),
      Exercise(id: _uuid.v4(), name: "Running", description: "Cardiovascular exercise.", muscleGroups: ["Legs", "Full Body"], equipment: ["Bodyweight"], type: ExerciseType.cardio, durationSeconds: 1800),
      Exercise(id: _uuid.v4(), name: "Cycling", description: "Cardiovascular exercise.", muscleGroups: ["Legs"], equipment: ["Machine"], type: ExerciseType.cardio, durationSeconds: 1800),
      Exercise(id: _uuid.v4(), name: "Jumping Jacks", description: "Full body cardio.", muscleGroups: ["Full Body"], equipment: ["Bodyweight"], type: ExerciseType.plyometrics, durationSeconds: 120),
      Exercise(id: _uuid.v4(), name: "Hamstring Stretch", description: "Static stretch for hamstrings.", muscleGroups: ["Legs"], equipment: ["Bodyweight"], type: ExerciseType.stretch, durationSeconds: 30),
    ];
  }

  void _filterExercises() {
    // Same as before
     List<Exercise> tempFiltered = List.from(_allExercises);

    if (_searchTerm.isNotEmpty) {
      tempFiltered = tempFiltered.where((exercise) {
        return exercise.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
               exercise.description.toLowerCase().contains(_searchTerm.toLowerCase());
      }).toList();
    }

    if (_muscleGroupFilters.isNotEmpty) {
      tempFiltered = tempFiltered.where((exercise) {
        return _muscleGroupFilters.every((filter) => exercise.muscleGroups.contains(filter));
      }).toList();
    }

    if (_equipmentFilters.isNotEmpty) {
      tempFiltered = tempFiltered.where((exercise) {
        return _equipmentFilters.every((filter) => exercise.equipment.contains(filter));
      }).toList();
    }

    setState(() {
      _filteredExercises = tempFiltered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return CupertinoActionSheet(
              title: const Text("Filter Exercises"),
              message: SizedBox( // Constrain height of the ActionSheet
                height: MediaQuery.of(context).size.height * 0.4, // Adjust as needed
                child: ListView(
                  children: [
                    _buildCupertinoFilterSection(
                      "Muscle Groups",
                      _availableMuscleGroups,
                      _muscleGroupFilters,
                      (value, isSelected) {
                        setDialogState(() {
                          isSelected
                              ? _muscleGroupFilters.add(value)
                              : _muscleGroupFilters.remove(value);
                        });
                      },
                    ),
                    _buildCupertinoFilterSection(
                      "Equipment",
                      _availableEquipment,
                      _equipmentFilters,
                      (value, isSelected) {
                        setDialogState(() {
                          isSelected
                              ? _equipmentFilters.add(value)
                              : _equipmentFilters.remove(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  child: const Text("Apply Filters"),
                  onPressed: () {
                    _filterExercises();
                    Navigator.pop(context);
                  },
                ),
                 CupertinoActionSheetAction(
                  child: const Text("Clear All", style: TextStyle(color: CupertinoColors.destructiveRed)),
                  onPressed: () {
                    setDialogState(() {
                      _muscleGroupFilters.clear();
                      _equipmentFilters.clear();
                    });
                    _filterExercises();
                  },
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCupertinoFilterSection(
    String title,
    List<String> availableOptions,
    List<String> selectedOptions,
    Function(String, bool) onOptionSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(title, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: availableOptions.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add some padding
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.secondarySystemFill,
                  child: Text(option, style: TextStyle(color: isSelected ? CupertinoColors.white : CupertinoColors.label)),
                  onPressed: () {
                     onOptionSelected(option, !isSelected);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Exercise Library'),
        previousPageTitle: "Explore",
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showFilterDialog,
          child: const Icon(CupertinoIcons.slider_horizontal_3),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: "Search exercises...",
            ),
          ),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      "No exercises found.",
                      style: cupertinoTheme.textTheme.textStyle
                          .copyWith(color: CupertinoColors.secondaryLabel),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0), // No horizontal padding for list itself
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return CupertinoListTile(
                        leading: exercise.imageUrl != null &&
                                exercise.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  exercise.imageUrl!,
                                  width: 50, height: 50, fit: BoxFit.cover, // Smaller image
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(width: 50, height: 50, color: CupertinoColors.secondarySystemFill, child: const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey, size: 25)),
                                ),
                              )
                            : Container(width: 50, height: 50, decoration: BoxDecoration(color: CupertinoColors.secondarySystemFill, borderRadius: BorderRadius.circular(8.0)), child: const Icon(CupertinoIcons.flame_fill, color: CupertinoColors.systemGrey, size: 25)),
                        title: Text(exercise.name),
                        subtitle: Text(
                          "${exercise.type.toString().split('.').last.capitalize()} - ${exercise.muscleGroups.take(2).join(', ')}${exercise.muscleGroups.length > 2 ? '...' : ''}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(CupertinoIcons.forward),
                        onTap: () {
                          if (widget.isPickerMode) {
                            Navigator.of(context).pop(exercise);
                          } else {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ExerciseDetailScreen(
                                  exercise: exercise,
                                  isPickerMode: widget.isPickerMode,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
