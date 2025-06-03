import 'package:mockito/mockito.dart';
import 'package:aksumfit/features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart';
import 'package:flutter/material.dart'; // ChangeNotifier is from foundation

// For code generation with build_runner:
// import 'mock_view_models.mocks.dart';


// If not using build_runner, define manual mock:
// We need to ensure it has `notifyListeners()` and default getter values.
class MockSetupFlowViewModel extends Mock implements SetupFlowViewModel {
  // Internal state for getters if not stubbed by tests
  String? _fitnessGoal;
  String? _experienceLevel;
  List<String> _preferredTrainingDays = [];
  DateTime? _dateOfBirth;
  String? _gender;
  double? _weight;
  String _weightUnit = 'kg';
  double? _height;
  String _heightUnit = 'cm';
  String? _selectedFrequencyPreset; // New internal state

  MockSetupFlowViewModel() {
    // Initialize with default stubs to prevent MissingStubError
    _initializeStubs();
  }

  void _initializeStubs() {
    // Default stubs for existing methods
    when(updateFitnessGoal(any)).thenAnswer((realInvocation) {
      _fitnessGoal = realInvocation.positionalArguments.first as String?;
      notifyListeners();
    });
    when(updateExperienceLevel(any)).thenAnswer((realInvocation) {
      _experienceLevel = realInvocation.positionalArguments.first as String?;
      notifyListeners();
    });
    when(updateDateOfBirth(any)).thenAnswer((realInvocation) {
      _dateOfBirth = realInvocation.positionalArguments.first as DateTime?;
      notifyListeners();
    });
    when(updateGender(any)).thenAnswer((realInvocation) {
      _gender = realInvocation.positionalArguments.first as String?;
      notifyListeners();
    });
    when(updateWeight(any)).thenAnswer((realInvocation) {
      _weight = realInvocation.positionalArguments.first as double?;
      notifyListeners();
    });
    when(setWeightUnit(any)).thenAnswer((realInvocation) {
      _weightUnit = realInvocation.positionalArguments.first as String;
      notifyListeners();
    });
    when(updateHeight(any)).thenAnswer((realInvocation) {
      _height = realInvocation.positionalArguments.first as double?;
      notifyListeners();
    });
    when(setHeightUnit(any)).thenAnswer((realInvocation) {
      _heightUnit = realInvocation.positionalArguments.first as String;
      notifyListeners();
    });

    // Stubs for new/modified methods related to training preferences
    when(toggleTrainingDay(any)).thenAnswer((realInvocation) {
      final day = realInvocation.positionalArguments.first as String;
      _selectedFrequencyPreset = null; // A key behavior change

      final newDays = List<String>.from(_preferredTrainingDays);
      if (newDays.contains(day)) {
        newDays.remove(day);
      } else {
        newDays.add(day);
        // Use the real ViewModel's static dayOrder for sorting if needed by tests
        // For simplicity, mock won't sort unless explicitly coded here or test verifies unsorted.
        // Let's assume tests will provide sorted lists if order matters for verification.
      }
      _preferredTrainingDays = newDays;
      notifyListeners();
    });

    when(selectFrequencyPreset(any)).thenAnswer((realInvocation) {
      final presetName = realInvocation.positionalArguments.first as String?;
      if (presetName == null || !SetupFlowViewModel.frequencyPresets.containsKey(presetName)) {
        _selectedFrequencyPreset = null;
        // _preferredTrainingDays remains unchanged as per current VM logic for custom flow
      } else {
        _selectedFrequencyPreset = presetName;
        _preferredTrainingDays = List.from(SetupFlowViewModel.frequencyPresets[presetName]!);
      }
      notifyListeners();
    });
     when(setPreferredTrainingDays(any)).thenAnswer((realInvocation) {
      _preferredTrainingDays = List<String>.from(realInvocation.positionalArguments.first as List<String>);
      _selectedFrequencyPreset = null; // Custom days imply no preset
      notifyListeners();
    });
  }

  // Reset mock state before each test if needed, or manage via when().thenReturn() per test.
  void resetMockState() {
    _fitnessGoal = null;
    _experienceLevel = null;
    _preferredTrainingDays = [];
    _dateOfBirth = null;
    _gender = null;
    _weight = null;
    _weightUnit = 'kg';
    _height = null;
    _heightUnit = 'cm';
    _selectedFrequencyPreset = null;

    // Clear previous interactions if using Mockito's verify framework heavily.
    // clearInteractions(this); // 'this' might not work if not a real mockito generated mock.
    // Re-initialize stubs if they were changed by tests.
    // _initializeStubs(); // Or ensure tests don't modify global stubs.
  }

  // Override getters
  @override
  String? get fitnessGoal => _fitnessGoal;
  @override
  String? get experienceLevel => _experienceLevel;
  @override
  List<String> get preferredTrainingDays => _preferredTrainingDays;
  @override
  DateTime? get dateOfBirth => _dateOfBirth;
  @override
  String? get gender => _gender;
  @override
  double? get weight => _weight;
  @override
  String get weightUnit => _weightUnit;
  @override
  double? get height => _height;
  @override
  String get heightUnit => _heightUnit;
  @override
  String? get selectedFrequencyPreset => _selectedFrequencyPreset; // New getter

  // --- ChangeNotifier implementation ---
  final List<VoidCallback> _listeners = [];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) { // Iterate over a copy
      listener();
    }
  }

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void dispose() {
    _listeners.clear();
    super.dispose(); // Important if extending a class that has a dispose method
  }
}
