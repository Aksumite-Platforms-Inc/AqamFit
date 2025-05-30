import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // For AuthManager, potentially for SettingsService if made a ChangeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  ThemeMode _currentThemeMode = ThemeMode.system;
  WeightUnit _currentWeightUnit = WeightUnit.kg;
  DistanceUnit _currentDistanceUnit = DistanceUnit.km;
  // bool _workoutRemindersEnabled = false; // Example

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _currentThemeMode = await _settingsService.getThemeMode();
    _currentWeightUnit = await _settingsService.getWeightUnit();
    _currentDistanceUnit = await _settingsService.getDistanceUnit();
    // _workoutRemindersEnabled = await _settingsService.getWorkoutReminders();
    setState(() => _isLoading = false);
    // TODO: For ThemeMode, need to notify the root MaterialApp to rebuild with the new theme.
    // This typically involves a ThemeProvider or similar state management at the app root.
    // For now, changing it here will save, but might not visually update immediately without that.
  }

  Future<void> _handleLogout() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    // In a real app, ApiService might have a logout method to call the backend
    // await ApiService().logout();
    await authManager.clearUser(); // Clear local user state
    await ApiService().clearToken(); // Clear token from secure storage

    if (mounted) {
      // Navigate to a login or initial screen. Using context.go('/') assumes '/' is your initial/login route.
      // Adjust if your initial route is different or if you have a specific pre-login route.
      context.go('/');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.inter(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionTitle(context, "Preferences"),
                ListTile(
                  title: Text("Theme Mode", style: GoogleFonts.inter()),
                  leading: Icon(CupertinoIcons.moon_stars_fill, color: colorScheme.secondary),
                  trailing: DropdownButton<ThemeMode>(
                    value: _currentThemeMode,
                    items: ThemeMode.values.map((mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.toString().split('.').last.capitalize(), style: GoogleFonts.inter()),
                    )).toList(),
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) {
                        setState(() => _currentThemeMode = newValue);
                        _settingsService.setThemeMode(newValue);
                        // IMPORTANT: This won't visually change the theme immediately
                        // without a mechanism to rebuild MaterialApp (e.g., a ThemeProvider).
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Theme change will apply on next app restart (or with ThemeProvider)."))
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text("Weight Unit", style: GoogleFonts.inter()),
                  leading: Icon(CupertinoIcons.gauge, color: colorScheme.secondary),
                  trailing: DropdownButton<WeightUnit>(
                    value: _currentWeightUnit,
                    items: WeightUnit.values.map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit.toString().split('.').last.toUpperCase(), style: GoogleFonts.inter()),
                    )).toList(),
                    onChanged: (WeightUnit? newValue) {
                      if (newValue != null) {
                        setState(() => _currentWeightUnit = newValue);
                        _settingsService.setWeightUnit(newValue);
                        // TODO: Update user object in AuthManager or ApiService if these are stored there too
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text("Distance Unit", style: GoogleFonts.inter()),
                  leading: Icon(CupertinoIcons.map_pin_ellipse, color: colorScheme.secondary),
                  trailing: DropdownButton<DistanceUnit>(
                    value: _currentDistanceUnit,
                    items: DistanceUnit.values.map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit.toString().split('.').last.capitalize(), style: GoogleFonts.inter()),
                    )).toList(),
                    onChanged: (DistanceUnit? newValue) {
                      if (newValue != null) {
                        setState(() => _currentDistanceUnit = newValue);
                        _settingsService.setDistanceUnit(newValue);
                         // TODO: Update user object
                      }
                    },
                  ),
                ),
                // Example for a SwitchListTile for boolean settings
                // SwitchListTile(
                //   title: Text("Enable Workout Reminders", style: GoogleFonts.inter()),
                //   secondary: Icon(CupertinoIcons.bell_fill, color: colorScheme.secondary),
                //   value: _workoutRemindersEnabled,
                //   onChanged: (bool value) {
                //     setState(() => _workoutRemindersEnabled = value);
                //     _settingsService.setWorkoutReminders(value);
                //   },
                // ),

                const Divider(height: 30),
                _buildSectionTitle(context, "Account"),
                 ListTile(
                  title: Text("Edit Profile", style: GoogleFonts.inter()),
                  leading: Icon(CupertinoIcons.person_crop_circle_fill, color: colorScheme.secondary),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    // TODO: context.go('/profile/edit'); - Create EditProfileScreen
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigate to Edit Profile (TODO)")));
                  },
                ),
                ListTile(
                  title: Text("Change Password", style: GoogleFonts.inter()),
                  leading: Icon(CupertinoIcons.lock_shield_fill, color: colorScheme.secondary),
                   trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    context.go('/profile/change-password');
                  },
                ),
                 const Divider(height: 30),
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(CupertinoIcons.square_arrow_left),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final confirmLogout = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (BuildContext ctx) => CupertinoAlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            CupertinoDialogAction(
                              child: const Text('Logout'),
                              isDestructiveAction: true,
                              onPressed: () => Navigator.of(ctx).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (confirmLogout == true) {
                        _handleLogout();
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

extension StringHelperExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

import 'package:aksumfit/services/api_service.dart'; // Import actual ApiService
