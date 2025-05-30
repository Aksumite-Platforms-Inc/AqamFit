import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightRepLoggerWidget extends StatefulWidget {
  final int targetSets;
  final String targetReps;
  final Function(int set, double weight, int reps) onSetLogged;

  const WeightRepLoggerWidget({
    super.key,
    required this.targetSets,
    required this.targetReps,
    required this.onSetLogged,
  });

  @override
  State<WeightRepLoggerWidget> createState() => _WeightRepLoggerWidgetState();
}

class _WeightRepLoggerWidgetState extends State<WeightRepLoggerWidget> {
  int _currentSet = 1;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _logSet() {
    if (!mounted) return;

    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    final int reps = int.tryParse(_repsController.text) ?? 0;

    if (weight <= 0 || reps <= 0) {
      // Optionally show a snackbar or alert for invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid weight and reps.")),
      );
      return;
    }

    widget.onSetLogged(_currentSet, weight, reps);

    if (_currentSet < widget.targetSets) {
      setState(() {
        _currentSet++;
        // Optionally clear controllers or pre-fill with previous values
        _weightController.clear(); // Or keep previous weight?
        _repsController.clear();
      });
    } else {
      // All sets logged
      setState(() {
        _currentSet++; // To disable button and show completion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All sets logged!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Padding( // Added Padding for overall widget spacing
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column take minimum space
        children: [
          Text(
            "Set $_currentSet / ${widget.targetSets}",
            style: GoogleFonts.inter(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            "Target Reps: ${widget.targetReps}",
            style: GoogleFonts.inter(
              fontSize: textTheme.bodyMedium?.fontSize,
              color: textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16), // Increased spacing
          Row(
            children: [
              Text(
                "Weight (kg): ",
                style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize, color: textTheme.bodyLarge?.color),
              ),
              const SizedBox(width: 8),
              Expanded( // Allow TextField to take remaining space
                child: SizedBox(
                  // width: 120, // Or use Expanded
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: "0.0",
                      isDense: true, // Makes the field smaller
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Adjust padding
                    ),
                    style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Adjusted spacing
          Row(
            children: [
              Text(
                "Reps: ",
                style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize, color: textTheme.bodyLarge?.color),
              ),
              const SizedBox(width: 8),
              Expanded( // Allow TextField to take remaining space
                child: SizedBox(
                  // width: 120, // Or use Expanded
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "0",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Increased spacing
          Align( // Align button to center or stretch
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: _currentSet > widget.targetSets ? null : _logSet,
              child: Text(_currentSet > widget.targetSets ? "Completed" : "Log Set $_currentSet"),
            ),
          ),
        ],
      ),
    );
  }
}
