import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengeTile extends StatelessWidget {
  final String title;
  final String description;
  final String? participationStats; // Added optional parameter

  const ChallengeTile({
    super.key,
    required this.title,
    required this.description,
    this.participationStats, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme
    final ColorScheme colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // TODO: Implement challenge tap functionality
      },
      child: Card(
        // Removed explicit color, will use theme's cardColor or surfaceVariant
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          // Removed fixed height: 120
          decoration: BoxDecoration(
            // Consider using a gradient or subtle pattern if desired
            color: colorScheme.surfaceContainerHighest, // Using theme color
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.end, // Adjusted to allow for dynamic height
              mainAxisSize: MainAxisSize.min, // Allow column to determine height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant, // Use theme color
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Use theme color
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8), // Added SizedBox
                if (participationStats != null && participationStats!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.group_solid,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        participationStats!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
