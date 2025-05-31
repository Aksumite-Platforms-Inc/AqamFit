import 'package:aksumfit/models/workout_log.dart'; // Import WorkoutLog
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutLog? workoutLog; // WorkoutLog can be nullable

  const WorkoutSummaryScreen({super.key, this.workoutLog});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    if (workoutLog == null) {
      // Handle case where no log data is passed (e.g., direct navigation or error)
      return Scaffold(
        appBar: AppBar(title: Text("Workout Summary", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary))),
        body: Center(
          child: Text(
            "No workout summary available.",
            style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        bottomNavigationBar: _buildDoneButton(context, theme),
      );
    }

    final String planName = workoutLog!.planName ?? "Ad-hoc Workout";
    final Duration workoutDuration = workoutLog!.endTime.difference(workoutLog!.startTime);
    final String formattedDuration = _formatDuration(workoutDuration);

    return Scaffold(
      appBar: AppBar(
        title: Text(planName, style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryHeader(theme, textTheme, planName, formattedDuration),
          const SizedBox(height: 24),
          Text("Details:", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const Divider(thickness: 1, height: 20),
          if (workoutLog!.completedExercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "No exercises were logged for this workout.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            ...workoutLog!.completedExercises.map((loggedEx) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loggedEx.exerciseName, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      if (loggedEx.sets.isNotEmpty)
                        ...loggedEx.sets.map((set) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text(
                              "Set ${set.setNumber}: ${set.repsAchieved ?? 'N/A'} reps @ ${set.weightUsedKg ?? 'N/A'} kg ${set.isCompleted ? '(Completed)' : ''}",
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                      if (loggedEx.durationAchievedSeconds != null && loggedEx.durationAchievedSeconds! > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            "Duration: ${_formatDuration(Duration(seconds: loggedEx.durationAchievedSeconds!))}",
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      if (loggedEx.notes != null && loggedEx.notes!.isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                           child: Text("Notes: ${loggedEx.notes}", style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                         ),
                    ],
                  ),
                ),
              );
            }).toList(),

          if (workoutLog!.notes != null && workoutLog!.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text("Workout Notes:", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(thickness: 1, height: 20),
            Text(workoutLog!.notes!, style: textTheme.bodyLarge),
          ],
          const SizedBox(height: 30),
          // TODO: Add more summary data like calories burned, PRs, etc.
        ],
      ),
      bottomNavigationBar: _buildDoneButton(context, theme),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, TextTheme textTheme, String planName, String formattedDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.checkmark_seal_fill, size: 60, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          "Workout Complete!",
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text("Plan: $planName", style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text("Total Duration: $formattedDuration", style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          "Date: ${DateFormat.yMMMd().add_jm().format(workoutLog!.startTime)}",
          style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (context.mounted) {
            context.go('/main'); // Navigate back to the main part of the app
          }
        },
        child: Text("Done", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
