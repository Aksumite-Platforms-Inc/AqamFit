import 'package:flutter/material.dart';
import 'package:aksumfit/.dart_tool/flutter_gen/gen_l10n/app_localizations.dart' as S;

import '../widgets/home_progress_item.dart';
import '../widgets/home_quick_action.dart';
import '../widgets/home_achievement_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = S.AppLocalizations.of(context);
    if (localizations != null) {
      print(localizations.helloWorld);
    } else {
      print("Localizations not found");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Morning, Alex!'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Progress Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: HomeProgressItem(
                          title: 'Workouts',
                          value: '2/3',
                          icon: Icons.fitness_center,
                        ),
                      ),
                      Expanded(
                        child: HomeProgressItem(
                          title: 'Calories',
                          value: '1,850/2,100',
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      Expanded(
                        child: HomeProgressItem(
                          title: 'Steps',
                          value: '8,245/10,000',
                          icon: Icons.directions_walk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: HomeQuickAction(
                    title: 'Start Workout',
                    icon: Icons.play_arrow,
                    color: Color(0xFF43A047),
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: HomeQuickAction(
                    title: 'Log Meal',
                    icon: Icons.camera_alt,
                    color: Color(0xFFFF7043),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Achievements
            Text(
              'Recent Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  HomeAchievementCard(
                    title: '7-Day Streak',
                    icon: Icons.local_fire_department,
                    color: Color(0xFFFF5722),
                  ),
                  HomeAchievementCard(
                    title: 'Weight Goal',
                    icon: Icons.trending_down,
                    color: Color(0xFF4CAF50),
                  ),
                  HomeAchievementCard(
                    title: '5K Steps',
                    icon: Icons.directions_walk,
                    color: Color(0xFF2196F3),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // AI Insights
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
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF1E88E5)),
                      SizedBox(width: 8),
                      Text(
                        'AI Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Great job maintaining your workout consistency! Your performance has improved by 15% this week. Consider increasing your protein intake to support muscle recovery.',
                    style: TextStyle(color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildProgressItem removed

  // _buildQuickAction removed

  // _buildAchievementCard removed
}
