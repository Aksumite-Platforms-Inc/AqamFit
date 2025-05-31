import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Change Password"),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('Current Password'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _currentPasswordController,
                  placeholder: "Enter current password",
                  prefix: const Icon(CupertinoIcons.lock_fill, color: CupertinoColors.systemGrey),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Current password is required.";
                    return null;
                  },
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('New Password'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _newPasswordController,
                  placeholder: "Enter new password",
                  prefix: const Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "New password is required.";
                    if (value.length < 6) return "Password must be at least 6 characters.";
                    return null;
                  },
                ),
                CupertinoTextFormFieldRow(
                  controller: _confirmPasswordController,
                  placeholder: "Confirm new password",
                  prefix: const Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please confirm your new password.";
                    if (value != _newPasswordController.text) return "Passwords do not match.";
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Match typical Cupertino button padding
              child: CupertinoButton.filled(
                onPressed: _isLoading ? null : _handleChangePassword,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
