import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/features/profile/widgets/user_stats_card.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper Method for Goal Items
  Widget _buildGoalItem(BuildContext context, String title, String progress) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        progress,
        style: GoogleFonts.inter(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        CupertinoIcons.flag_circle_fill,
        color: theme.colorScheme.secondary,
      ),
      onTap: () {
        // TODO: Navigate to goal details or edit
        print("Goal item tapped: $title");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface, // Use onBackground for AppBar title
            fontWeight: FontWeight.w700, // Ensure consistency
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor, // Use theme's appBarTheme
        elevation: theme.appBarTheme.elevation, // Use theme's appBarTheme
        iconTheme: theme.appBarTheme.iconTheme, // Use theme's appBarTheme
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Alex Axum", // Placeholder name
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Member since Jan 2024", // Placeholder join date
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24), // Spacing before next section
              ],
            ),
          ),
          // User Stats Section
          const UserStatsCard(),
          const SizedBox(height: 24),

          // My Goals Section
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "My Goals",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                _buildGoalItem(context, "Workout 5 times a week", "3/5 completed"),
                _buildGoalItem(context, "Run 20km this month", "12/20 km"),
                _buildGoalItem(context, "Read 1 fitness article", "0/1 read"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Edit Goals
                      print("Edit Goals tapped");
                    },
                    child: Text(
                      "Edit Goals",
                      style: GoogleFonts.inter(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Navigation
          Card(
            child: ListTile(
              leading: Icon(CupertinoIcons.settings, color: theme.colorScheme.secondary),
              title: Text(
                "Settings",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary),
              onTap: () {
                context.go('/settings');
              },
            ),
          ),
          const SizedBox(height: 24),

          // Subscription Showcase Section
          Card(
            // Using a slightly different background to make it stand out
            // color: theme.colorScheme.primary.withOpacity(0.05), // Subtle tint
            // Or use surfaceVariant if not already the default card color
            color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest, // Default card color
            elevation: theme.cardTheme.elevation ?? 2.0,
            shape: theme.cardTheme.shape,
            clipBehavior: Clip.antiAlias, // Good practice if using BoxDecoration inside
            child: Container( // Use a container for potential gradient or more complex background
              decoration: BoxDecoration(
                 gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ?? BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AxumFit Premium",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary, // Prominent color for title
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unlock exclusive workouts, advanced AI coaching, and personalized meal plans!",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to subscription page
                        print("Learn More about Premium tapped");
                      },
                      style: ElevatedButton.styleFrom( // Use theme for base, then customize
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text("Learn More"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Other profile sections will be added here (e.g., Logout)
        ],
      ),
    );
  }
}
