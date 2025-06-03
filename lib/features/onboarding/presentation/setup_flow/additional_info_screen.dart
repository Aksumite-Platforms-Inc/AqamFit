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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateOfBirthController;
  final List<String> _genders = ["Male", "Female", "Other", "Prefer not to say"];
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SetupFlowViewModel>();
    _dateOfBirthController = TextEditingController(
      text: viewModel.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(viewModel.dateOfBirth!)
          : '',
    );
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, SetupFlowViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != viewModel.dateOfBirth) {
      viewModel.updateDateOfBirth(picked);
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _finishSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    // labelText: 'Date of Birth', // Label can be part of the card title
                    hintText: 'Select your date of birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  ),
                  readOnly: true,
                  textAlign: TextAlign.center,
                  onTap: () => _selectDate(context, viewModel),
                  validator: (value) {
                    if (viewModel.dateOfBirth == null) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Less vertical padding for dropdown
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DropdownButtonFormField<String>(
                  value: viewModel.gender,
                  items: _genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(child: Text(value)), // Center text in dropdown items
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    viewModel.updateGender(newValue);
                  },
                  decoration: const InputDecoration(
                    // labelText: 'Gender', // Label can be part of the card title
                    hintText: 'Select your gender',
                    border: InputBorder.none, // Remove border from dropdown itself to blend with card
                    prefixIcon: Icon(Icons.wc), // Example gender icon (wc for washroom, general person icon)
                    // Or Icons.person_outline, Icons.transgender, etc.
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 15.0), // Adjust padding
                  ),
                  isExpanded: true, // Ensure dropdown takes available width for centering text
                  alignment: Alignment.center, // Center selected value text
                  validator: (value) => value == null ? 'Please select your gender' : null,
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
