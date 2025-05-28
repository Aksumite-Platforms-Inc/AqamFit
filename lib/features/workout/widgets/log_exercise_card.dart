import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogExerciseCard extends StatefulWidget {
  final String exerciseName;

  const LogExerciseCard({
    super.key,
    required this.exerciseName,
  });

  @override
  State<LogExerciseCard> createState() => _LogExerciseCardState();
}

class _LogExerciseCardState extends State<LogExerciseCard> {
  // Reps controllers
  final TextEditingController _repsController1 = TextEditingController();
  final TextEditingController _repsController2 = TextEditingController();
  final TextEditingController _repsController3 = TextEditingController();

  // Weight controllers
  final TextEditingController _weightController1 = TextEditingController();
  final TextEditingController _weightController2 = TextEditingController();
  final TextEditingController _weightController3 = TextEditingController();

  // Set completion flags
  bool _set1Completed = false;
  bool _set2Completed = false;
  bool _set3Completed = false;

  @override
  void dispose() {
    _repsController1.dispose();
    _repsController2.dispose();
    _repsController3.dispose();
    _weightController1.dispose();
    _weightController2.dispose();
    _weightController3.dispose();
    super.dispose();
  }

  Widget _buildSetRow(
    int setNumber,
    TextEditingController repsController,
    TextEditingController weightController,
    bool isCompleted,
    VoidCallback onToggleComplete,
  ) {
    return Row(
      children: [
        Text(
          "Set $setNumber",
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Reps",
              hintStyle: GoogleFonts.inter(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2D3748), // Slightly different shade for inputs
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: "kg",
              hintStyle: GoogleFonts.inter(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2D3748), // Slightly different shade
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked_outlined,
            color: isCompleted ? Colors.greenAccent : Colors.white54,
          ),
          onPressed: onToggleComplete,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildSetRow(1, _repsController1, _weightController1, _set1Completed, () {
                  setState(() => _set1Completed = !_set1Completed);
                }),
                const SizedBox(height: 8),
                _buildSetRow(2, _repsController2, _weightController2, _set2Completed, () {
                  setState(() => _set2Completed = !_set2Completed);
                }),
                const SizedBox(height: 8),
                _buildSetRow(3, _repsController3, _weightController3, _set3Completed, () {
                  setState(() => _set3Completed = !_set3Completed);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
