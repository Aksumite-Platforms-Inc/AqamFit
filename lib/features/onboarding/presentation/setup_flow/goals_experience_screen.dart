import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';

class GoalsExperienceScreen extends StatefulWidget {
  const GoalsExperienceScreen({super.key});

  @override
  State<GoalsExperienceScreen> createState() => _GoalsExperienceScreenState();
}

class _GoalsExperienceScreenState extends State<GoalsExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _fitnessGoals = ["Fat Loss", "Muscle Gain", "Maintenance", "Improve Endurance", "Overall Health"];
  final List<String> _experienceLevels = ["Beginner", "Intermediate", "Advanced"];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupFlowViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Goals & Experience'),
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
              const Text(
                'Select Your Primary Fitness Goal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: viewModel.fitnessGoal,
                items: _fitnessGoals.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  viewModel.updateFitnessGoal(newValue);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a goal',
                ),
                validator: (value) => value == null ? 'Please select a goal' : null,
              ),
              const SizedBox(height: 32),
              const Text(
                'Select Your Fitness Experience Level:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: viewModel.experienceLevel,
                items: _experienceLevels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  viewModel.updateExperienceLevel(newValue);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose your experience level',
                ),
                validator: (value) => value == null ? 'Please select your experience level' : null,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton( // Changed to OutlinedButton for visual distinction
                    onPressed: () {
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ViewModel is already updated by DropdownButtonFormField's onChanged
                        context.go('/setup/training-prefs');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Next'),
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
