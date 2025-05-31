import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart'; // For WeightUnit/DistanceUnit enums
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:image_picker/image_picker.dart'; // For actual image picking

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late AuthManager _authManager;
  late User _currentUser;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController; // Usually not editable or requires verification
  String? _profileImageUrlController; // For new image URL or path

  late WeightUnit _selectedWeightUnit;
  late DistanceUnit _selectedDistanceUnit;

  bool _isLoading = false;
  // final ImagePicker _picker = ImagePicker(); // For actual image picking

  @override
  void initState() {
    super.initState();
    _authManager = Provider.of<AuthManager>(context, listen: false);
    _currentUser = _authManager.currentUser!; // Assume user is always logged in to reach this screen

    _nameController = TextEditingController(text: _currentUser.name);
    _emailController = TextEditingController(text: _currentUser.email);
    _profileImageUrlController = _currentUser.profileImageUrl;

    _selectedWeightUnit = WeightUnit.values.firstWhere(
        (e) => e.toString().split('.').last == _currentUser.preferredWeightUnit,
        orElse: () => WeightUnit.kg);
    _selectedDistanceUnit = DistanceUnit.values.firstWhere(
        (e) => e.toString().split('.').last == _currentUser.preferredDistanceUnit,
        orElse: () => DistanceUnit.km);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    // Placeholder for image picking logic
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     // In a real app, you'd upload this image and get a URL.
    //     // For mock, we might just use the path or a placeholder URL.
    //     _profileImageUrlController = image.path; // Placeholder
    //   });
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image picking placeholder: Feature not implemented yet.")),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      User updatedUser = _currentUser.copyWith(
        name: _nameController.text,
        // email: _emailController.text, // সাধারণত ইমেল পরিবর্তন করতে দেওয়া হয় না বা ভেরিফিকেশন লাগে
        profileImageUrl: _profileImageUrlController, // This would be the new URL after upload
        preferredWeightUnit: _selectedWeightUnit.toString().split('.').last,
        preferredDistanceUnit: _selectedDistanceUnit.toString().split('.').last,
      );

      // Simulate API call to update profile
      // In a real app, if profileImageUrlController is a local path, upload it first.
      final User resultUser = await ApiService().updateUserProfile(
        name: updatedUser.name,
        profileImageUrl: updatedUser.profileImageUrl, // Send new URL
        // preferences: { // If your API takes preferences map for units
        //   'preferredWeightUnit': updatedUser.preferredWeightUnit,
        //   'preferredDistanceUnit': updatedUser.preferredDistanceUnit,
        // }
      );

      // Update AuthManager with the potentially modified user object from backend
      // The ApiService().updateUserProfile mock currently doesn't update units,
      // so we merge manually for now. A real API would return the full updated user.
      _authManager.setUser(resultUser.copyWith(
          preferredWeightUnit: updatedUser.preferredWeightUnit,
          preferredDistanceUnit: updatedUser.preferredDistanceUnit
      ));

      // Also update settings in SettingsService for global consistency if these are also stored there
      await SettingsService().setWeightUnit(_selectedWeightUnit);
      await SettingsService().setDistanceUnit(_selectedDistanceUnit);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      if(mounted) Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Edit Profile"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: _isLoading ? const CupertinoActivityIndicator() : const Text("Save"),
          onPressed: _isLoading ? null : _saveProfile,
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Add some vertical padding
          children: [
            const SizedBox(height: 20), // Top spacing
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: CupertinoColors.secondarySystemFill,
                    backgroundImage: _profileImageUrlController != null && _profileImageUrlController!.startsWith('http')
                        ? CachedNetworkImageProvider(_profileImageUrlController!)
                        : null,
                    child: (_profileImageUrlController == null || !_profileImageUrlController!.startsWith('http'))
                        ? Icon(CupertinoIcons.person_fill, size: 60, color: cupertinoTheme.primaryColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container( // Create a colored circle for the button
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cupertinoTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.camera_fill, color: CupertinoColors.white, size: 20),
                      ),
                      onPressed: _pickProfileImage,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            CupertinoFormSection.insetGrouped(
              header: const Text("Personal Information"),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  prefix: const Text("Name"),
                  placeholder: "Enter your full name",
                  validator: (value) => (value == null || value.isEmpty) ? "Name cannot be empty" : null,
                ),
                CupertinoTextFormFieldRow(
                  controller: _emailController,
                  prefix: const Text("Email"),
                  placeholder: "your.email@example.com",
                  readOnly: true,
                  style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context)), // Dim text for read-only
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Preferences"),
              children: [
                CupertinoListTile(
                  title: const Text("Weight Unit"),
                  additionalInfo: Text(_selectedWeightUnit.toString().split('.').last.toUpperCase()),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () => _showUnitPicker<WeightUnit>(
                    context: context,
                    title: "Select Weight Unit",
                    items: WeightUnit.values,
                    currentValue: _selectedWeightUnit,
                    onSelectedItemChanged: (newValue) {
                      if (newValue != null) setState(() => _selectedWeightUnit = newValue);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text("Distance Unit"),
                  additionalInfo: Text(_selectedDistanceUnit.toString().split('.').last.capitalize()),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () => _showUnitPicker<DistanceUnit>(
                     context: context,
                    title: "Select Distance Unit",
                    items: DistanceUnit.values,
                    currentValue: _selectedDistanceUnit,
                    onSelectedItemChanged: (newValue) {
                      if (newValue != null) setState(() => _selectedDistanceUnit = newValue);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Consistent padding
              child: CupertinoButton.filled(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading ? const CupertinoActivityIndicator(color: CupertinoColors.white) : const Text("Save Changes"),
              ),
            ),
             const SizedBox(height: 20), // Bottom spacing
          ],
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
        height: 250, // Adjust height as needed
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
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), // Title in the middle
                    onPressed: null, // Not interactive
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

extension StringHelperExtensionEditProfile on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
