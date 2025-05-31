import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/profile/widgets/user_stats_card.dart'; // Will update this
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For profile picture

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<Goal>>? _activeGoalsFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _currentUser = authManager.currentUser;
    if (_currentUser != null) {
      setState(() {
        _activeGoalsFuture = ApiService().getGoals(_currentUser!.id, isActive: true);
        // Potentially load other dynamic stats for UserStatsCard here
      });
    }
  }

  // Refreshes data if navigated back from edit profile or settings
  Future<void> _refreshDataOnReturn() async {
    // This forces AuthManager to be re-read if user details might have changed
    // A more robust way is if AuthManager was a ChangeNotifier and ProfileScreen listened to it.
    // For now, simply re-assigning from provider should fetch the latest if it was updated by EditProfileScreen.
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (_currentUser?.id != authManager.currentUser?.id ||
        _currentUser?.name != authManager.currentUser?.name ||
        _currentUser?.email != authManager.currentUser?.email ||
        _currentUser?.profileImageUrl != authManager.currentUser?.profileImageUrl
        ) {
      _loadProfileData(); // Reload all profile data if user changed or critical fields changed
    } else {
      // Just refresh goals if other parts of user are same
       if (_currentUser != null) {
        setState(() {
          _activeGoalsFuture = ApiService().getGoals(_currentUser!.id, isActive: true);
        });
      }
    }
  }


  Widget _buildGoalItem(BuildContext context, Goal goal) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(
        goal.name,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: LinearProgressIndicator(
        value: goal.progressPercentage,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        color: theme.colorScheme.primary,
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
      ),
      trailing: Text(
        "${(goal.progressPercentage * 100).toStringAsFixed(0)}%",
         style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 14),
      ),
      onTap: () {
        // TODO: Navigate to goal details or edit
        // context.go('/progress/goals/${goal.id}'); // Example
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    if (_currentUser == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text("Profile")),
        child: const Center(child: Text("Not logged in.")),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("My Profile"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.pencil_ellipsis_rectangle),
          onPressed: () async {
            context.go('/profile/edit');
            _refreshDataOnReturn();
          },
        ),
      ),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: () async => _loadProfileData()),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: cupertinoTheme.primaryColor.withOpacity(0.1),
                        child: _currentUser!.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _currentUser!.profileImageUrl!,
                                  width: 100, height: 100, fit: BoxFit.cover,
                                  placeholder: (context, url) => const CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) => Icon(CupertinoIcons.person_fill, size: 50, color: cupertinoTheme.primaryColor),
                                ),
                              )
                            : Icon(CupertinoIcons.person_fill, size: 50, color: cupertinoTheme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentUser!.name,
                        style: cupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(color: CupertinoColors.label),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentUser!.email,
                        style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                UserStatsCard(
                  totalWorkouts: _currentUser!.totalWorkouts ?? 0,
                  streak: _currentUser!.streakCount,
                  achievements: _currentUser!.achievements ?? 0,
                ),
                CupertinoListSection.insetGrouped(
                  header: const Text("Active Goals"),
                  children: [
                    FutureBuilder<List<Goal>>(
                      future: _activeGoalsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CupertinoActivityIndicator()));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading goals.", style: TextStyle(color: CupertinoColors.destructiveRed)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const CupertinoListTile(title: Text("No active goals set yet."));
                        }
                        final goals = snapshot.data!;
                        return Column(
                          children: [
                            ...goals.take(3).map((goal) => _buildGoalItemCupertino(context, goal, cupertinoTheme)),
                            if (goals.length > 3)
                              CupertinoListTile(
                                title: Text("View All Goals (${goals.length})", style: TextStyle(color: cupertinoTheme.primaryColor)),
                                trailing: const Icon(CupertinoIcons.forward),
                                onTap: () => context.go('/progress'),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    _buildNavigationTileCupertino(
                      context,
                      cupertinoTheme: cupertinoTheme,
                      icon: CupertinoIcons.settings_solid,
                      title: "Settings",
                      onTap: () async {
                        context.go('/settings');
                        _refreshDataOnReturn();
                      },
                    ),
                    _buildNavigationTileCupertino(
                      context,
                      cupertinoTheme: cupertinoTheme,
                      icon: CupertinoIcons.question_circle_fill,
                      title: "Help & Support",
                      onTap: () { /* TODO: Navigate to Help/Support */ }
                    ),
                    _buildNavigationTileCupertino(
                      context,
                      cupertinoTheme: cupertinoTheme,
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      title: "Privacy Policy",
                      onTap: () { /* TODO: Navigate to Privacy Policy */ }
                    ),
                  ],
                ),
                // Premium Upsell Card (can be kept or modified)
                // Card( /* ... existing premium card ... */ ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItemCupertino(BuildContext context, Goal goal, CupertinoThemeData theme) {
    return CupertinoListTile(
      title: Text(
        goal.name,
        style: theme.textTheme.textStyle.copyWith(fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: LinearProgressIndicator( // Using LinearProgressIndicator as Cupertino doesn't have a direct equivalent styled this way
          value: goal.progressPercentage,
          backgroundColor: CupertinoColors.secondarySystemFill,
          color: theme.primaryColor,
          minHeight: 6,
          // borderRadius: BorderRadius.circular(3), // Not available in LinearProgressIndicator
        ),
      ),
      trailing: Text(
        "${(goal.progressPercentage * 100).toStringAsFixed(0)}%",
         style: theme.textTheme.navActionTextStyle.copyWith(color: theme.primaryColor, fontSize: 14),
      ),
      onTap: () {
        // context.go('/progress/goals/${goal.id}'); // Example
      },
    );
  }

  Widget _buildNavigationTileCupertino(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, required CupertinoThemeData cupertinoTheme}) {
    return CupertinoListTile(
      leading: Icon(icon, color: cupertinoTheme.primaryColor),
      title: Text(title, style: cupertinoTheme.textTheme.textStyle),
      trailing: const Icon(CupertinoIcons.forward, color: CupertinoColors.inactiveGray),
      onTap: onTap,
    );
  }
}

// Keep existing premium card structure or simplify if needed
// For brevity, I'll assume the existing premium card structure is fine.
// The Card structure was:
// Card(
//   color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
//   elevation: theme.cardTheme.elevation ?? 2.0,
//   shape: theme.cardTheme.shape,
//   clipBehavior: Clip.antiAlias,
//   child: Container(
//     decoration: BoxDecoration( /* gradient */ ),
//     child: Padding( /* content */ ),
//   )
// )
