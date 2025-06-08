import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MuscleHitMapCard extends StatefulWidget {
  const MuscleHitMapCard({super.key});

  @override
  State<MuscleHitMapCard> createState() => _MuscleHitMapCardState();
}

class _MuscleHitMapCardState extends State<MuscleHitMapCard> {
  bool showFront = true;

  final Map<String, String> muscleIntensity = {
    "Chest": "high",
    "Biceps": "medium",
    "Quadriceps": "high",
    "Triceps": "low",
    "Shoulders": "medium",
    "Upper Back": "low",
    "Abs": "high",
    "Lats": "medium",
    "Hamstrings": "none"
  };

  Color getColorForIntensity(String intensity) {
    switch (intensity) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.blueAccent;
      default:
        return Colors.grey.shade400;
    }
  }

  void onMuscleTap(String muscle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$muscle Stats"),
        content: Text("Weekly report for $muscle goes here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget buildHeatmapLayer(String assetPath) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),

          // Example muscles overlay — adjust coords to match real SVG zones
          Positioned(
            top: 100,
            left: 120,
            child: GestureDetector(
              onTap: () => onMuscleTap("Chest"),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: getColorForIntensity(muscleIntensity["Chest"]!),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 115,
            child: GestureDetector(
              onTap: () => onMuscleTap("Abs"),
              child: CircleAvatar(
                radius: 8,
                backgroundColor: getColorForIntensity(muscleIntensity["Abs"]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Your Weekly Muscle Activity",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Toggle View',
                  icon: Icon(showFront ? Icons.rotate_90_degrees_ccw : Icons.rotate_90_degrees_cw),
                  onPressed: () => setState(() => showFront = !showFront),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: showFront
                  ? buildHeatmapLayer('assets/images/muscles_front.svg')
                  : buildHeatmapLayer('assets/images/muscles_back.svg'),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Activated Muscles",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: muscleIntensity.entries.map((entry) {
                return Chip(
                  label: Text(entry.key),
                  backgroundColor: getColorForIntensity(entry.value).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: getColorForIntensity(entry.value),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to progress stats page
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text("View Detailed Progress"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
