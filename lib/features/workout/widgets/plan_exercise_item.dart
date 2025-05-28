import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanExerciseItem extends StatelessWidget {
  final String exerciseName;
  // final String? details; // Example for later: setsReps or duration

  const PlanExerciseItem({
    super.key,
    required this.exerciseName,
    // this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.fitness_center,
          color: Color(0xFF6366F1),
        ),
        title: Text(
          exerciseName,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "3 sets x 10 reps", // Placeholder details
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: () {
            // TODO: Implement more options (edit/delete)
          },
        ),
      ),
    );
  }
}
