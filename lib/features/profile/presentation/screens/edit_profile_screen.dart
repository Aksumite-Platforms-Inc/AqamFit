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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)) : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
            tooltip: "Save Changes",
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: _profileImageUrlController != null && _profileImageUrlController!.startsWith('http')
                        ? CachedNetworkImageProvider(_profileImageUrlController!)
                        : null, // TODO: Handle local file path for preview if _picker is used
                    child: (_profileImageUrlController == null || !_profileImageUrlController!.startsWith('http'))
                        ? Icon(CupertinoIcons.person_fill, size: 60, color: theme.colorScheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                      icon: Icon(CupertinoIcons.camera_fill, color: theme.colorScheme.onPrimary, size: 20),
                      onPressed: _pickProfileImage,
                      tooltip: "Change Profile Picture",
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(CupertinoIcons.person)),
              validator: (value) => (value == null || value.isEmpty) ? "Name cannot be empty" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(CupertinoIcons.mail)),
              readOnly: true, // Typically email is not directly editable
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text("Preferences", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DropdownButtonFormField<WeightUnit>(
              value: _selectedWeightUnit,
              decoration: const InputDecoration(labelText: "Weight Unit", prefixIcon: Icon(CupertinoIcons.gauge)),
              items: WeightUnit.values.map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit.toString().split('.').last.toUpperCase()),
              )).toList(),
              onChanged: (WeightUnit? newValue) {
                if (newValue != null) setState(() => _selectedWeightUnit = newValue);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<DistanceUnit>(
              value: _selectedDistanceUnit,
              decoration: const InputDecoration(labelText: "Distance Unit", prefixIcon: Icon(CupertinoIcons.map_pin_ellipse)),
              items: DistanceUnit.values.map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit.toString().split('.').last.capitalize()),
              )).toList(),
              onChanged: (DistanceUnit? newValue) {
                if (newValue != null) setState(() => _selectedDistanceUnit = newValue);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes", style: TextStyle(fontSize: 16)),
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
