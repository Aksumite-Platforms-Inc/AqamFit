import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Social',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          'Social Screen',
          style: GoogleFonts.inter(
            fontSize: 20,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
