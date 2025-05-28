import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/workout/widgets/log_exercise_card.dart';

class LogWorkoutScreen extends StatelessWidget {
  const LogWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Log Workout",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () { /* TODO: Finish workout */ },
        //     child: Text("Finish", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        //   )
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const LogExerciseCard(exerciseName: "Bench Press"),
          const LogExerciseCard(exerciseName: "Overhead Press"),
          const LogExerciseCard(exerciseName: "Squats"),
          const SizedBox(height: 16), // Add some space before the button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement finish workout functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1), // Accent color
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                minimumSize: const Size(double.infinity, 50), // Full width
              ),
              child: const Text("Finish Workout"),
            ),
          ),
        ],
      ),
    );
  }
}
