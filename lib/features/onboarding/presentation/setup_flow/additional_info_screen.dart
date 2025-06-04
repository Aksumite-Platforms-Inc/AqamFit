import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'setup_flow_viewmodel.dart';
import '../../../../services/auth_manager.dart';
import '../../../../repositories/user_repository.dart';
// Required for User type if used directly

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

// _GenderOption can be kept if we want icons in the bottom sheet list tiles too.
// For simplicity, the bottom sheet might just use text.
// Let's keep it for now, can decide in the _showGenderPickerBottomSheet implementation.
class _GenderOption {
  final String title;
  final IconData icon; // Icon for the card, maybe also for list tile
  _GenderOption({required this.title, required this.icon});
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  // This list is used for the bottom sheet options now
  final List<_GenderOption> _genderOptions = [
    _GenderOption(title: "Male", icon: Icons.male),
    _GenderOption(title: "Female", icon: Icons.female),
    _GenderOption(title: "Other", icon: Icons.transgender),
    _GenderOption(title: "Prefer not to say", icon: Icons.question_mark),
  ];
  bool _isFinishing = false;
  bool _isDobExpanded = false;
  bool _isGenderExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Re-purpose _selectDate to be used by the inline CalendarDatePicker
  // This method was originally used with showDatePicker, now adapted.
  void _handleDateSelection(DateTime newDate, SetupFlowViewModel viewModel) {
    viewModel.updateDateOfBirth(newDate);
    setState(() {
      _isDobExpanded = false; // Auto-collapse after selection
    });
  }

  void _handleGenderSelection(String gender, SetupFlowViewModel viewModel) {
    viewModel.updateGender(gender);
    setState(() {
      _isGenderExpanded = false; // Auto-collapse
    });
  }

  Future<void> _finishSetup() async {
    final viewModel = context.read<SetupFlowViewModel>();
    // bool valid = true; // Not strictly needed due to early returns
    if (viewModel.dateOfBirth == null) {
      // valid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }
    if (viewModel.gender == null) {
      // valid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender.')),
      );
      return;
    }

    // if (!valid) return; // Not needed

    setState(() {
      _isFinishing = true;
    });

    // ViewModel already obtained with context.read earlier in this method.
    // final viewModel = context.read<SetupFlowViewModel>();
    final authManager = context.read<AuthManager>();
    final userRepository = context.read<UserRepository>();

    final String? userId = authManager.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in. Please restart.')),
      );
      setState(() { _isFinishing = false; });
      // Potentially navigate to login: context.go('/login');
      return;
    }

    try {
      final updatedUser = await userRepository.updateUserProfileSetup(
        userId: userId,
        weight: viewModel.weight,
        weightUnit: viewModel.weightUnit, // Ensure this is the one you want (e.g. from viewModel.weightUnit)
        height: viewModel.height,
        heightUnit: viewModel.heightUnit,
        fitnessGoal: viewModel.fitnessGoal,
        experienceLevel: viewModel.experienceLevel,
        preferredTrainingDays: viewModel.preferredTrainingDays,
        dateOfBirth: viewModel.dateOfBirth,
        gender: viewModel.gender,
      );

      if (updatedUser != null) {
        await authManager.completeOnboardingSetup(updatedUser); // Pass the updated user
        if (mounted) {
          context.go('/main');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFinishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupFlowViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Almost There!'), // Updated AppBar title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Just a few more details...',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // --- Date of Birth Section ---
                      _buildDobHeaderPanel(context, viewModel, theme),
                      AnimatedVisibility(
                        visible: _isDobExpanded,
                        child: Material( // Material for elevation and theming of CalendarDatePicker
                          elevation: 2,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CalendarDatePicker(
                              initialDate: viewModel.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              onDateChanged: (newDate) => _handleDateSelection(newDate, viewModel),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Gender Section ---
                      _buildGenderHeaderPanel(context, viewModel, theme),
                      AnimatedVisibility(
                        visible: _isGenderExpanded,
                        child: Material( // Material for elevation
                           elevation: 2,
                           borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                            child: Column( // Using Column for ListTiles
                              children: _genderOptions.map((option) {
                                final isSelected = viewModel.gender == option.title;
                                return ListTile(
                                  leading: Icon(option.icon,
                                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                                  title: Text(
                                    option.title,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? theme.colorScheme.primary : null,
                                    ),
                                  ),
                                  trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                                  onTap: () => _handleGenderSelection(option.title, viewModel),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  selected: isSelected,
                                  selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24), // Padding at the end of scrollable content
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _isFinishing ? null : _finishSetup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: _isFinishing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Finish Setup'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isFinishing ? null : () => context.pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8), // Some bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
