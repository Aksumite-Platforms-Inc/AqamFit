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

  MockSetupFlowViewModel() {
    // Provide default stubs for methods that might be called without specific test setup
    // This helps prevent MissingStubError if a listener calls a method.
    when(updateFitnessGoal(any)).thenAnswer((realInvocation) {
      _fitnessGoal = realInvocation.positionalArguments.first as String?;
      notifyListeners(); // Ensure mock can also notify if needed, though typically state is managed by test
    });
    when(updateExperienceLevel(any)).thenAnswer((realInvocation) {
      _experienceLevel = realInvocation.positionalArguments.first as String?;
      notifyListeners();
    });
    when(toggleTrainingDay(any)).thenAnswer((realInvocation) {
      final day = realInvocation.positionalArguments.first as String;
      if (_preferredTrainingDays.contains(day)) {
        _preferredTrainingDays.remove(day);
      } else {
        _preferredTrainingDays.add(day);
      }
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
  }


  // Override getters to return internal state or default, can be stubbed in tests too
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

  // Mock addListener and removeListener to satisfy ChangeNotifier interface
  // Store listeners if you need to test that they are added/removed,
  // or to manually trigger them. For most widget tests, this level of detail isn't needed.
  final List<VoidCallback> _listeners = [];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    // super.noSuchMethod(Invocation.method(#addListener, [listener])); // if using pure mockito
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    // super.noSuchMethod(Invocation.method(#removeListener, [listener]));
  }

  @override
  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
    // super.noSuchMethod(Invocation.method(#notifyListeners, []));
  }
   @override
  bool get hasListeners => _listeners.isNotEmpty; // Basic implementation

  @override
  void dispose() {
    _listeners.clear();
    // super.noSuchMethod(Invocation.method(#dispose, []));
  }
}
