import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String owner;
  final int participantCount;
  final bool isJoined; // To determine "Join" or "View Details" emphasis

  const ChallengeCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    this.owner = "AksumFit Community",
    this.participantCount = 0,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Use screen padding from parent
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Ensures content respects card's shape
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Placeholder
          Container(
            height: 120,
            width: double.infinity,
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            child: Center(
              child: Icon(
                Icons.emoji_events_outlined, // Placeholder icon
                size: 50,
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text("$participantCount Participants", style: theme.textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(Icons.person_outline, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text("By $owner", style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                // Leaderboard Snippet Placeholder
                Text("Leaderboard: 1. You, 2. User A, 3. User B (mock)", style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                // Weekly Milestone Chart Concept Placeholder
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.show_chart_outlined, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Weekly Milestone Chart - Coming Soon!", style: theme.textTheme.bodyMedium)),
                    ],
                  )
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to challenge details screen with id
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("View details for $title (Coming Soon)")),
                    );
                  },
                  child: const Text("View Details"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Join/Leave challenge logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isJoined ? "Leave $title (Coming Soon)" : "Join $title (Coming Soon)")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined ? theme.colorScheme.errorContainer : theme.colorScheme.primary,
                    foregroundColor: isJoined ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimary,
                  ),
                  child: Text(isJoined ? "Leave Challenge" : "Join Challenge"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
