import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/weekly_snapshot_card.dart';
import '../widgets/suggested_challenges_card.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/suggested_users_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_fire_department_outlined),
            onPressed: () => context.push('/streak'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Snapshot Card
            const WeeklySnapshotCard(),
            const SizedBox(height: 20),

            // Suggested Challenges
            const Text(
              "Suggested Challenges",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const SuggestedChallengesCard(),
            const SizedBox(height: 25),

            // Feed
            const Text(
              "Community Feed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const FeedPostCard(),
            const SizedBox(height: 25),

            // Suggested Users
            const Text(
              "Suggested Users",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const SuggestedUsersCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
