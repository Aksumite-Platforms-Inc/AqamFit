import 'package:aksumfit/features/challenges/presentation/widgets/challenge_card.dart';
import 'package:flutter/material.dart';

// Mock data for challenges - replace with actual data model and fetching later
class MockChallenge {
  final String id;
  final String title;
  final String description;
  final String owner;
  final int participantCount;
  final bool isJoined;

  MockChallenge({
    required this.id,
    required this.title,
    required this.description,
    this.owner = "AksumFit Team",
    this.participantCount = 0,
    this.isJoined = false,
  });
}

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  final List<MockChallenge> _mockChallenges = const [
    MockChallenge(
      id: "1",
      title: "Summer Shred Challenge",
      description: "Get ready for summer with this 8-week intensive shredding challenge. Focus on HIIT and clean eating.",
      participantCount: 125,
      isJoined: true,
    ),
    MockChallenge(
      id: "2",
      title: "30-Day Yoga Journey",
      description: "Discover the benefits of daily yoga. Suitable for all levels. Improve flexibility and mindfulness.",
      owner: "YogaWithAdriene",
      participantCount: 340,
    ),
    MockChallenge(
      id: "3",
      title: "Run 100km in May",
      description: "Challenge yourself to run a total of 100 kilometers throughout the month of May. Track your runs and compete!",
      participantCount: 88,
    ),
     MockChallenge(
      id: "4",
      title: "Strength Builders League",
      description: "Focus on progressive overload and building raw strength. Compete on total weight lifted.",
      owner: "StrongLifts",
      participantCount: 55,
      isJoined: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
        // Potentially add filter/search actions here in the future
        // actions: [
        //   IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        //   IconButton(icon: Icon(Icons.search), onPressed: () {}),
        // ],
      ),
      body: Column(
        children: [
          // Placeholder for Filter/Search UI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Filter & Search (Conceptual)", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search challenges...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        readOnly: true, // Placeholder
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: const [
                    Chip(label: Text("Strength")),
                    Chip(label: Text("Cardio")),
                    Chip(label: Text("Endurance")),
                    Chip(label: Text("Flexibility")),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _mockChallenges.length,
              itemBuilder: (context, index) {
                final challenge = _mockChallenges[index];
                return ChallengeCard(
                  id: challenge.id,
                  title: challenge.title,
                  description: challenge.description,
                  owner: challenge.owner,
                  participantCount: challenge.participantCount,
                  isJoined: challenge.isJoined,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
