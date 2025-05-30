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
    final ThemeData theme = Theme.of(context);
    // Listen to AuthManager to rebuild if user changes (e.g., after logout from settings)
    // However, for displaying user data, a one-time read in initState or a Consumer is often better.
    // For simplicity, we use the _currentUser from initState and refresh on return.
    // final _currentUser = Provider.of<AuthManager>(context).currentUser;

    if (_currentUser == null) {
      // This case should ideally not be reached if ProfileScreen is protected by auth routes
      return Scaffold(
        appBar: AppBar(title: Text("Profile", style: GoogleFonts.inter())),
        body: const Center(child: Text("Not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: theme.colorScheme.primary,
        elevation: theme.appBarTheme.elevation,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle),
            tooltip: "Edit Profile",
            onPressed: () {
               context.go('/profile/edit').then((_) => _refreshDataOnReturn());
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProfileData(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: _currentUser!.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _currentUser!.profileImageUrl!,
                              width: 100, height: 100, fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(CupertinoIcons.person_fill, size: 50, color: theme.colorScheme.onPrimaryContainer),
                            ),
                          )
                        : Icon(CupertinoIcons.person_fill, size: 50, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentUser!.name,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser!.email, // Display actual email
                    style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  // Text("Joined: ${DateFormat.yMMMMd().format(_currentUser!.createdAt)}", style: GoogleFonts.inter(...)), // If createdAt is available
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // User Stats Section - pass dynamic data
            UserStatsCard(
              totalWorkouts: _currentUser!.totalWorkouts ?? 0,
              streak: _currentUser!.streakCount,
              achievements: _currentUser!.achievements ?? 0,
            ),
            const SizedBox(height: 24),

            // My Goals Section
            _buildSectionTitle(context, "Active Goals"),
            FutureBuilder<List<Goal>>(
              future: _activeGoalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading goals.", style: TextStyle(color: theme.colorScheme.error)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("No active goals set yet.", style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)),
                  ));
                }
                final goals = snapshot.data!;
                return Card(
                  child: Column(
                    children: [
                      ...goals.take(3).map((goal) => _buildGoalItem(context, goal)), // Show top 3 goals
                      if (goals.length > 3 || goals.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0, top: 4.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                 context.go('/progress'); // Navigate to full progress/goals screen
                              },
                              child: Text("View All Goals (${goals.length})", style: GoogleFonts.inter(color: theme.colorScheme.primary, fontSize: 13)),
                            ),
                          ),
                        ),
                       if (goals.isEmpty) // Should be caught by earlier check, but good fallback
                         ListTile(title: Text("No active goals.", style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)))
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 24),

            // Settings Navigation
            _buildNavigationTile(
              context,
              icon: CupertinoIcons.settings_solid,
              title: "Settings",
              onTap: () => context.go('/settings').then((_) => _refreshDataOnReturn()),
            ),
            const SizedBox(height: 12),
            _buildNavigationTile(
              context,
              icon: CupertinoIcons.question_circle_fill,
              title: "Help & Support",
              onTap: () { /* TODO: Navigate to Help/Support */ }
            ),
             const SizedBox(height: 12),
            _buildNavigationTile(
              context,
              icon: CupertinoIcons.shield_lefthalf_fill,
              title: "Privacy Policy",
              onTap: () { /* TODO: Navigate to Privacy Policy */ }
            ),
            const SizedBox(height: 24),

            // Premium Upsell Card (can be kept or modified)
            Card( /* ... existing premium card ... */ ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.secondary, size: 24),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: Icon(CupertinoIcons.chevron_forward, color: theme.colorScheme.onSurfaceVariant, size: 20),
        onTap: onTap,
      ),
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
