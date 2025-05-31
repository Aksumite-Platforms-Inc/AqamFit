import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Implement actual API call to change password
    // For now, just show a success message if new passwords match.
    // A real implementation would involve ApiService().changePassword(...)

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    // Mock success:
    print("Mock Change Password: Current: $currentPassword, New: $newPassword");
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password changed successfully (Mocked).")),
    );
    if (mounted) Navigator.of(context).pop();


    // Mock failure example (e.g. if current password was wrong - needs backend)
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Failed to change password. Please check current password.")),
    // );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: "Current Password", prefixIcon: Icon(CupertinoIcons.lock_fill)),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Current password is required.";
                // Add more validation if needed (e.g., length)
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: "New Password", prefixIcon: Icon(CupertinoIcons.lock)),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "New password is required.";
                if (value.length < 6) return "Password must be at least 6 characters.";
                // Add more strength validation if desired
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm New Password", prefixIcon: Icon(CupertinoIcons.lock)),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Please confirm your new password.";
                if (value != _newPasswordController.text) return "Passwords do not match.";
                return null;
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _isLoading ? null : _handleChangePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Change Password", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
