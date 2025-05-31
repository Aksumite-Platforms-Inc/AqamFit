import 'package:aksumfit/services/api_service.dart'; // Moved import to top
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart'; // Import for capitalize
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final SettingsService _settingsService = SettingsService(); // Replaced by Provider
  // ThemeMode _currentThemeMode = ThemeMode.system; // Replaced by Provider
  // WeightUnit _currentWeightUnit = WeightUnit.kg; // Replaced by Provider
  // DistanceUnit _currentDistanceUnit = DistanceUnit.km; // Replaced by Provider
  // bool _workoutRemindersEnabled = false; // Example

  // bool _isLoading = true; // isLoading can be removed if UI updates reactively

  @override
  void initState() {
    super.initState();
    // Settings are now loaded globally, and Consumer will provide them.
    // _loadSettings(); // No longer needed here if using Consumer for UI updates
  }

  // Future<void> _loadSettings() async {
  //   // setState(() => _isLoading = true); // Not needed if Consumer updates UI
  //   // Use Provider to get initial values if needed, but Consumer handles updates.
  //   // final settings = Provider.of<SettingsService>(context, listen: false);
  //   // _currentThemeMode = settings.themeMode;
  //   // _currentWeightUnit = settings.weightUnit;
  //   // _currentDistanceUnit = settings.distanceUnit;
  //   // setState(() => _isLoading = false);
  // }

  Future<void> _handleLogout() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    // In a real app, ApiService might have a logout method to call the backend
    // await ApiService().logout();
    authManager.clearUser(); // Clear local user state
    await ApiService().clearToken(); // Clear token from secure storage

    if (mounted) {
      // Navigate to a login or initial screen. Using context.go('/') assumes '/' is your initial/login route.
      // Adjust if your initial route is different or if you have a specific pre-login route.
      context.go('/');
    }
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    // Use Consumer to listen to SettingsService changes
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        // Get current values from the settingsService
        final currentThemeMode = settingsService.themeMode;
        final currentWeightUnit = settingsService.weightUnit;
        final currentDistanceUnit = settingsService.distanceUnit;

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Settings'),
          ),
          // child: _isLoading // isLoading can be removed
          //     ? const Center(child: CupertinoActivityIndicator())
          //     : ListView(
          child: ListView( // Removed _isLoading check, UI updates reactively
                  children: [
                    CupertinoListSection.insetGrouped(
                      header: const Text("Preferences"),
                      children: [
                        CupertinoListTile(
                          title: const Text("Theme Mode"),
                          leading: Icon(CupertinoIcons.moon_stars_fill, color: cupertinoTheme.primaryColor),
                          additionalInfo: Text(currentThemeMode.toString().split('.').last.capitalize()),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () => _showThemePicker(context, settingsService, currentThemeMode),
                        ),
                        CupertinoListTile(
                          title: const Text("Weight Unit"),
                          leading: Icon(CupertinoIcons.gauge, color: cupertinoTheme.primaryColor),
                          additionalInfo: Text(currentWeightUnit.toString().split('.').last.toUpperCase()),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () => _showUnitPicker<WeightUnit>(
                            context,
                            "Select Weight Unit",
                            WeightUnit.values,
                            currentWeightUnit,
                            (newValue) {
                              if (newValue != null) {
                                // setState(() => _currentWeightUnit = newValue); // No longer needed
                                settingsService.setWeightUnit(newValue);
                              }
                            },
                          ),
                        ),
                        CupertinoListTile(
                          title: const Text("Distance Unit"),
                          leading: Icon(CupertinoIcons.map_pin_ellipse, color: cupertinoTheme.primaryColor),
                          additionalInfo: Text(currentDistanceUnit.toString().split('.').last.capitalize()),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () => _showUnitPicker<DistanceUnit>(
                            context,
                            "Select Distance Unit",
                            DistanceUnit.values,
                            currentDistanceUnit,
                            (newValue) {
                              if (newValue != null) {
                                // setState(() => _currentDistanceUnit = newValue); // No longer needed
                                settingsService.setDistanceUnit(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    CupertinoListSection.insetGrouped(
                      header: const Text("Account"),
                      children: [
                        CupertinoListTile(
                          title: const Text("Edit Profile"),
                          leading: Icon(CupertinoIcons.person_crop_circle_fill, color: cupertinoTheme.primaryColor),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () {
                             context.go('/profile/edit');
                          },
                        ),
                        CupertinoListTile(
                          title: const Text("Change Password"),
                          leading: Icon(CupertinoIcons.lock_shield_fill, color: cupertinoTheme.primaryColor),
                          trailing: const Icon(CupertinoIcons.forward),
                          onTap: () {
                            context.go('/profile/change-password');
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: CupertinoColors.destructiveRed,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.square_arrow_left, color: CupertinoColors.white),
                              SizedBox(width: 8),
                              Text("Logout", style: TextStyle(color: CupertinoColors.white)),
                            ],
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
                                    isDestructiveAction: true,
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Logout'),
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
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, SettingsService settingsService, ThemeMode currentThemeMode) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Theme Mode'),
        actions: ThemeMode.values
            .map((mode) => CupertinoActionSheetAction(
                  child: Text(mode.toString().split('.').last.capitalize()),
                  onPressed: () {
                    if (mode != currentThemeMode) { // Use passed currentThemeMode
                       // setState(() => _currentThemeMode = mode); // No longer needed
                      settingsService.setThemeMode(mode); // Use settingsService from parameter
                      // ScaffoldMessenger.of(context).showSnackBar( // Removed SnackBar
                      //   const SnackBar(content: Text("Theme change will apply on next app restart (or with ThemeProvider)."))
                      // );
                    }
                    Navigator.pop(context);
                  },
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showUnitPicker<T extends Enum>(
    BuildContext context,
    String title,
    List<T> items,
    T currentValue,
    ValueChanged<T?> onSelectedItemChanged,
  ) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: items.indexOf(currentValue));

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    onPressed: null,
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      onSelectedItemChanged(items[scrollController.selectedItem]);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: scrollController,
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  // No immediate state update here, wait for "Done"
                },
                children: items.map((T value) {
                  return Center(child: Text(value.toString().split('.').last.capitalize()));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removed local StringHelperExtension as it's defined globally
// extension StringHelperExtension on String {
//   String capitalize() {
//     if (isEmpty) return this;
//     return this[0].toUpperCase() + substring(1);
//   }
// }
// Removed import from here as it's moved to the top
