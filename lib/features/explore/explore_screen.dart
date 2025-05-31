import 'package:flutter/cupertino.dart';
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Explore"),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: "Search workouts, trainers, etc.",
                onChanged: (value) {
                  // TODO: Implement search logic
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CupertinoSegmentedControl<int>(
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("All")),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("Beginner")),
                  2: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("Intermediate")),
                  3: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("Advanced")),
                },
                onValueChanged: (int value) {
                  // TODO: Implement filter logic
                },
                groupValue: 0, // Dummy value
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  CupertinoListSection.insetGrouped(
                    header: const Text("Categories"),
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8.0, // Adjusted spacing
                        crossAxisSpacing: 8.0, // Adjusted spacing
                        childAspectRatio: 1.5, // Adjusted aspect ratio
                        children: [
                          AxumfitCategoryCard(title: "Strength", icon: CupertinoIcons.flame_fill, onTap: () { print("Category card tapped: Strength"); }),
                          AxumfitCategoryCard(title: "Cardio", icon: CupertinoIcons.tuningfork, onTap: () { print("Category card tapped: Cardio"); }),
                          AxumfitCategoryCard(title: "Yoga", icon: CupertinoIcons.loop_thick, onTap: () { print("Category card tapped: Yoga"); }),
                          AxumfitCategoryCard(title: "Flexibility", icon: CupertinoIcons.person_2, onTap: () { print("Category card tapped: Flexibility"); }),
                          AxumfitCategoryCard(title: "HIIT", icon: CupertinoIcons.timer_fill, onTap: () { print("Category card tapped: HIIT"); }),
                        ],
                      ),
                    ],
                  ),
                  CupertinoListSection.insetGrouped(
                    header: const Text("Active Challenges"),
                    children: const [
                      ChallengeTile(
                        title: "30-Day Abs Challenge",
                        description: "Get ready to sculpt your core with daily targeted workouts.",
                        participationStats: "1.5k active",
                      ),
                      ChallengeTile(
                        title: "Mindfulness Journey",
                        description: "Join our 2-week meditation and mindfulness program.",
                        participationStats: "950 joined",
                      ),
                      ChallengeTile(
                        title: "Run Your First 5K",
                        description: "A guided plan to get you across the finish line.",
                        participationStats: "780 runners",
                      ),
                    ],
                  ),
                  CupertinoListSection.insetGrouped(
                    header: const Text("Featured Trainers"),
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trainers.length,
                          itemBuilder: (context, index) {
                            final trainer = _trainers[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0), // Added top/bottom padding
                              child: FeaturedTrainerCard(
                                name: trainer['name']!,
                                specialization: trainer['specialization']!,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  CupertinoListSection.insetGrouped(
                    header: const Text("Exercise Library"),
                    children: [
                      CupertinoListTile(
                        title: const Text("Browse All Exercises"),
                        trailing: const Icon(CupertinoIcons.forward),
                        onTap: () {
                          context.go('/exercise-library');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
