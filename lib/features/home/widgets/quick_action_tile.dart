import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement action
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF334155), // Lighter shade for contrast
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1), // Primary color for icon
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
