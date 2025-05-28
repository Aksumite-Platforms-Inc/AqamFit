import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakTrackerWidget extends StatelessWidget {
  const StreakTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B), // Theme color from main.dart
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔥 Streak",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "5 Days", // Placeholder
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6366F1), // Accent color
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Keep it up!", // Placeholder
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
