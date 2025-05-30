import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class ActivityFeedItem extends StatelessWidget {
  final String activity;
  final String time;
  final IconData icon;

  const ActivityFeedItem({
    super.key,
    required this.activity,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest, // Use theme color
        borderRadius: BorderRadius.circular(12.0), // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05), // Use theme shadow color
            blurRadius: 5,
            offset: const Offset(0, 2), // Adjusted offset
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.1), // Use theme color (tertiary)
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: colorScheme.tertiary, // Use theme color (tertiary)
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: GoogleFonts.inter( // Use GoogleFonts
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant, // Use theme color
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2), // Add a small space
                Text(
                  time,
                  style: GoogleFonts.inter( // Use GoogleFonts
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Use theme color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
