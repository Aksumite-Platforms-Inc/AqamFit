import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AxumfitCategoryCard extends StatelessWidget { // Renamed class
  final String title; // Renamed categoryName to title
  final IconData icon;
  final VoidCallback onTap; // Added onTap parameter

  const AxumfitCategoryCard({
    super.key,
    required this.title, // Updated parameter name
    required this.icon,
    required this.onTap, // Made onTap required
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Use the passed onTap callback
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        clipBehavior: Clip.antiAlias, // Ensure gradient respects card's shape
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), // Match Card's shape
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Changed to mainAxisSize.min
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary, // Use theme color for icon
                ),
                const SizedBox(height: 12),
                Text(
                  title, // Use title parameter
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant, // Use theme color for text
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
