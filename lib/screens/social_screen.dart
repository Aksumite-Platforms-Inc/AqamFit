import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';
import '../models/challenge.dart';
import '../widgets/social_stat_item.dart';
import '../widgets/challenge_card.dart';
import '../widgets/leaderboard_list_item.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int currentStreak = 7;
  int totalPoints = 2450;
  int weeklyRank = 3;

  List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry('Sarah M.', 3240, 1, 'assets/avatar1.png'),
    LeaderboardEntry('Mike R.', 2890, 2, 'assets/avatar2.png'),
    LeaderboardEntry(
      'You',
      2450,
      3,
      'assets/avatar3.png',
    ), // Assuming current user
    LeaderboardEntry('Emma K.', 2210, 4, 'assets/avatar4.png'),
    LeaderboardEntry('John D.', 1980, 5, 'assets/avatar5.png'),
  ];

  List<Challenge> challenges = [
    Challenge(
      '30-Day Fitness Streak',
      'Complete a workout every day for 30 days',
      22,
      30,
      true,
    ),
    Challenge(
      '10K Steps Daily',
      'Walk 10,000 steps every day this week',
      5,
      7,
      true,
    ),
    Challenge('Hydration Hero', 'Drink 8 glasses of water daily', 3, 7, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Fitness Journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialStatItem(
                        label: 'Streak',
                        value: '$currentStreak days',
                        icon: Icons.local_fire_department,
                      ),
                      SocialStatItem(
                        label: 'Points',
                        value: '$totalPoints',
                        icon: Icons.stars,
                      ),
                      SocialStatItem(
                        label: 'Rank',
                        value: '#$weeklyRank',
                        icon: Icons.emoji_events,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Active Challenges
            Text(
              'Active Challenges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            ...challenges.map(
              (challenge) => ChallengeCard(challenge: challenge),
            ),
            SizedBox(height: 24),

            // Leaderboard
            Text(
              'Weekly Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    leaderboard
                        .map((entry) => LeaderboardListItem(entry: entry))
                        .toList(),
              ),
            ),
            SizedBox(height: 24),

            // Recent Activity Feed
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            _buildActivityItem(
              'Sarah M. completed a 45-min HIIT workout',
              '2h ago',
              Icons.fitness_center,
            ),
            _buildActivityItem(
              'Mike R. achieved a 10-day streak!',
              '4h ago',
              Icons.local_fire_department,
            ),
            _buildActivityItem(
              'Emma K. logged a healthy breakfast',
              '6h ago',
              Icons.restaurant,
            ),
            _buildActivityItem(
              'You completed Upper Body Strength',
              '1d ago',
              Icons.fitness_center,
            ),
          ],
        ),
      ),
    );
  }

  // _buildStatItem removed

  // _buildChallengeCard removed

  // _buildLeaderboardItem removed

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Color(0xFF9C27B0), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildActivityItem(String activity, String time, IconData icon) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Color(0xFF9C27B0), size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity,
                style: TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
