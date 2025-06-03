import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:numberpicker/numberpicker.dart';
import 'setup_flow_viewmodel.dart';
import 'dart:math'; // For pow in DoublePrecision

// Helper extension for precision (copied from original WeightHeightScreen)
extension DoublePrecision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

class WeightInputScreen extends StatefulWidget {
  const WeightInputScreen({super.key});

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  late SetupFlowViewModel _viewModel;

  // Conversion factors & defaults (copied and adjusted)
  static const double kgToLbsFactor = 2.20462;
  double _initialWeightKg = 70.0;
  // double _initialWeightLbs = 154.0; // Not directly used for initialization in this screen's logic

  double _currentDisplayWeight = 70.0; // Local display value

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SetupFlowViewModel>();
    if (_viewModel.weight == null) {
      _viewModel.updateWeight(_initialWeightKg); // Store in kg
    }
  }

  void _onNext() {
    if (_viewModel.weight == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure weight is selected.')),
      );
      return;
    }
    print('ViewModel state (Weight): Weight: ${_viewModel.weight} ${_viewModel.weightUnit}');
    context.go('/setup/height-input');
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = context.watch<SetupFlowViewModel>();
    final theme = Theme.of(context);

    // --- Weight Picker Configuration ---
    double minDisplayWeight, maxDisplayWeight;
    int displayWeightDecimalPlaces = 1;
    _currentDisplayWeight = _viewModel.weight ?? _initialWeightKg; // Base value from VM (kg)

    if (_viewModel.weightUnit == 'kg') {
      minDisplayWeight = 30.0; maxDisplayWeight = 200.0;
    } else { // lbs
      minDisplayWeight = (30.0 * kgToLbsFactor).roundToDouble();
      maxDisplayWeight = (200.0 * kgToLbsFactor).roundToDouble();
      _currentDisplayWeight = _currentDisplayWeight * kgToLbsFactor; // Convert base kg to lbs for display
    }
    _currentDisplayWeight = _currentDisplayWeight.toPrecision(displayWeightDecimalPlaces).clamp(minDisplayWeight, maxDisplayWeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Weight'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              // This might be the first screen in the setup flow after login/register.
              // Fallback to a safe route like /main or /onboarding.
              context.go('/main');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column( // Changed to Column for simpler structure for single input
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Select Your Weight',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
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
                    minValue: minDisplayWeight,
                    maxValue: maxDisplayWeight,
                    value: _currentDisplayWeight,
                    decimalPlaces: displayWeightDecimalPlaces,
                    onChanged: (value) {
                      double valueToStore = value;
                      if (_viewModel.weightUnit == 'lbs') {
                        valueToStore = value / kgToLbsFactor;
                      }
                      _viewModel.updateWeight(valueToStore.toPrecision(1));
                    },
                    itemHeight: 70,
                    itemWidth: 60,
                    textStyle: TextStyle(fontSize: 20, color: theme.colorScheme.onSurfaceVariant),
                    selectedTextStyle: TextStyle(fontSize: 28, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    axis: Axis.horizontal,
                    integerDecoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline), // Use theme.colorScheme.outline
                      borderRadius: BorderRadius.circular(8),
                    ),
                    decimalDecoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline), // Use theme.colorScheme.outline
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _viewModel.weightUnit,
                    children: const {
                      'kg': Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('kg')),
                      'lbs': Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('lbs')),
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
            const Spacer(), // Push button to bottom
            ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text('Next'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
