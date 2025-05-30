import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter( // Ensuring GoogleFonts
            color: theme.colorScheme.onPrimary, // Using theme color
          ),
        ),
        backgroundColor: theme.colorScheme.primary, // Using theme color
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary), // Ensuring icon color
      ),
      body: Center(
        child: Text(
          'Notifications Screen',
          style: GoogleFonts.inter( // Ensuring GoogleFonts
            fontSize: 20,
            color: theme.colorScheme.onBackground, // Using theme color
          ),
        ),
      ),
    );
  }
}
