import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RadarChartWidgetPlaceholder extends StatelessWidget {
  const RadarChartWidgetPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skills Overview",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Icon(
                  Icons.hexagon_outlined,
                  size: 100,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Strength, Cardio, Flexibility, Agility, Endurance",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
