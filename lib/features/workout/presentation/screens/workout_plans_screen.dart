import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/features/workout/create_workout_screen.dart';
import 'package:aksumfit/features/workout/workout_screen.dart'; // The active workout session screen

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/services/auth_manager.dart';


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
    // It's important that AuthManager is listened to here if you want UI to rebuild
    // if the user changes, or ensure _currentUserId is available.
    // However, for fetching data tied to a user, it's often better to get it once.
    // If AuthManager could notify listeners and this screen needs to react,
    // consider using a Consumer or context.watch. For a one-time fetch, context.read is fine.
    _currentUserId = Provider.of<AuthManager>(context, listen: false).currentUser?.id;
    _loadWorkoutPlans();
  }

  void _loadWorkoutPlans() {
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
      // A plan was saved (created or updated)
      _loadWorkoutPlans(); // Refresh the list
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("${result.name} ${planToEdit == null ? 'created' : 'updated'}.")));
    }
  }

  void _deletePlan(WorkoutPlan plan) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Plan"),
        content: Text("Are you sure you want to delete the plan \"${plan.name}\"? This action cannot be undone."),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop(false)),
          CupertinoDialogAction(child: const Text("Delete"), isDestructiveAction: true, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        bool deleted = await ApiService().deleteWorkoutPlan(plan.id);
        if (deleted) {
          _loadWorkoutPlans();
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("${plan.name} deleted.")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete ${plan.name}.")));
        }
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting plan: $e")));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Workout Plans", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        // Potentially add actions like filter or sort if list becomes long
      ),
      body: FutureBuilder<List<WorkoutPlan>>(
        future: _workoutPlansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading plans: ${snapshot.error}", style: GoogleFonts.inter()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.doc_text_search, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text(
                    "No workout plans yet.",
                    style: GoogleFonts.inter(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the '+' button to create your first plan!",
                    style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            );
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical:10.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(plan.name.isNotEmpty ? plan.name[0].toUpperCase() : "?", style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(plan.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    "${plan.exercises.length} exercises - ${StringExtension(plan.difficulty.toString().split('.').last).capitalize()}",
                     style: GoogleFonts.inter(),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToCreatePlan(planToEdit: plan);
                      } else if (value == 'delete') {
                        _deletePlan(plan);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(CupertinoIcons.pencil), title: Text('Edit'))),
                      const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(CupertinoIcons.delete), title: Text('Delete'))),
                    ],
                    icon: Icon(CupertinoIcons.ellipsis_vertical, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  onTap: () {
                    // Navigate to WorkoutScreen (active session) with the selected plan
                    // Ensure WorkoutScreen is registered in GoRouter if not already
                    // For now, direct MaterialPageRoute for simplicity if WorkoutScreen is not part of main nav stack
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutScreen(plan: plan)),
                    ).then((_) => _loadWorkoutPlans()); // Refresh plans if user comes back, e.g. after a workout
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreatePlan(),
        icon: const Icon(CupertinoIcons.add),
        label: const Text("Create Plan"),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        foregroundColor: theme.colorScheme.onTertiaryContainer,
      ),
    );
  }
}
