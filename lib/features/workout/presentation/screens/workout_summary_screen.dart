import 'package:aksumfit/models/workout_log.dart'; // Import WorkoutLog
import 'package:flutter/cupertino.dart';
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
    final cupertinoTheme = CupertinoTheme.of(context);

    if (workoutLog == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text("Workout Summary")),
        child: const Center(
          child: Text(
            "No workout summary available.",
            style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel),
          ),
        ),
        // No bottom button if no log
      );
    }

    final String planName = workoutLog!.planName ?? "Ad-hoc Workout";
    final Duration workoutDuration = workoutLog!.endTime.difference(workoutLog!.startTime);
    final String formattedDuration = _formatDuration(workoutDuration);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(planName),
        automaticallyImplyLeading: false, // No back button
      ),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSummaryHeaderCupertino(cupertinoTheme, planName, formattedDuration),
                CupertinoListSection.insetGrouped(
                  header: const Text("Details"),
                  children: workoutLog!.completedExercises.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0), // More padding for standalone message
                            child: Center(
                              child: Text(
                                "No exercises were logged for this workout.",
                                style: TextStyle(color: CupertinoColors.secondaryLabel),
                              ),
                            ),
                          )
                        ]
                      : workoutLog!.completedExercises.map((loggedEx) {
                          return CupertinoListTile.notched(
                            title: Text(loggedEx.exerciseName, style: cupertinoTheme.textTheme.navTitleTextStyle),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (loggedEx.sets.isNotEmpty)
                                  ...loggedEx.sets.map((set) {
                                    return Text(
                                      "Set ${set.setNumber}: ${set.repsAchieved ?? 'N/A'} reps @ ${set.weightUsedKg ?? 'N/A'} kg ${set.isCompleted ? '(Completed)' : ''}",
                                      style: cupertinoTheme.textTheme.tabLabelTextStyle,
                                    );
                                  }).toList(),
                                if (loggedEx.durationAchievedSeconds != null && loggedEx.durationAchievedSeconds! > 0)
                                  Text(
                                    "Duration: ${_formatDuration(Duration(seconds: loggedEx.durationAchievedSeconds!))}",
                                    style: cupertinoTheme.textTheme.tabLabelTextStyle,
                                  ),
                                if (loggedEx.notes != null && loggedEx.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text("Notes: ${loggedEx.notes}", style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontStyle: FontStyle.italic)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
                if (workoutLog!.notes != null && workoutLog!.notes!.isNotEmpty)
                  CupertinoListSection.insetGrouped(
                    header: const Text("Workout Notes"),
                    children: [CupertinoListTile(title: Text(workoutLog!.notes!))],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          SliverFillRemaining( // Pushes button to bottom
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                 padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16.0),
                child: SizedBox( // Ensure button takes full width
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    child: const Text("Done"),
                    onPressed: () {
                      if (context.mounted) {
                        context.go('/main');
                      }
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryHeaderCupertino(CupertinoThemeData theme, String planName, String formattedDuration) {
    return Padding(
      padding: const EdgeInsets.all(20.0), // Increased padding for header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.checkmark_seal_fill, size: 60, color: theme.primaryColor),
          const SizedBox(height: 12),
          Text(
            "Workout Complete!",
            style: theme.textTheme.navLargeTitleTextStyle.copyWith(color: theme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text("Plan: $planName", style: theme.textTheme.navTitleTextStyle),
          const SizedBox(height: 8),
          Text("Total Duration: $formattedDuration", style: theme.textTheme.textStyle),
          const SizedBox(height: 8),
          Text(
            "Date: ${DateFormat.yMMMd().add_jm().format(workoutLog!.startTime)}",
            style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel),
          ),
        ],
      ),
    );
  }
}
