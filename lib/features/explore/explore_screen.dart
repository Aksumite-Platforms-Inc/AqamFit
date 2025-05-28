import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/explore/widgets/explore_search_bar.dart';
import 'package:aksumfit/features/explore/widgets/category_tile.dart';
import 'package:aksumfit/features/explore/widgets/challenge_tile.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Explore",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          const ExploreSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0), // Added top padding similar to original placeholder
                      child: Text(
                        "Categories",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1.2,
                      children: const [
                        CategoryTile(categoryName: "Strength", icon: Icons.fitness_center),
                        CategoryTile(categoryName: "Cardio", icon: Icons.directions_run),
                        CategoryTile(categoryName: "Yoga", icon: Icons.self_improvement),
                        CategoryTile(categoryName: "Flexibility", icon: Icons.accessibility_new),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Challenge Tiles Placeholder",
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                      child: Text(
                        "Active Challenges",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const ChallengeTile(
                      title: "30-Day Abs Challenge",
                      description: "Get ready to sculpt your core with daily targeted workouts.",
                    ),
                    const SizedBox(height: 16),
                    const ChallengeTile(
                      title: "Mindfulness Journey",
                      description: "Join our 2-week meditation and mindfulness program.",
                    ),
                    const SizedBox(height: 16),
                    const ChallengeTile(
                      title: "Run Your First 5K",
                      description: "A guided plan to get you across the finish line.",
                    ),
                  ],
                ),
                // Add more placeholders as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
