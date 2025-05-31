import 'package:flutter/material.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/models/workout_plan.dart'; // WorkoutPlanCategory is here
// Potentially import Provider if you decide to use Provider.of for ApiService,
// though direct singleton usage is also common for services like ApiService.
// import 'package:provider/provider.dart';

class BrowseWorkoutsScreen extends StatefulWidget {
  const BrowseWorkoutsScreen({super.key});

  @override
  State<BrowseWorkoutsScreen> createState() => _BrowseWorkoutsScreenState();
}

class _BrowseWorkoutsScreenState extends State<BrowseWorkoutsScreen> {
  List<WorkoutPlan> _workoutPlans = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TextEditingController _searchController;
  String _searchText = "";

  static const String _allGoalsValue = "All Goals"; // For the dropdown

  // Filter values
  String? _selectedGoal = _allGoalsValue; // Default to "All Goals"
  String? _selectedDuration;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchText = _searchController.text;
        });
      }
    });
    _fetchWorkouts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final plans = await ApiService().getWorkoutPlans();
      if (mounted) {
        setState(() {
          _workoutPlans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch workouts: ${e.toString()}';
        });
        if (context.mounted) { // Check if context is still valid
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_errorMessage!))
             );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare items for Goal Dropdown
    List<DropdownMenuItem<String>> goalDropdownItems = [
      const DropdownMenuItem<String>(value: _allGoalsValue, child: Text(_allGoalsValue)),
      ...WorkoutPlanCategory.values.map((WorkoutPlanCategory category) {
        return DropdownMenuItem<String>(
          value: category.toString(), // Use enum.toString() as value
          child: Text(category.displayName),
        );
      }).toList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Workouts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search workouts by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildFilterDropdown(
                  hint: "Goal",
                  value: _selectedGoal,
                  items: goalDropdownItems, // Use generated items
                  onChanged: (value) => setState(() {
                     _selectedGoal = value;
                     // Optionally call a filter function here if not relying on build method's filter
                  }),
                ),
                // Placeholder for Duration Dropdown (can be built similarly)
                _buildFilterDropdown(
                  hint: "Duration",
                  value: _selectedDuration,
                   items: [ // Example items, replace with actual logic if needed
                    const DropdownMenuItem<String>(value: "All Durations", child: Text("All Durations")),
                    const DropdownMenuItem<String>(value: "<30min", child: Text("<30min")),
                    const DropdownMenuItem<String>(value: "30-60min", child: Text("30-60min")),
                    const DropdownMenuItem<String>(value: ">60min", child: Text(">60min")),
                  ],
                  onChanged: (value) => setState(() => _selectedDuration = value),
                ),
                 // Placeholder for Difficulty Dropdown (can be built similarly)
                _buildFilterDropdown(
                  hint: "Difficulty",
                  value: _selectedDifficulty,
                  items: [ // Example items, replace with actual logic if needed
                    const DropdownMenuItem<String>(value: "All Difficulties", child: Text("All Difficulties")),
                    const DropdownMenuItem<String>(value: "Beginner", child: Text("Beginner")),
                    const DropdownMenuItem<String>(value: "Intermediate", child: Text("Intermediate")),
                    const DropdownMenuItem<String>(value: "Advanced", child: Text("Advanced")),
                  ],
                  onChanged: (value) => setState(() => _selectedDifficulty = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildWorkoutList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items, // Changed to accept DropdownMenuItems
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      value: value,
      // hint: Text(hint), // LabelText is usually enough
      items: items,
      onChanged: onChanged,
      isExpanded: false,
    );
  }

  Widget _buildWorkoutList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center,),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchWorkouts, child: const Text('Retry'))
            ],
          ),
        )
      );
    }

    final filteredByName = _workoutPlans.where((plan) {
      return plan.name.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

    final filteredByGoal = filteredByName.where((plan) {
      if (_selectedGoal == null || _selectedGoal == _allGoalsValue) {
        return true; // No goal filter applied or "All Goals" selected
      }
      return plan.category.toString() == _selectedGoal;
    }).toList();

    // TODO: Add similar filtering for _selectedDuration and _selectedDifficulty

    final displayedPlans = filteredByGoal; // This will be the final list to display

    if (displayedPlans.isEmpty && !_isLoading) {
      return Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No workouts match your criteria.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { // Reset filters and refresh
                setState(() {
                  _searchController.clear(); // Clears text and triggers listener to set _searchText to ""
                  _selectedGoal = _allGoalsValue;
                  _selectedDuration = null; // Or your "All Durations" value
                  _selectedDifficulty = null; // Or your "All Difficulties" value
                });
                _fetchWorkouts(); // Refetch all workouts
              },
              child: const Text('Clear Filters & Refresh')
            )
          ],
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: displayedPlans.length,
      itemBuilder: (context, index) {
        final plan = displayedPlans[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Category: ${plan.category.displayName}'),
                Text('Difficulty: ${plan.difficulty.displayName}'),
                Text('Duration: ${plan.estimatedDurationMinutes} min'),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on: ${plan.name}'))
              );
            },
          ),
        );
      },
    );
  }
}
