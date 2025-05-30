import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LineChartWidgetPlaceholder extends StatelessWidget {
  const LineChartWidgetPlaceholder({super.key});

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
              "Weight Progress",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: Center(
                child: Icon(
                  CupertinoIcons.graph_square_fill,
                  size: 100,
                  color: Color(0xFF06B6D4), // Accent cyan
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Jan", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                Text("Feb", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                Text("Mar", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                Text("Apr", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
