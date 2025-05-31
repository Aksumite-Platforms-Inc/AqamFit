import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/features/workout/create_workout_screen.dart';
import 'package:aksumfit/features/workout/workout_screen.dart'; // The active workout session screen
import 'package:flutter/material.dart'; // Changed from Cupertino
// import 'package:go_router/go_router.dart'; // Not explicitly used for navigation here, but good for consistency
import 'package:provider/provider.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart'; // For capitalize

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  Future<List<WorkoutPlan>>? _workoutPlansFuture;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<AuthManager>(context, listen: false).currentUser?.id;
    _loadWorkoutPlans();
  }

  void _loadWorkoutPlans() {
    if (_currentUserId == null) {
      // Handle case where user ID is not available (e.g., show error or empty state)
      setState(() {
        _workoutPlansFuture = Future.value([]); // Or Future.error("User not logged in");
      });
      return;
    }
    setState(() {
      _workoutPlansFuture = ApiService().getWorkoutPlans(userId: _currentUserId);
    });
  }

  Future<void> _navigateToCreatePlan({WorkoutPlan? planToEdit}) async {
    final result = await Navigator.push<WorkoutPlan>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(existingPlan: planToEdit),
      ),
    );
    if (result != null) {
      _loadWorkoutPlans();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("${result.name} ${planToEdit == null ? 'created' : 'updated'}.")));
      }
    }
  }

  void _startWorkout(WorkoutPlan plan) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutScreen(plan: plan)),
    ).then((_) => _loadWorkoutPlans()); // Refresh list if workout session leads to changes
  }

  void _deletePlan(WorkoutPlan plan) async {
    final confirm = await showDialog<bool>( // Changed to showDialog
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Plan"),
        content: Text("Are you sure you want to delete the plan \"${plan.name}\"? This action cannot be undone."),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        bool deleted = await ApiService().deleteWorkoutPlan(plan.id);
        if (mounted) {
          if (deleted) {
            _loadWorkoutPlans();
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text("${plan.name} deleted.")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete ${plan.name}.")));
          }
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting plan: $e")));
         }
      }
    }
  }

  void _showWorkoutPlanOptions(BuildContext context, WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Plan'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToCreatePlan(planToEdit: plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text('Delete Plan', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _deletePlan(plan);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get Material theme
    return Scaffold( // Changed to Scaffold
      appBar: AppBar( // Changed to AppBar
        title: const Text("My Workout Plans"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreatePlan(),
          ),
        ],
      ),
      body: FutureBuilder<List<WorkoutPlan>>(
        future: _workoutPlansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Changed to CircularProgressIndicator
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}")); // Simplified error message
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 50, color: Colors.grey[400]), // Material Icon
                  const SizedBox(height: 16),
                  Text("No workout plans yet.", style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text("Tap '+' to create your first plan!", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0), // Add padding around the list
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card( // Changed to Card
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile( // Changed to ListTile
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(plan.name.isNotEmpty ? plan.name[0].toUpperCase() : "?",
                        style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(plan.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    "${plan.exercises.length} exercises - ${plan.difficulty.toString().split('.').last.capitalize()}",
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  trailing: IconButton( // Changed to IconButton for options
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showWorkoutPlanOptions(context, plan),
                  ),
                  onTap: () => _startWorkout(plan), // Navigate to start workout
                ),
              );
            },
          );
        },
      ),
    );
  }
}
