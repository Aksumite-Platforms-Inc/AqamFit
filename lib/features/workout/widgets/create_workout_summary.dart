import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateWorkoutSummary extends StatelessWidget {
  final int exerciseCount;

  const CreateWorkoutSummary({
    super.key,
    required this.exerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Exercises:",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            "$exerciseCount exercises",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
