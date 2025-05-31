// import 'package:aksumfit/models/goal.dart'; // No longer used directly in this simplified version
// import 'package:aksumfit/models/user.dart'; // No longer used directly
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:flutter/material.dart'; // Changed from Cupertino
// import 'package:google_fonts/google_fonts.dart'; // Using theme.textTheme instead
import 'package:aksumfit/features/profile/widgets/user_stats_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aksumfit/models/goal.dart'; // Re-added for _activeGoalsFuture type

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<Goal>>? _activeGoalsFuture;
  User? _currentUser; // Kept to display user info

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (mounted) { // Ensure widget is still in the tree
      setState(() {
        _currentUser = authManager.currentUser;
        if (_currentUser != null) {
          _activeGoalsFuture = ApiService().getGoals(_currentUser!.id, isActive: true);
        }
      });
    }
  }

  Future<void> _refreshDataOnReturn() async {
    // This is a simplified refresh. A more robust solution might involve
    // a global state management approach that updates User object across the app.
    final authManager = Provider.of<AuthManager>(context, listen: false);
     if (mounted) {
        setState(() {
          _currentUser = authManager.currentUser; // Re-fetch current user from AuthManager
           if (_currentUser != null) {
            _activeGoalsFuture = ApiService().getGoals(_currentUser!.id, isActive: true);
          }
        });
    }
  }

  Widget _buildGoalItemMaterial(BuildContext context, Goal goal) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(
        goal.name,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: LinearProgressIndicator(
          value: goal.progressPercentage,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: theme.colorScheme.primary,
          minHeight: 8, // Slightly thicker for Material
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      trailing: Text(
        "${(goal.progressPercentage * 100).toStringAsFixed(0)}%",
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
      onTap: () {
        // TODO: Navigate to goal details or edit
        // context.go('/progress/goals/${goal.id}'); // Example
      },
    );
  }

  Widget _buildNavigationTileMaterial(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
      onTap: onTap,
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get Material theme
    // Use a local variable for _currentUser from provider to ensure it's up-to-date for the build method.
    // This is safer if AuthManager is a ChangeNotifier and might update.
    final authManager = Provider.of<AuthManager>(context);
    _currentUser = authManager.currentUser;


    if (_currentUser == null) {
      return Scaffold( // Changed to Scaffold
        appBar: AppBar(title: const Text("Profile")), // Changed to AppBar
        body: const Center(child: Text("Not logged in.")),
      );
    }

    return Scaffold( // Changed to Scaffold
      appBar: AppBar( // Changed to AppBar
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.go('/profile/edit');
              _refreshDataOnReturn();
            },
          ),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: () async => _loadProfileData(), // Call existing load method
        child: ListView( // Changed CustomScrollView to ListView
          padding: const EdgeInsets.all(0), // No padding for ListView itself, handle in children
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
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
                              errorWidget: (context, url, error) => Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer),
                            ),
                          )
                        : Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  Text(
                    _currentUser!.name,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentUser!.email,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Padding( // Add padding around UserStatsCard
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: UserStatsCard(
                totalWorkouts: _currentUser!.totalWorkouts ?? 0,
                streak: _currentUser!.streakCount, // Assuming streakCount is already an int
                achievements: _currentUser!.achievements ?? 0,
              ),
            ),
            const SizedBox(height: 24), // Spacing before goals card
            Padding( // Add padding for the goals card
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card( // Changed CupertinoListSection to Card
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text("Active Goals", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    FutureBuilder<List<Goal>>(
                      future: _activeGoalsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("Error loading goals.", style: TextStyle(color: theme.colorScheme.error))));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const ListTile(title: Text("No active goals set yet."));
                        }
                        final goals = snapshot.data!;
                        return Column(
                          children: [
                            ...goals.take(3).map((goal) => _buildGoalItemMaterial(context, goal)),
                            if (goals.length > 3)
                              ListTile(
                                title: Text("View All Goals (${goals.length})", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () => context.go('/progress'), // Assuming /progress shows all goals
                              ),
                          ],
                        );
                      },
                    ),
                     const SizedBox(height: 8), // Padding at the bottom of the card
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing before navigation tiles
            Padding( // Add padding for the navigation list
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column( // Use Column for list of tiles instead of ListView.separated inside another ListView
                children: [
                  _buildNavigationTileMaterial(
                    context,
                    icon: Icons.settings_outlined, // Material icon
                    title: "Settings",
                    onTap: () async {
                      context.go('/settings');
                      _refreshDataOnReturn();
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildNavigationTileMaterial(
                    context,
                    icon: Icons.help_outline, // Material icon
                    title: "Help & Support",
                    onTap: () { /* TODO: Navigate to Help/Support */ }
                  ),
                   const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildNavigationTileMaterial(
                    context,
                    icon: Icons.privacy_tip_outlined, // Material icon
                    title: "Privacy Policy",
                    onTap: () { /* TODO: Navigate to Privacy Policy */ }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
