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

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  // _formKey might still be useful if we want to trigger all validations at once,
  // but individual field validators are removed.
  // final _formKey = GlobalKey<FormState>();
  final List<String> _genders = ["Male", "Female", "Other", "Prefer not to say"];
  bool _isFinishing = false;

  // No TextEditingController needed for DOB anymore
  // late TextEditingController _dateOfBirthController;

  @override
  void initState() {
    super.initState();
    // ViewModel is accessed via context.read or context.watch in build/methods
  }

  @override
  void dispose() {
    // No controllers to dispose
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, SetupFlowViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) { // Optional: Theme the date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != viewModel.dateOfBirth) {
      viewModel.updateDateOfBirth(picked);
      // No controller to update, UI will rebuild via watch(viewModel)
    }
  }

  Future<void> _finishSetup() async {
    final viewModel = context.read<SetupFlowViewModel>(); // Use read for one-off actions
    bool valid = true;
    if (viewModel.dateOfBirth == null) {
      valid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return; // Exit early if first validation fails
    }
    if (viewModel.gender == null) {
      valid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender.')),
      );
      return; // Exit early
    }

    if (!valid) return; // Should have been caught by early returns

    setState(() {
      _isFinishing = true;
    });

    final viewModel = context.read<SetupFlowViewModel>();
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
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: Form(
          key: _formKey,
          child: Column( // Changed to Column for better control with Spacer
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Just a few more details...', // Main screen title
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Date of Birth Card
              Center(
                child: Text(
                  'Your Birthday',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduced padding for ListTile
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    viewModel.dateOfBirth != null
                        ? DateFormat('MMMM d, yyyy').format(viewModel.dateOfBirth!)
                        : 'Select your date of birth',
                    style: TextStyle(
                      color: viewModel.dateOfBirth != null
                             ? Theme.of(context).colorScheme.onSurface
                             : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 16, // Consistent font size
                    ),
                    textAlign: viewModel.dateOfBirth == null ? TextAlign.start : TextAlign.start, // Align text to start
                  ),
                  trailing: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onTap: () => _selectDate(context, viewModel),
                ),
              ),
              const SizedBox(height: 24),

              // Gender Card
              Center(
                child: Text(
                  'Your Gender',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: _genders.map((gender) {
                    final isSelected = viewModel.gender == gender;
                    return ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          viewModel.updateGender(gender);
                        }
                        // Optional: allow deselecting by tapping again, though ChoiceChip typically doesn't.
                        // else { viewModel.updateGender(null); }
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                               ? Theme.of(context).colorScheme.onPrimary
                               : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: isSelected
                                 ? Theme.of(context).colorScheme.primary
                                 : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        )
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(), // Pushes buttons to the bottom

              ElevatedButton(
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
