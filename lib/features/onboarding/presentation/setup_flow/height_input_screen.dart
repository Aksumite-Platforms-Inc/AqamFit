import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'setup_flow_viewmodel.dart';
import 'dart:math'; // For pow in DoublePrecision

// Helper extension for precision (copied from original WeightHeightScreen)
extension DoublePrecision on double {
  double toPrecision(int fractionDigits) {
    double mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

class HeightInputScreen extends StatefulWidget {
  const HeightInputScreen({super.key});

  @override
  State<HeightInputScreen> createState() => _HeightInputScreenState();
}

class _HeightInputScreenState extends State<HeightInputScreen> {
  late SetupFlowViewModel _viewModel;

  // Conversion factors & defaults (copied and adjusted)
  static const double cmToFeetFactor = 1 / 30.48;
  final int _initialHeightCm = 170;
  // double _initialHeightFeet = 5.57; // Not directly used for init, derived from cm.

  double _currentDisplayHeight = 170.0; // Local display value

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SetupFlowViewModel>();
    if (_viewModel.height == null) {
       _viewModel.updateHeight(_initialHeightCm.toDouble()); // Store in cm
    }
  }

  void _onNext() {
    if (_viewModel.height == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure height is selected.')),
      );
      return;
    }
    print('ViewModel state (Height): Height: ${_viewModel.height} ${_viewModel.heightUnit}');
    context.go('/setup/fitness-goal');
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = context.watch<SetupFlowViewModel>();
    final theme = Theme.of(context);

    // --- Height Picker Configuration ---
    double minDisplayHeight, maxDisplayHeight;
    int displayHeightDecimalPlaces;
    _currentDisplayHeight = _viewModel.height ?? _initialHeightCm.toDouble(); // Base value from VM (cm)

    if (_viewModel.heightUnit == 'cm') {
      minDisplayHeight = 100.0; maxDisplayHeight = 250.0;
      displayHeightDecimalPlaces = 0;
    } else { // ft
      minDisplayHeight = (100.0 * cmToFeetFactor).toPrecision(1);
      maxDisplayHeight = (250.0 * cmToFeetFactor).toPrecision(1);
      displayHeightDecimalPlaces = 1;
      _currentDisplayHeight = _currentDisplayHeight * cmToFeetFactor; // Convert base cm to ft for display
    }
    _currentDisplayHeight = _currentDisplayHeight.toPrecision(displayHeightDecimalPlaces).clamp(minDisplayHeight, maxDisplayHeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Height'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This screen should always be able to pop to WeightInputScreen
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              // Fallback just in case, though direct navigation here is unlikely
              context.go('/setup/weight-input');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded( // Wrap content in Expanded and SingleChildScrollView
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Select Your Height',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                        children: [
                          Text(
                            '${_currentDisplayHeight.toStringAsFixed(displayHeightDecimalPlaces)} ${_viewModel.heightUnit}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                      trackShape: const RoundedRectSliderTrackShape(),
                      trackHeight: 8.0,
                      thumbColor: theme.colorScheme.primary,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                      activeTickMarkColor: theme.colorScheme.onPrimary,
                      inactiveTickMarkColor: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    child: Slider(
                      min: minDisplayHeight,
                      max: maxDisplayHeight,
                      value: _currentDisplayHeight,
                      // Divisions: cm by 1, ft by 0.1
                      divisions: ((maxDisplayHeight - minDisplayHeight) / (_viewModel.heightUnit == 'cm' ? 1.0 : 0.1)).round().clamp(1,1000),
                      label: _currentDisplayHeight.toStringAsFixed(displayHeightDecimalPlaces),
                      onChanged: (value) {
                        double valueToStore = value;
                        if (_viewModel.heightUnit == 'ft') {
                          valueToStore = value / cmToFeetFactor; // ft to cm
                        }
                        _viewModel.updateHeight(valueToStore.toPrecision(displayHeightDecimalPlaces == 0 ? 0 : 1));
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.secondary, size: 36),
                        onPressed: () {
                          double step = _viewModel.heightUnit == 'cm' ? 1.0 : 0.1;
                          double newValue = (_currentDisplayHeight - step).clamp(minDisplayHeight, maxDisplayHeight);
                          double valueToStore = newValue;
                          if (_viewModel.heightUnit == 'ft') {
                            valueToStore = newValue / cmToFeetFactor;
                          }
                          _viewModel.updateHeight(valueToStore.toPrecision(displayHeightDecimalPlaces == 0 ? 0 : 1));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.secondary, size: 36),
                        onPressed: () {
                          double step = _viewModel.heightUnit == 'cm' ? 1.0 : 0.1;
                          double newValue = (_currentDisplayHeight + step).clamp(minDisplayHeight, maxDisplayHeight);
                          double valueToStore = newValue;
                          if (_viewModel.heightUnit == 'ft') {
                            valueToStore = newValue / cmToFeetFactor;
                          }
                          _viewModel.updateHeight(valueToStore.toPrecision(displayHeightDecimalPlaces == 0 ? 0 : 1));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _viewModel.heightUnit,
                            children: const {
                              'cm': Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('cm')),
                              'ft': Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('ft')),
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
                  ],
                ),
              ),
            ),
            // Spacer removed, button wrapped in Padding outside Expanded
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
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
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
