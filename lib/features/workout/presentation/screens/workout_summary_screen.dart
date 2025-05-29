import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Summary',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        automaticallyImplyLeading: false, // Remove back button if not desired
      ),
      body: Center(
        child: Padding( // Added padding for better text display
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Workout summary: Calories burned, total duration, new personal records, and more details will be shown here!",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16, // Adjusted for better readability
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
      ),
      // Optional: Add a button to navigate back to home or explore
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Assuming GoRouter is accessible here, or pass context if needed
            // For simplicity, direct navigation. If context isn't directly available for router,
            // this might need to be a callback or use a global navigator key.
            // For now, let's assume context.go works.
            // Note: Direct context.go might not be ideal here if this screen is pushed.
            // Consider Navigator.of(context).popUntil if it's part of a flow or context.go to a root.
            // For this placeholder, going to /main is a safe bet.
            if (context.mounted) {
                context.go('/main');
            }
          },
          child: const Text("Done"),
        ),
      ),
    );
  }
}
