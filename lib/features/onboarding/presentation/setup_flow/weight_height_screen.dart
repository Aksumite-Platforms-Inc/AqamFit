import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:numberpicker/numberpicker.dart'; // Added import
import 'setup_flow_viewmodel.dart';

class WeightHeightScreen extends StatefulWidget {
  const WeightHeightScreen({super.key});

  @override
  State<WeightHeightScreen> createState() => _WeightHeightScreenState();
}

class _WeightHeightScreenState extends State<WeightHeightScreen> {
  // No longer using FormKey or TextEditingControllers for pickers
  // final _formKey = GlobalKey<FormState>();
  late SetupFlowViewModel _viewModel;

  // Conversion factors
  static const double kgToLbsFactor = 2.20462;
  static const double cmToFeetFactor = 1 / 30.48; // 1 foot = 30.48 cm

  // Default initial values for pickers if ViewModel is null
  // These should be in the selected unit.
  double _initialWeightKg = 70.0;
  double _initialWeightLbs = 154.0;
  int _initialHeightCm = 170;
  double _initialHeightFeet = 5.5; // Approx 168cm

  // Local display values for pickers, derived from ViewModel's base values
  double _currentDisplayWeight = 70.0;
  double _currentDisplayHeight = 170.0;


  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SetupFlowViewModel>();

    // Initialize ViewModel with base unit defaults if null
    if (_viewModel.weight == null) {
      _viewModel.updateWeight(_initialWeightKg); // Store in kg
    }
    if (_viewModel.height == null) {
       _viewModel.updateHeight(_initialHeightCm.toDouble()); // Store in cm
    }
  }

  // No need for didChangeDependencies to sync controllers anymore

  @override
  void dispose() {
    // No controllers to dispose
    super.dispose();
  }

  void _onNext() {
    // No form validation needed for pickers as they constrain values.
    // Values are updated in ViewModel directly via onChanged.
    // We might want to ensure values are not null if that's a requirement,
    // but pickers usually have a default/current value.
    if (_viewModel.weight == null || _viewModel.height == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure weight and height are selected.')),
      );
      return;
    }

    // Log current ViewModel state before navigating
    print('ViewModel state before navigating:');
      print('Weight: ${_viewModel.weight} ${_viewModel.weightUnit}');
      print('Height: ${_viewModel.height} ${_viewModel.heightUnit}');

      context.go('/setup/fitness-goal');
    // } // Removed form validation
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = context.watch<SetupFlowViewModel>(); // Ensure we watch for rebuilds
    final theme = Theme.of(context);

    // --- Weight Picker Configuration ---
    double minDisplayWeight, maxDisplayWeight;
    int displayWeightDecimalPlaces = 1;
    _currentDisplayWeight = _viewModel.weight ?? _initialWeightKg; // Base value from VM (kg)

    if (_viewModel.weightUnit == 'kg') {
      minDisplayWeight = 30.0; maxDisplayWeight = 200.0;
      // _currentDisplayWeight is already in kg
    } else { // lbs
      minDisplayWeight = (30.0 * kgToLbsFactor).roundToDouble(); // e.g. 66 lbs
      maxDisplayWeight = (200.0 * kgToLbsFactor).roundToDouble(); // e.g. 440 lbs
      _currentDisplayWeight = _currentDisplayWeight * kgToLbsFactor; // Convert base kg to lbs for display
    }
    // Clamp display value to its min/max for the current unit
    _currentDisplayWeight = _currentDisplayWeight.clamp(minDisplayWeight, maxDisplayWeight);


    // --- Height Picker Configuration ---
    double minDisplayHeight, maxDisplayHeight;
    int displayHeightDecimalPlaces;
    _currentDisplayHeight = _viewModel.height ?? _initialHeightCm.toDouble(); // Base value from VM (cm)

    if (_viewModel.heightUnit == 'cm') {
      minDisplayHeight = 100.0; maxDisplayHeight = 250.0;
      displayHeightDecimalPlaces = 0;
      // _currentDisplayHeight is already in cm
    } else { // ft
      minDisplayHeight = (100.0 * cmToFeetFactor).toPrecision(1); // e.g. 3.3 ft
      maxDisplayHeight = (250.0 * cmToFeetFactor).toPrecision(1); // e.g. 8.2 ft
      displayHeightDecimalPlaces = 1;
      _currentDisplayHeight = _currentDisplayHeight * cmToFeetFactor; // Convert base cm to ft for display
    }
    // Clamp display value
    _currentDisplayHeight = _currentDisplayHeight.toPrecision(displayHeightDecimalPlaces).clamp(minDisplayHeight, maxDisplayHeight);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              context.go('/main');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        // Removed Form widget as TextFormFields are gone
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Select Your Weight', // Updated title
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Text('Weight (${_viewModel.weightUnit})', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DecimalNumberPicker(
                    minValue: minDisplayWeight, // double
                    maxValue: maxDisplayWeight, // double
                    value: _currentDisplayWeight,
                    decimalPlaces: displayWeightDecimalPlaces,
                    onChanged: (value) {
                      double valueToStore = value;
                      if (_viewModel.weightUnit == 'lbs') {
                        valueToStore = value / kgToLbsFactor; // Convert lbs to kg for storage
                      }
                      _viewModel.updateWeight(valueToStore.toPrecision(1)); // Store with 1 decimal precision
                    },
                    itemHeight: 40,
                    selectedTextStyle: TextStyle(fontSize: 20, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _viewModel.weightUnit,
                    children: const {
                      'kg': Text('kg'),
                      'lbs': Text('lbs'),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        _viewModel.setWeightUnit(value);
                        // No need to convert stored value here, build() will re-calculate displayValue
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Select Your Height', // Updated title
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                   Text('Height (${_viewModel.heightUnit})', style: theme.textTheme.labelLarge),
                   const SizedBox(height: 8),
                  _viewModel.heightUnit == 'cm'
                  ? NumberPicker(
                      minValue: minDisplayHeight.floor(),
                      maxValue: maxDisplayHeight.ceil(),
                      value: _currentDisplayHeight.round(),
                      onChanged: (value) {
                        // Value from NumberPicker is int, store as double in cm
                        _viewModel.updateHeight(value.toDouble());
                      },
                      itemHeight: 40,
                      selectedTextStyle: TextStyle(fontSize: 20, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    )
                  : DecimalNumberPicker(
                      minValue: minDisplayHeight, // double
                      maxValue: maxDisplayHeight, // double
                      value: _currentDisplayHeight,
                      decimalPlaces: displayHeightDecimalPlaces,
                      onChanged: (value) {
                        double valueToStore = value;
                        if (_viewModel.heightUnit == 'ft') {
                           valueToStore = value / cmToFeetFactor; // Convert ft to cm for storage
                        }
                        // For cm, NumberPicker returns int, but updateHeight expects double.
                        // The previous NumberPicker for cm already called value.toDouble()
                        _viewModel.updateHeight(valueToStore.toPrecision(1));
                      },
                      itemHeight: 40,
                      selectedTextStyle: TextStyle(fontSize: 20, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _viewModel.heightUnit,
                    children: const {
                      'cm': Text('cm'),
                      'ft': Text('ft'), // Changed from 'ft/in' to 'ft'
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                         _viewModel.setHeightUnit(value);
                        // No need to convert stored value here, build() will re-calculate displayValue
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
