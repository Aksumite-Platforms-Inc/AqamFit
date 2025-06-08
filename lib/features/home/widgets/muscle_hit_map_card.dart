import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';

class MuscleHitMapCard extends StatefulWidget {
  const MuscleHitMapCard({super.key});

  @override
  State<MuscleHitMapCard> createState() => _MuscleHitMapCardState();
}

class _MuscleHitMapCardState extends State<MuscleHitMapCard> {
  Set<Muscle> selectedMuscles = {};
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Weekly Muscle Heatmap",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: "View Data Overview",
                  child: IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    onPressed: () {
                      // TODO: Implement stats screen navigation
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Muscle Picker
            AspectRatio(
              aspectRatio: 3 / 4,
              child: InteractiveViewer(
                minScale: 0.95,
                maxScale: 1.4,
                child: MusclePickerMap(
                  key: _mapKey,
                  width: MediaQuery.of(context).size.width,
                  map: Maps.BODY,
                  isEditing: false,
                  actAsToggle: true,
                  initialSelectedGroups: const [
                    'chest',
                    'glutes',
                    'neck',
                    'lower_back'
                  ],
                  onChanged: (muscles) {
                    setState(() {
                      selectedMuscles = muscles;
                    });
                  },
                  dotColor: isDark ? Colors.white : Colors.black,
                  selectedColor: Colors.lightBlueAccent,
                  strokeColor: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Muscle Chips Section
            Text(
              "Activated Muscles",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: selectedMuscles.map((muscle) {
                final name = muscle.toString().split('.').last.replaceAll('_', ' ');
                return Chip(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  label: Text(
                    _capitalize(name),
                    style: TextStyle(
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Bottom Action
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  // TODO: Implement progress page navigation
                },
                icon: const Icon(Icons.trending_up_rounded, size: 20),
                label: const Text("Progress"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String input) {
    return input
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
