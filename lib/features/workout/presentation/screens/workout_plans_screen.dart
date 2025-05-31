import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/features/workout/create_workout_screen.dart';
import 'package:aksumfit/features/workout/workout_screen.dart'; // The active workout session screen
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Keep for ScaffoldMessenger, MaterialPageRoute
import 'package:go_router/go_router.dart';
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
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("My Workout Plans"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _navigateToCreatePlan(),
        ),
      ),
      child: FutureBuilder<List<WorkoutPlan>>(
        future: _workoutPlansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading plans: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.doc_text_search, size: 80, color: CupertinoColors.secondaryLabel),
                  const SizedBox(height: 20),
                  const Text(
                    "No workout plans yet.",
                    style: TextStyle(fontSize: 18, color: CupertinoColors.secondaryLabel),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the '+' button to create your first plan!",
                    style: TextStyle(fontSize: 14, color: CupertinoColors.tertiaryLabel),
                  ),
                ],
              ),
            );
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0), // Add padding for the first section
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile.notched(
                    leading: CircleAvatar(
                      backgroundColor: cupertinoTheme.primaryColor.withOpacity(0.1),
                      child: Text(plan.name.isNotEmpty ? plan.name[0].toUpperCase() : "?",
                          style: TextStyle(color: cupertinoTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(plan.name, style: cupertinoTheme.textTheme.navTitleTextStyle),
                    subtitle: Text(
                      "${plan.exercises.length} exercises - ${StringExtension(plan.difficulty.toString().split('.').last).capitalize()}",
                    ),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.ellipsis_vertical),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => CupertinoActionSheet(
                            actions: <CupertinoActionSheetAction>[
                              CupertinoActionSheetAction(
                                child: const Text('Edit Plan'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _navigateToCreatePlan(planToEdit: plan);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Delete Plan'),
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deletePlan(plan);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => WorkoutScreen(plan: plan)),
                      ).then((_) => _loadWorkoutPlans());
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
