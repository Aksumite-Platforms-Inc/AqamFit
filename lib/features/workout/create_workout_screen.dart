import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/workout/widgets/plan_exercise_item.dart';
import 'package:aksumfit/features/workout/widgets/create_workout_summary.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  late TextEditingController _planNameController;
  final List<String> _exercises = ["Push Ups", "Squats", "Plank"]; // Initialize exercises

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Workout Plan",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Plan Name",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _planNameController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "e.g., Morning Power Routine",
                  hintStyle: GoogleFonts.inter(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Exercises",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _exercises.isEmpty
                  ? Container(
                      height: 100, // Give some height to the placeholder
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "No exercises added yet.",
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                      ),
                    )
                  : Column(
                      children: _exercises
                          .map((name) => PlanExerciseItem(exerciseName: name))
                          .toList(),
                    ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _exercises.add("New Exercise ${DateTime.now().millisecond}");
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1), // Accent color
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text("Add Exercise"),
              ),
              const SizedBox(height: 24), // Added for spacing before summary
              CreateWorkoutSummary(exerciseCount: _exercises.length),
              const SizedBox(height: 16), // Existing SizedBox, now between summary and save button
              ElevatedButton( // Using ElevatedButton, can be OutlinedButton too
                onPressed: () {
                  // TODO: Implement save plan functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155), // A different color
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text("Save Plan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
