import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/progress/widgets/radar_chart_widget_placeholder.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Progress",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Added padding for content
        child: Column( // Added a Column for structure
          children: [
            const RadarChartWidgetPlaceholder(),
            const SizedBox(height: 24),
            Text(
              "Line Chart Placeholder",
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              "Progress Summary Cards Placeholder",
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
