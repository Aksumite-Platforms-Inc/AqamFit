import 'package:flutter/material.dart';

import '../widgets/profile_stat_card.dart';
import '../widgets/profile_achievement_item.dart';
import '../widgets/profile_menu_option.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Alex Johnson';
  String userEmail = 'alex.johnson@email.com';
  int totalWorkouts = 47;
  double totalDistance = 125.6;
  int caloriesBurned = 18450;
  int currentStreak = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName[0], // Assuming userName is not empty
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Premium Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                ProfileStatCard(
                  title: 'Workouts',
                  value: totalWorkouts.toString(),
                  icon: Icons.fitness_center,
                  color: Color(0xFF43A047),
                ),
                ProfileStatCard(
                  title: 'Distance',
                  value: '${totalDistance.toInt()} km',
                  icon: Icons.directions_run,
                  color: Color(0xFF1E88E5),
                ),
                ProfileStatCard(
                  title: 'Calories',
                  value: '${caloriesBurned.toString()}',
                  icon: Icons.local_fire_department,
                  color: Color(0xFFFF7043),
                ),
                ProfileStatCard(
                  title: 'Streak',
                  value: '$currentStreak days',
                  icon: Icons.emoji_events,
                  color: Color(0xFF9C27B0),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Achievements Section
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 16),
                  ProfileAchievementItem(
                    title: 'First 5K',
                    description: 'Completed your first 5K run',
                    icon: Icons.directions_run,
                    color: Color(0xFF43A047),
                  ),
                  ProfileAchievementItem(
                    title: 'Week Warrior',
                    description: '7-day workout streak',
                    icon: Icons.local_fire_department,
                    color: Color(0xFFFF7043),
                  ),
                  ProfileAchievementItem(
                    title: 'Early Bird',
                    description: '10 morning workouts',
                    icon: Icons.wb_sunny,
                    color: Color(0xFFFFB74D),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Menu Options
            _buildMenuOption('Workout History', Icons.history, () {}),
            _buildMenuOption('Nutrition Goals', Icons.restaurant, () {}),
            _buildMenuOption('Connect Devices', Icons.watch, () {}),
            _buildMenuOption('Privacy Settings', Icons.privacy_tip, () {}),
            _buildMenuOption('Help & Support', Icons.help, () {}),
            _buildMenuOption(
              'Upgrade to Premium',
              Icons.star,
              () {},
              isHighlighted: true,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // _buildStatCard removed

  // _buildAchievementItem removed

  // _buildMenuOption removed

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Text('Settings options will be available soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
