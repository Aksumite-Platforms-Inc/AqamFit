import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Center(
        child: Text(
          'Nutrition Screen',
          style: GoogleFonts.inter(
            fontSize: 20,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
