import 'package:aksumfit/models/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroWorkoutBanner extends StatelessWidget {
  final WorkoutPlan? workoutPlan; // Accept a nullable WorkoutPlan

  const HeroWorkoutBanner({super.key, this.workoutPlan});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final String workoutName = workoutPlan?.name ?? "No Plan for Today";
    final String workoutDuration = workoutPlan?.estimatedDurationMinutes != null
        ? "${workoutPlan!.estimatedDurationMinutes} Mins"
        : "Explore Plans";
    final bool canStartWorkout = workoutPlan != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ colorScheme.primary, colorScheme.secondary ],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              canStartWorkout ? "Today's Focus" : "Find a Workout",
              style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutName,
                        style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onPrimary.withOpacity(0.95),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        workoutDuration,
                        style: GoogleFonts.inter(fontSize: 14, color: colorScheme.onPrimary.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: canStartWorkout
                      ? () {
                          // Navigate to WorkoutScreen with the plan
                          context.go('/workout-session', extra: workoutPlan);
                        }
                      : () {
                          // Navigate to workout plans screen
                          context.go('/workout-plans');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary,
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: Text(canStartWorkout ? "Start Workout" : "View Plans"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
