import 'package:aksumfit/services/api_service.dart'; // Moved import to top
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart'; // Import for capitalize
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  header: const Text("Preferences"),
                  children: [
                    CupertinoListTile(
                      title: const Text("Theme Mode"),
                      leading: Icon(CupertinoIcons.moon_stars_fill, color: cupertinoTheme.primaryColor),
                      additionalInfo: Text(StringHelperExtension(_currentThemeMode.toString().split('.').last).capitalize()),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () => _showThemePicker(context),
                    ),
                    CupertinoListTile(
                      title: const Text("Weight Unit"),
                      leading: Icon(CupertinoIcons.gauge, color: cupertinoTheme.primaryColor),
                      additionalInfo: Text(_currentWeightUnit.toString().split('.').last.toUpperCase()),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () => _showUnitPicker<WeightUnit>(
                        context: context,
                        title: "Select Weight Unit",
                        items: WeightUnit.values,
                        currentValue: _currentWeightUnit,
                        onSelectedItemChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _currentWeightUnit = newValue);
                            _settingsService.setWeightUnit(newValue);
                          }
                        },
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text("Distance Unit"),
                      leading: Icon(CupertinoIcons.map_pin_ellipse, color: cupertinoTheme.primaryColor),
                      additionalInfo: Text(StringHelperExtension(_currentDistanceUnit.toString().split('.').last).capitalize()),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () => _showUnitPicker<DistanceUnit>(
                        context: context,
                        title: "Select Distance Unit",
                        items: DistanceUnit.values,
                        currentValue: _currentDistanceUnit,
                        onSelectedItemChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _currentDistanceUnit = newValue);
                            _settingsService.setDistanceUnit(newValue);
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
                ),
              ],
            ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Theme Mode'),
        actions: ThemeMode.values
            .map((mode) => CupertinoActionSheetAction(
                  child: Text(StringHelperExtension(mode.toString().split('.').last).capitalize()),
                  onPressed: () {
                    if (mode != _currentThemeMode) {
                       setState(() => _currentThemeMode = mode);
                      _settingsService.setThemeMode(mode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Theme change will apply on next app restart (or with ThemeProvider)."))
                      );
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

  void _showUnitPicker<T extends Enum>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T currentValue,
    required ValueChanged<T?> onSelectedItemChanged,
  }) {
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
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: null,
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
