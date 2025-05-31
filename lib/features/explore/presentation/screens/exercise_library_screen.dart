import 'package:aksumfit/models/exercise.dart'; // Updated import
import 'package:aksumfit/core/extensions/string_extensions.dart'; // Import for capitalize
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name, style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Changed to ListView for potentially longer content
          children: [
            if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network( // Assuming network URL for now, can be adapted for assets
                  exercise.imageUrl!,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(CupertinoIcons.photo, size: 100, color: theme.colorScheme.primary),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              exercise.name,
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.headlineMedium?.fontSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              exercise.description.isNotEmpty ? exercise.description : "No description available.",
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.bodyLarge?.fontSize,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(theme, "Type:", exercise.type.toString().split('.').last),
            _buildDetailRow(theme, "Muscle Groups:", exercise.muscleGroups.join(', ')),
            _buildDetailRow(theme, "Equipment:", exercise.equipment.join(', ')),
            if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(CupertinoIcons.play_rectangle_fill),
                label: const Text('Watch Video'),
                onPressed: () {
                  // TODO: Implement video player logic (e.g., using url_launcher or an inline player)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Video URL: ${exercise.videoUrl}')),
                  );
                },
              ),
            ],
            if (isPickerMode) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(CupertinoIcons.check_mark_circled_solid),
                label: const Text('Select Exercise'),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                onPressed: () {
                  Navigator.of(context).pop(exercise); // Return the selected exercise
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: GoogleFonts.inter(
              fontSize: theme.textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "N/A",
              style: GoogleFonts.inter(
                fontSize: theme.textTheme.titleMedium?.fontSize,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ExerciseLibraryScreen extends StatefulWidget {
  final bool isPickerMode; // If true, allows selecting an exercise to return

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

  // Sample filter options
  List<String> _muscleGroupFilters = [];
  List<String> _equipmentFilters = [];

  // Available options for filters (could be fetched from a service)
  final List<String> _availableMuscleGroups = ["Chest", "Back", "Legs", "Shoulders", "Biceps", "Triceps", "Abs", "Full Body"];
  final List<String> _availableEquipment = ["Barbell", "Dumbbell", "Kettlebell", "Machine", "Bodyweight", "Bands"];


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
    return [
      Exercise(id: _uuid.v4(), name: "Bench Press", description: "Compound chest exercise.", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: ["Barbell", "Bench"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YmVuY2glMjBwcmVzc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Squat", description: "Compound leg exercise.", muscleGroups: ["Legs", "Glutes", "Core"], equipment: ["Barbell"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1599058917212-d750089bc07e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8c3F1YXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Deadlift", description: "Full body compound exercise.", muscleGroups: ["Back", "Legs", "Glutes", "Core", "Full Body"], equipment: ["Barbell"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Overhead Press", description: "Compound shoulder exercise.", muscleGroups: ["Shoulders", "Triceps"], equipment: ["Barbell"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Pull Up", description: "Upper body pulling exercise.", muscleGroups: ["Back", "Biceps"], equipment: ["Bodyweight", "Pull-up bar"], type: ExerciseType.strength, imageUrl: "https://images.unsplash.com/photo-1574283800482-727484c8b99e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHVsbCUyMHVwfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60"),
      Exercise(id: _uuid.v4(), name: "Push Up", description: "Upper body pushing exercise.", muscleGroups: ["Chest", "Triceps", "Shoulders", "Core"], equipment: ["Bodyweight"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Dumbbell Row", description: "Unilateral back exercise.", muscleGroups: ["Back", "Biceps"], equipment: ["Dumbbell", "Bench"], type: ExerciseType.strength),
      Exercise(id: _uuid.v4(), name: "Plank", description: "Core stability exercise.", muscleGroups: ["Abs", "Core"], equipment: ["Bodyweight"], type: ExerciseType.strength, durationSeconds: 60), // Example of strength exercise with duration
      Exercise(id: _uuid.v4(), name: "Running", description: "Cardiovascular exercise.", muscleGroups: ["Legs", "Full Body"], equipment: ["Bodyweight"], type: ExerciseType.cardio, durationSeconds: 1800),
      Exercise(id: _uuid.v4(), name: "Cycling", description: "Cardiovascular exercise.", muscleGroups: ["Legs"], equipment: ["Machine"], type: ExerciseType.cardio, durationSeconds: 1800),
      Exercise(id: _uuid.v4(), name: "Jumping Jacks", description: "Full body cardio.", muscleGroups: ["Full Body"], equipment: ["Bodyweight"], type: ExerciseType.plyometrics, durationSeconds: 120),
      Exercise(id: _uuid.v4(), name: "Hamstring Stretch", description: "Static stretch for hamstrings.", muscleGroups: ["Legs"], equipment: ["Bodyweight"], type: ExerciseType.stretch, durationSeconds: 30),
    ];
  }

  void _filterExercises() {
    List<Exercise> tempFiltered = List.from(_allExercises);

    // Filter by search term
    if (_searchTerm.isNotEmpty) {
      tempFiltered = tempFiltered.where((exercise) {
        return exercise.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
               exercise.description.toLowerCase().contains(_searchTerm.toLowerCase());
      }).toList();
    }

    // Filter by selected muscle groups (AND logic if multiple selected, OR if you prefer)
    if (_muscleGroupFilters.isNotEmpty) {
      tempFiltered = tempFiltered.where((exercise) {
        return _muscleGroupFilters.every((filter) => exercise.muscleGroups.contains(filter));
      }).toList();
    }

    // Filter by selected equipment
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for taller content
      builder: (BuildContext context) {
        // Using StatefulWidget for the dialog content to manage its own state for selections
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.75, // Take 75% of screen height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Exercises", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          "Muscle Groups",
                          _availableMuscleGroups,
                          _muscleGroupFilters,
                          (value, isSelected) {
                            setDialogState(() {
                              isSelected ? _muscleGroupFilters.add(value) : _muscleGroupFilters.remove(value);
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildFilterSection(
                          "Equipment",
                          _availableEquipment,
                          _equipmentFilters,
                          (value, isSelected) {
                            setDialogState(() {
                              isSelected ? _equipmentFilters.add(value) : _equipmentFilters.remove(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       TextButton(
                        onPressed: () {
                          setDialogState(() {
                            _muscleGroupFilters.clear();
                            _equipmentFilters.clear();
                          });
                           _filterExercises(); // Apply cleared filters
                        },
                        child: const Text("Clear All"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _filterExercises(); // Apply filters
                          Navigator.pop(context); // Close dialog
                        },
                        child: const Text("Apply Filters"),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> availableOptions,
    List<String> selectedOptions,
    Function(String, bool) onOptionSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: availableOptions.map((option) {
            final bool isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                onOptionSelected(option, selected);
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Library', style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              // Could expand search into the AppBar or use a dedicated search bar below
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search exercises...",
                prefixIcon: Icon(CupertinoIcons.search, color: theme.inputDecorationTheme.prefixIconColor ?? theme.colorScheme.onSurfaceVariant),
                // Using theme's input decoration
              ),
            ),
          ),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      "No exercises found.",
                      style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Card(
                        // Using CardTheme from main.dart
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          leading: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    exercise.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color:theme.colorScheme.surfaceContainerHighest, child: Icon(CupertinoIcons.photo, color: theme.colorScheme.primary, size:30)),
                                  ),
                                )
                              : Container(width: 60, height: 60, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8.0)), child: Icon(CupertinoIcons.flame_fill, color: theme.colorScheme.primary,  size:30)),
                          title: Text(
                            exercise.name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            "${exercise.type.toString().split('.').last.capitalize()} - ${exercise.muscleGroups.take(2).join(', ')}${exercise.muscleGroups.length > 2 ? '...' : ''}",
                            style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(CupertinoIcons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                          onTap: () {
                            if (widget.isPickerMode) {
                              Navigator.of(context).pop(exercise); // Return selected exercise
                            } else {
                              // Navigate to detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(
                                    exercise: exercise,
                                    isPickerMode: widget.isPickerMode, // Pass it along, though detail might not need it if selection happens on list
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Removed local StringExtension for capitalize
