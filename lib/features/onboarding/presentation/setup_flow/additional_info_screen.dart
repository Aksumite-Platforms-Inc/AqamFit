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
        title: const Text('Additional Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'Select your date of birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, viewModel),
                validator: (value) {
                  if (viewModel.dateOfBirth == null) { // Check viewModel directly
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: viewModel.gender,
                items: _genders.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  viewModel.updateGender(newValue);
                },
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  hintText: 'Select your gender',
                ),
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isFinishing ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _isFinishing ? null : _finishSetup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isFinishing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
