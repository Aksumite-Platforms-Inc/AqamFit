import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStatsCard extends StatelessWidget {
  final int totalWorkouts;
  final int streak;
  final int achievements;

  const UserStatsCard({
    super.key,
    required this.totalWorkouts,
    required this.streak,
    required this.achievements,
  });

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant, // Ensure this contrasts with card background
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, "Total Workouts", totalWorkouts.toString()),
            _buildStatItem(context, "Streak", "$streak Days"),
            _buildStatItem(context, "Achievements", achievements.toString()),
          ],
        ),
      ),
    );
  }
}
