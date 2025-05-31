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
  late int _currentSetToLog; // Represents the set number the user is about to log
  final List<Map<String, dynamic>> _loggedSetsData = []; // To store data of sets already logged in this instance

  // Controllers for input fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSetToLog = 1;
  }

  @override
  void didUpdateWidget(WeightRepLoggerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the widget is rebuilt (e.g. for a new exercise), reset its internal state.
    // This depends on how WorkoutScreen uses Keys. If the key changes, initState runs.
    // If the same widget instance is updated with new targets, this might be needed.
    if (widget.targetSets != oldWidget.targetSets || widget.targetReps != oldWidget.targetReps) {
      _resetForNewExercise();
    }
  }

  void _resetForNewExercise() {
    setState(() {
      _currentSetToLog = 1;
      _loggedSetsData.clear();
      _weightController.clear();
      _repsController.clear();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _logSet() {
    if (!mounted) return;
    if (_currentSetToLog > widget.targetSets) return; // Already completed all sets

    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    final int reps = int.tryParse(_repsController.text) ?? 0;

    // Basic validation, can be enhanced
    if (reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number of reps.")),
      );
      return;
    }
    // Weight can be 0 for bodyweight exercises, so allow weight >= 0

    widget.onSetLogged(_currentSetToLog, weight, reps);

    // Store this set's data locally for display or if needed for "edit previous set" later (not implemented)
    _loggedSetsData.add({'set': _currentSetToLog, 'weight': weight, 'reps': reps});


    if (_currentSetToLog < widget.targetSets) {
      setState(() {
        _currentSetToLog++;
        // Clear for next set, or pre-fill with previous data as a UX choice
        // _weightController.text = weight.toString(); // Keep previous weight
        _repsController.clear();
      });
    } else {
      // All target sets logged
      setState(() {
         _currentSetToLog++; // Increment beyond targetSets to signify completion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All target sets logged!")),
      );
      // The parent (WorkoutScreen) will decide to auto-advance or not based on this.
    }
  }

  bool get _allSetsCompleted => _currentSetToLog > widget.targetSets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display previously logged sets for this exercise instance
          ..._loggedSetsData.map((setData) => Text(
                "Set ${setData['set']}: ${setData['weight']} kg x ${setData['reps']} reps",
                style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant),
              )),
          if (_loggedSetsData.isNotEmpty) const SizedBox(height: 10),

          if (!_allSetsCompleted) ...[
            Text(
              "Logging Set $_currentSetToLog of ${widget.targetSets}",
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      hintText: "0.0",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Reps",
                      hintText: "0",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    style: GoogleFonts.inter(fontSize: textTheme.bodyLarge?.fontSize),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logSet,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text("Log Set $_currentSetToLog", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            Text(
              "All ${widget.targetSets} sets logged!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: textTheme.titleMedium?.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
