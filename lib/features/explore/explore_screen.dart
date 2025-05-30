import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/explore/widgets/explore_search_bar.dart';
import 'package:aksumfit/shared/widgets/axumfit_category_card.dart'; // Updated import
import 'package:aksumfit/features/explore/widgets/challenge_tile.dart';
import 'package:aksumfit/features/explore/widgets/featured_trainer_card.dart';
import 'package:go_router/go_router.dart'; // Ensure GoRouter is imported

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // Placeholder data for trainers
  final List<Map<String, String>> _trainers = const [
    {"name": "Alex Fitness", "specialization": "Strength & HIIT"},
    {"name": "Jules Yoga", "specialization": "Yoga & Wellness"},
    {"name": "Sam Cardio", "specialization": "Cardio & Endurance"},
    {"name": "Maria P.", "specialization": "Pilates & Core"}, // Added one more for scrolling
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Use theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Explore",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface, // Use theme color
          ),
        ),
      ),
      body: Column(
        children: [
          const ExploreSearchBar(),
          // Difficulty Filters Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: true, // Dummy value
                  onSelected: (bool value) {}, // Dummy callback
                  // Styling will be picked from ChipThemeData in main.dart
                ),
                FilterChip(
                  label: const Text("Beginner"),
                  selected: false, // Dummy value
                  onSelected: (bool value) {}, // Dummy callback
                ),
                FilterChip(
                  label: const Text("Intermediate"),
                  selected: false, // Dummy value
                  onSelected: (bool value) {}, // Dummy callback
                ),
                FilterChip(
                  label: const Text("Advanced"),
                  selected: false, // Dummy value
                  onSelected: (bool value) {}, // Dummy callback
                ),
              ],
            ),
          ),
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
                          color: theme.colorScheme.onSurface, // Use theme color
                        ),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1.2, // Adjust as needed for 5 items or make dynamic
                      children: [
                        AxumfitCategoryCard(title: "Strength", icon: CupertinoIcons.flame_fill, onTap: () { print("Category card tapped: Strength"); }),
                        AxumfitCategoryCard(title: "Cardio", icon: CupertinoIcons.tuningfork, onTap: () { print("Category card tapped: Cardio"); }),
                        AxumfitCategoryCard(title: "Yoga", icon: CupertinoIcons.loop_thick, onTap: () { print("Category card tapped: Yoga"); }),
                        AxumfitCategoryCard(title: "Flexibility", icon: CupertinoIcons.stretch_out_figure, onTap: () { print("Category card tapped: Flexibility"); }),
                        AxumfitCategoryCard(title: "HIIT", icon: CupertinoIcons.timer_fill, onTap: () { print("Category card tapped: HIIT"); }),
                      ],
                    ),
                  ],
                ),
                // Removed Padding with "Challenge Tiles Placeholder"
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
                          color: theme.colorScheme.onSurface, // Use theme color
                        ),
                      ),
                    ),
                    const ChallengeTile(
                      title: "30-Day Abs Challenge",
                      description: "Get ready to sculpt your core with daily targeted workouts.",
                      participationStats: "1.5k active", // Added stats
                    ),
                    const SizedBox(height: 16),
                    const ChallengeTile(
                      title: "Mindfulness Journey",
                      description: "Join our 2-week meditation and mindfulness program.",
                      participationStats: "950 joined", // Added stats
                    ),
                    const SizedBox(height: 16),
                    const ChallengeTile(
                      title: "Run Your First 5K",
                      description: "A guided plan to get you across the finish line.",
                      participationStats: "780 runners", // Added stats
                    ),
                  ],
                ),
                // Featured Trainers Section
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                  child: Text(
                    "Featured Trainers",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200, // Adjusted height to fit card and potential padding
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _trainers.length, // Use length of placeholder data
                    itemBuilder: (context, index) {
                      final trainer = _trainers[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0), // Added right padding
                        child: FeaturedTrainerCard(
                          name: trainer['name']!,
                          specialization: trainer['specialization']!,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24), // Bottom padding for the trainers section

                // Exercise Library Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0), // Spacing for the title
                  child: Text(
                    "Exercise Library",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Card(
                  // Card styling will be inherited from theme
                  clipBehavior: Clip.antiAlias, // Recommended for consistency
                  shape: RoundedRectangleBorder( // Ensure card has rounded corners
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(
                      "Browse All Exercises",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    onTap: () {
                      context.go('/exercise-library');
                    },
                  ),
                ),
                const SizedBox(height: 24), // Bottom padding for the page
              ],
            ),
          ),
        ],
      ),
    );
  }
}
