import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exercise Library',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          "Searchable exercise database coming soon!",
          textAlign: TextAlign.center, // Ensure text is centered if it wraps
          style: GoogleFonts.inter(
            fontSize: 16, // Adjusted for better readability
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
