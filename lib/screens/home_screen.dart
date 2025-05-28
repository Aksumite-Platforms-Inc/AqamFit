import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../widgets/home_progress_item.dart';
import '../widgets/home_quick_action.dart';
import '../widgets/home_achievement_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Ethiopian greeting based on time
  String get ethiopianGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'እንደምን አደሩ'; // Good morning
    if (hour < 18) return 'እንደምን ዋሉ'; // Good afternoon
    return 'እንደምን አመሹ'; // Good evening
  }

  String get englishGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E8B57), // Ethiopian green
              Color(0xFFFFD700), // Ethiopian gold
              Color(0xFFDC143C), // Ethiopian red
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with Ethiopian flag colors
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ethiopianGreeting,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$englishGreeting, Alex!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        onPressed: () => _showNotifications(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Enhanced Daily Progress Card
                          _buildModernProgressCard(),
                          SizedBox(height: 24),

                          // Quick Actions with Ethiopian pattern
                          _buildQuickActionsSection(),
                          SizedBox(height: 24),

                          // Achievements with cultural touch
                          _buildAchievementsSection(),
                          SizedBox(height: 24),

                          // Enhanced AI Insights
                          _buildEnhancedAIInsights(),
                          SizedBox(height: 24),

                          // Weekly Challenge (New)
                          _buildWeeklyChallenge(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernProgressCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.today, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedProgressItem(
                    title: 'Workouts',
                    value: '2/3',
                    icon: Icons.fitness_center,
                    progress: 0.67,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _buildEnhancedProgressItem(
                    title: 'Calories',
                    value: '1,850',
                    subtitle: '/2,100',
                    icon: Icons.local_fire_department,
                    progress: 0.88,
                    color: Color(0xFFFF5722),
                  ),
                ),
                Expanded(
                  child: _buildEnhancedProgressItem(
                    title: 'Steps',
                    value: '8,245',
                    subtitle: '/10K',
                    icon: Icons.directions_walk,
                    progress: 0.82,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProgressItem({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required double progress,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Icon(icon, color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              children: subtitle != null
                  ? [
                      TextSpan(
                        text: subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8B57), Color(0xFFFFD700)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModernQuickAction(
                title: 'Start Workout',
                subtitle: 'Begin your session',
                icon: Icons.play_circle_filled,
                gradient: [Color(0xFF43A047), Color(0xFF66BB6A)],
                onTap: () => _startWorkout(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildModernQuickAction(
                title: 'Log Meal',
                subtitle: 'Scan & track food',
                icon: Icons.camera_alt_rounded,
                gradient: [Color(0xFFFF7043), Color(0xFFFFAB40)],
                onTap: () => _logMeal(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernQuickAction(
                title: 'Water Intake',
                subtitle: 'Track hydration',
                icon: Icons.water_drop,
                gradient: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                onTap: () => _trackWater(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildModernQuickAction(
                title: 'Meditation',
                subtitle: 'Find inner peace',
                icon: Icons.self_improvement,
                gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                onTap: () => _startMeditation(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFDC143C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Recent Achievements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _viewAllAchievements(),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildModernAchievementCard(
                title: '7-Day Streak',
                description: 'ተከታታይ 7 ቀናት',
                icon: Icons.local_fire_department,
                color: Color(0xFFFF5722),
                isNew: true,
              ),
              _buildModernAchievementCard(
                title: 'Weight Goal',
                description: 'Target achieved!',
                icon: Icons.trending_down,
                color: Color(0xFF4CAF50),
              ),
              _buildModernAchievementCard(
                title: '10K Steps',
                description: 'Walking champion',
                icon: Icons.directions_walk,
                color: Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernAchievementCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    bool isNew = false,
  }) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isNew)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFFF5722),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAIInsights() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Personalized for you',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.trending_up, color: Color(0xFF4CAF50), size: 20),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF4CAF50).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Great job maintaining your workout consistency! Your performance has improved by 15% this week. Consider increasing your protein intake to support muscle recovery. በተለይ የኢትዮጵያ ባህላዊ ምግቦችን በመመገብ ጤናን ማሻሻል ይቻላል።',
              style: TextStyle(
                color: Color(0xFF2D3748),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChallenge() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Weekly Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Ethiopian Coffee Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Replace sugary drinks with traditional Ethiopian coffee',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '4/7 days',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Color(0xFF43A047)),
              title: Text('Time for your workout!'),
              subtitle: Text('2 minutes ago'),
            ),
            ListTile(
              leading:
                  Icon(Icons.local_fire_department, color: Color(0xFFFF5722)),
              title: Text('Streak milestone reached'),
              subtitle: Text('1 hour ago'),
            ),
          ],
        ),
      ),
    );
  }

  void _startWorkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout session...'),
        backgroundColor: Color(0xFF43A047),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _logMeal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening meal logger...'),
        backgroundColor: Color(0xFFFF7043),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _trackWater() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Water intake tracked!'),
        backgroundColor: Color(0xFF42A5F5),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startMeditation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting meditation session...'),
        backgroundColor: Color(0xFF9C27B0),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewAllAchievements() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing all achievements...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
