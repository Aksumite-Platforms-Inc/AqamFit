import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart'; // Adjusted path assuming it's in the same directory

class WeightHeightScreen extends StatefulWidget {
  const WeightHeightScreen({super.key});

  @override
  State<WeightHeightScreen> createState() => _WeightHeightScreenState();
}

class _WeightHeightScreenState extends State<WeightHeightScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late SetupFlowViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SetupFlowViewModel>();

    _weightController = TextEditingController(
        text: _viewModel.weight?.toString() ?? '');
    _heightController = TextEditingController(
        text: _viewModel.height?.toString() ?? '');

    _weightController.addListener(() {
      final weight = double.tryParse(_weightController.text);
      // Check if the value is different to avoid unnecessary updates and potential loops
      if (weight != _viewModel.weight) {
        _viewModel.updateWeight(weight);
      }
    });

    _heightController.addListener(() {
      final height = double.tryParse(_heightController.text);
      // Check if the value is different
      if (height != _viewModel.height) {
        _viewModel.updateHeight(height);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If viewmodel values change from outside, update controllers.
    // This is less common if this screen is the source of truth during its active time.
    // However, good for scenarios like pre-filling data or if viewModel could be updated by other means.
    // Check if controller text differs from viewmodel to prevent cursor jumps.
    final viewModelWeight = _viewModel.weight?.toString() ?? '';
    if (_weightController.text != viewModelWeight) {
      _weightController.text = viewModelWeight;
    }
    final viewModelHeight = _viewModel.height?.toString() ?? '';
    if (_heightController.text != viewModelHeight) {
      _heightController.text = viewModelHeight;
    }
  }


  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Good practice if using Form's onSaved

      // Values should already be in ViewModel due to listeners
      // But explicit update here ensures latest controller values are set if listeners somehow didn't fire
      _viewModel.updateWeight(double.tryParse(_weightController.text));
      _viewModel.updateHeight(double.tryParse(_heightController.text));

      // Log current ViewModel state before navigating
      print('ViewModel state before navigating:');
      print('Weight: ${_viewModel.weight}, Unit: ${_viewModel.weightUnit}');
      print('Height: ${_viewModel.height}, Unit: ${_viewModel.heightUnit}');

      context.go('/setup/fitness-goal'); // Updated navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild parts of the UI if the ViewModel changes from elsewhere
    // or if we want to directly react to viewModel changes in the build method.
    // For this screen, we primarily update the ViewModel, so direct use of _viewModel is often fine.
    // However, for the SegmentedControl, consuming is good.
    final currentWeightUnit = context.watch<SetupFlowViewModel>().weightUnit;
    final currentHeightUnit = context.watch<SetupFlowViewModel>().heightUnit;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
        centerTitle: true, // Center AppBar title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Potentially show a confirmation dialog if data has been entered
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If cannot pop (e.g. this is the first screen in a nested navigator or deep link)
              // decide where to go, e.g. back to home or login
              context.go('/main'); // Example: go to main if it's a root of a flow
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: Form(
          key: _formKey,
          child: ListView( // Changed to ListView to prevent overflow with keyboard
            children: <Widget>[
              const SizedBox(height: 16), // Add some space at the top
              Center(
                child: Text(
                  'Enter Your Weight',
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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _weightController,
                      textAlign: TextAlign.center, // Center the input text
                decoration: InputDecoration(
                  labelText: 'Weight (${_viewModel.weightUnit})', // Display current unit
                  hintText: 'Enter your weight',
                  hintStyle: TextStyle(textAlign: TextAlign.center), // Center hint text if possible (might be controlled by textAlign on TextFormField)
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Increased padding
                ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Weight must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: currentWeightUnit,
                      children: const {
                        'kg': Text('kg'),
                        'lbs': Text('lbs'),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          _viewModel.setWeightUnit(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Adjusted spacing
              Center(
                child: Text(
                  'Enter Your Height',
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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _heightController,
                      textAlign: TextAlign.center, // Center the input text
                decoration: InputDecoration(
                  labelText: 'Height (${_viewModel.heightUnit})', // Display current unit
                  hintText: 'Enter your height',
                  hintStyle: TextStyle(textAlign: TextAlign.center), // Center hint text
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Increased padding
                ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                         if (double.parse(value) <= 0) {
                          return 'Height must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: currentHeightUnit,
                      children: const {
                        'cm': Text('cm'),
                        'ft': Text('ft/in'), // Representing feet/inches
                      },
                      onValueChanged: (value) {
                         if (value != null) {
                          _viewModel.setHeightUnit(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32), // Adjusted spacing before button
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )
                ),
                child: const Text('Next'),
              ),
              const SizedBox(height: 16), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
