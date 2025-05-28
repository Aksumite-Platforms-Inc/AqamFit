import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

import '../widgets/profile_stat_card.dart';
import '../widgets/profile_achievement_item.dart';
import '../widgets/profile_menu_option.dart';
import '../services/api_service.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserRepository _userRepository;
  bool _isLoading = true;

  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String? profileImageUrl;
  int totalWorkouts = 0; // Default value
  double totalDistance = 0.0; // Default value
  int caloriesBurned = 0; // Default value
  int currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository(apiService: ApiService());
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    final user = await _userRepository.getMyProfile();
    if (user != null && mounted) {
      setState(() {
        userName = user.name;
        userEmail = user.email;
        profileImageUrl = user.profileImageUrl;
        currentStreak = user.streakCount;
        // Mock data for other fields for now, as they are not in the User model from getMyProfile
        totalWorkouts = 47; // Placeholder
        totalDistance = 125.6; // Placeholder
        caloriesBurned = 18450; // Placeholder
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        userName = 'Failed to load';
        userEmail = 'Failed to load';
        _isLoading = false;
      });
    }
  }

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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                          backgroundImage: profileImageUrl != null &&
                                  profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child: (profileImageUrl == null ||
                                      profileImageUrl!.isEmpty) &&
                                  userName.isNotEmpty
                              ? Text(
                                  userName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E88E5),
                                  ),
                                )
                              : null,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _buildMenuOption(
                      'Privacy Settings', Icons.privacy_tip, () {}),
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

  Widget _buildMenuOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isHighlighted
                ? Color(0xFFFFD700).withOpacity(0.1)
                : Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? Color(0xFFFFD700) : Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? Color(0xFFFFD700) : Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }

  // _buildStatCard removed

  // _buildAchievementItem removed

  // _buildMenuOption removed

  void _showSettingsDialog() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Add StatefulBuilder
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Settings'), // Example of using localized string
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<Locale>(
                    title: const Text('English'),
                    value: const Locale('en'),
                    groupValue: localeProvider.locale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        localeProvider.setLocale(value);
                        setState(() {}); // Update dialog state
                      }
                    },
                  ),
                  RadioListTile<Locale>(
                    title: const Text('Amharic'),
                    value: const Locale('am'),
                    groupValue: localeProvider.locale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        localeProvider.setLocale(value);
                        setState(() {}); // Update dialog state
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
