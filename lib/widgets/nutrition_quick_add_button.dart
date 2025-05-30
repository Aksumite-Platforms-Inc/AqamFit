import 'package:flutter/material.dart';

class NutritionQuickAddButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const NutritionQuickAddButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF475569), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // To better center content if it's in a GridView
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center, // Ensure text is centered if it wraps
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
