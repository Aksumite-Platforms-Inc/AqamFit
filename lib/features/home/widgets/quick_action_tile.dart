import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:google_fonts/google_fonts.dart';

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String onTapRoute; // Added onTapRoute parameter

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTapRoute, // Made onTapRoute required
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme

    return GestureDetector(
      onTap: () {
        context.go(onTapRoute); // Use context.go for navigation
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest, // Use theme color
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [ // Optional: add a subtle shadow from theme
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary, // Use theme color
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center, // Ensure text is centered if it wraps
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.8), // Use theme color
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
