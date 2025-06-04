import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MuscleHeatmapWidget extends StatelessWidget {
  const MuscleHeatmapWidget({super.key});

  // Mock data for muscle activity (0.0 = inactive, 1.0 = very active)
  // Keys can be descriptive IDs for muscle zones.
  final Map<String, double> _muscleActivity = const {
    // Front
    'chest_front': 0.8,
    'abs_front': 0.3,
    'left_bicep_front': 0.9,
    'right_bicep_front': 0.7,
    'left_quad_front': 0.4,
    'right_quad_front': 0.6,
    // Back
    'upper_back_back': 0.7,
    'lower_back_back': 0.5,
    'left_glute_back': 0.8,
    'right_glute_back': 0.4,
    'left_hamstring_back': 0.6,
    'right_hamstring_back': 0.3,
    'left_tricep_back': 0.7,
    'right_tricep_back': 0.5,
  };

  Widget _buildMuscleZone({
    required BuildContext context,
    required String zoneId,
    required String zoneName,
    required double top,
    required double left,
    required double width,
    required double height,
    BoxShape shape = BoxShape.rectangle,
  }) {
    final activity = _muscleActivity[zoneId] ?? 0.0;
    final Color zoneColor = activity > 0.65
        ? Colors.red.withOpacity(0.5) // Most active
        : activity > 0.35
            ? Colors.orange.withOpacity(0.5) // Moderately active
            : Colors.blueGrey.withOpacity(0.4); // Less active or inactive

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$zoneName: Activity Level ${(activity * 100).toStringAsFixed(0)}% (Placeholder)")),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: zoneColor,
            shape: shape,
            // For rectangle, you might want a slight border radius
            borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(4) : null,
            // border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.5), // Optional border for visibility
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Approximate scale factor if the images are too large or small for the desired display area
    // This would require knowing the original image dimensions and the target display size.
    // For simplicity, we'll assume direct positioning on a reasonably sized image.
    // Let's define a fixed size for the body outlines for now.
    const double bodyImageWidth = 150;
    const double bodyImageHeight = 300;


    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Front View
            SizedBox(
              width: bodyImageWidth,
              height: bodyImageHeight,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/muscles_front.png', // Ensure this path is correct
                    width: bodyImageWidth,
                    height: bodyImageHeight,
                    fit: BoxFit.contain,
                    // Optional: Add errorBuilder for placeholder if image fails to load
                     errorBuilder: (context, error, stackTrace) {
                       return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported, size: 50,)));
                     },
                  ),
                  // Define Front Muscle Zones (coordinates are approximate and need tuning)
                  _buildMuscleZone(context: context, zoneId: 'chest_front', zoneName: 'Chest', top: 60, left: 45, width: 60, height: 40),
                  _buildMuscleZone(context: context, zoneId: 'abs_front', zoneName: 'Abdominals', top: 105, left: 50, width: 50, height: 45),
                  _buildMuscleZone(context: context, zoneId: 'left_bicep_front', zoneName: 'Left Bicep', top: 65, left: 25, width: 20, height: 35),
                  _buildMuscleZone(context: context, zoneId: 'right_bicep_front', zoneName: 'Right Bicep', top: 65, left: 105, width: 20, height: 35),
                  _buildMuscleZone(context: context, zoneId: 'left_quad_front', zoneName: 'Left Quadriceps', top: 155, left: 30, width: 40, height: 60),
                  _buildMuscleZone(context: context, zoneId: 'right_quad_front', zoneName: 'Right Quadriceps', top: 155, left: 80, width: 40, height: 60),
                ],
              ),
            ),
            // Back View
            SizedBox(
              width: bodyImageWidth,
              height: bodyImageHeight,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/muscles_back.png', // Ensure this path is correct
                    width: bodyImageWidth,
                    height: bodyImageHeight,
                    fit: BoxFit.contain,
                     errorBuilder: (context, error, stackTrace) {
                       return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported, size: 50,)));
                     },
                  ),
                  // Define Back Muscle Zones (coordinates are approximate and need tuning)
                  _buildMuscleZone(context: context, zoneId: 'upper_back_back', zoneName: 'Upper Back', top: 55, left: 40, width: 70, height: 55),
                  _buildMuscleZone(context: context, zoneId: 'lower_back_back', zoneName: 'Lower Back', top: 110, left: 45, width: 60, height: 40),
                  _buildMuscleZone(context: context, zoneId: 'left_tricep_back', zoneName: 'Left Tricep', top: 65, left: 25, width: 20, height: 35),
                  _buildMuscleZone(context: context, zoneId: 'right_tricep_back', zoneName: 'Right Tricep', top: 65, left: 105, width: 20, height: 35),
                  _buildMuscleZone(context: context, zoneId: 'left_glute_back', zoneName: 'Left Glute', top: 140, left: 30, width: 40, height: 40, shape: BoxShape.circle),
                  _buildMuscleZone(context: context, zoneId: 'right_glute_back', zoneName: 'Right Glute', top: 140, left: 80, width: 40, height: 40, shape: BoxShape.circle),
                  _buildMuscleZone(context: context, zoneId: 'left_hamstring_back', zoneName: 'Left Hamstring', top: 185, left: 30, width: 40, height: 50),
                  _buildMuscleZone(context: context, zoneId: 'right_hamstring_back', zoneName: 'Right Hamstring', top: 185, left: 80, width: 40, height: 50),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.analytics_outlined),
          label: const Text("View Detailed Progress"),
          onPressed: () {
            context.go('/progress');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
