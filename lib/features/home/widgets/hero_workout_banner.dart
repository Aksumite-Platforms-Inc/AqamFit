import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroWorkoutBanner extends StatelessWidget {
  const HeroWorkoutBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      // Keep Card for elevation and shape from theme
      clipBehavior: Clip.antiAlias, // Ensures the gradient respects card's rounded corners
      child: Container(
        padding: const EdgeInsets.all(20.0), // Slightly increased padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Workout", // Title
              style: GoogleFonts.inter(
                fontSize: 20, // Made larger
                fontWeight: FontWeight.bold, // Made bolder
                color: colorScheme.onPrimary, // Ensure contrast
              ),
            ),
            const SizedBox(height: 16), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Allow text to wrap if needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Full Body Blast", // Workout Name
                        style: GoogleFonts.inter(
                          fontSize: 18, // Slightly larger
                          fontWeight: FontWeight.w600, // Bolder
                          color: colorScheme.onPrimary.withOpacity(0.9), // Ensure contrast
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "45 Mins", // Duration
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colorScheme.onPrimary.withOpacity(0.7), // Ensure contrast
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Spacing before button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement start workout functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary, // Button color for contrast
                    foregroundColor: colorScheme.primary, // Text color for contrast
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text("Start Workout"), // Updated button text
                ),
              ],
            ),
            // LinearProgressIndicator removed
          ],
        ),
      ),
    );
  }
}
