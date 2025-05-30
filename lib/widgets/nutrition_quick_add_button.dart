import 'package:flutter/material.dart';

class NutritionQuickAddButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const NutritionQuickAddButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFF475569), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // To better center content if it's in a GridView
          children: [
            Icon(icon, color: const Color(0xFFFF7043), size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
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
