import 'package:flutter/material.dart';

class SetupFlowViewModel extends ChangeNotifier {
  // Private fields
  double? _weight;
  String _weightUnit = 'kg'; // Default
  double? _height;
  String _heightUnit = 'cm'; // Default
  String? _fitnessGoal;
  String? _experienceLevel;
  List<String> _preferredTrainingDays = [];
  DateTime? _dateOfBirth;
  String? _gender;
  String? _selectedFrequencyPreset; // Added for frequency preset

  // Static map for day order if sorting is needed
  static const Map<String, int> dayOrder = {
    "Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4,
    "Friday": 5, "Saturday": 6, "Sunday": 7,
  };

  // Public getters
  double? get weight => _weight;
  String get weightUnit => _weightUnit;
  double? get height => _height;
  String get heightUnit => _heightUnit;
  String? get fitnessGoal => _fitnessGoal;
  String? get experienceLevel => _experienceLevel;
  List<String> get preferredTrainingDays => _preferredTrainingDays;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  String? get selectedFrequencyPreset => _selectedFrequencyPreset; // Added

  // Predefined frequency presets
  // Using full day names as stored in _preferredTrainingDays
  static final Map<String, List<String>> frequencyPresets = {
    "3 days/week": ["Monday", "Wednesday", "Friday"],
    "4 days/week": ["Monday", "Tuesday", "Thursday", "Friday"],
    "5 days/week": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  };

  // Public methods to update fields and notify listeners

  void updateWeight(double? newWeight) {
    _weight = newWeight;
    notifyListeners();
  }

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    notifyListeners();
  }

  void updateHeight(double? newHeight) {
    _height = newHeight;
    notifyListeners();
  }

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    notifyListeners();
  }

  void updateFitnessGoal(String? newFitnessGoal) {
    _fitnessGoal = newFitnessGoal;
    notifyListeners();
  }

  void updateExperienceLevel(String? newExperienceLevel) {
    _experienceLevel = newExperienceLevel;
    notifyListeners();
  }

  void toggleTrainingDay(String day) {
    // If a preset was active, and user clicks a day, they are now in custom mode.
    // The days from the preset should ideally remain as a starting point.
    if (_selectedFrequencyPreset != null) {
      _selectedFrequencyPreset = null; // Or a special "Custom" identifier string
    }

    final newDays = List<String>.from(_preferredTrainingDays);
    if (newDays.contains(day)) {
      newDays.remove(day);
    } else {
      newDays.add(day);
      // Optional: Sort days after adding for consistent order
      newDays.sort((a, b) => (dayOrder[a] ?? 8).compareTo(dayOrder[b] ?? 8));
    }
    _preferredTrainingDays = newDays;
    notifyListeners();
  }

  void selectFrequencyPreset(String? presetName) {
    if (presetName == null || !frequencyPresets.containsKey(presetName)) {
      _selectedFrequencyPreset = null;
      // When deselecting a preset or if preset name is invalid,
      // We can choose to clear days or leave them as they are (custom).
      // For now, let's assume deselecting a preset chip means going custom with current days,
      // so we don't modify _preferredTrainingDays here unless presetName is valid.
      // If a chip is tapped and it's already selected, it might mean "deselect".
      if (presetName == null && _selectedFrequencyPreset != null){
          // This case means a preset was active, and now we want to clear it.
          // Days should probably remain as they were.
      }
       _selectedFrequencyPreset = null;


    } else { // Valid preset name
      _selectedFrequencyPreset = presetName;
      // Set days according to preset, preserving order from definition
      _preferredTrainingDays = List.from(frequencyPresets[presetName]!);
    }
    notifyListeners();
  }

  void setPreferredTrainingDays(List<String> days) {
    _preferredTrainingDays = List.from(days); // Ensure it's a copy
    notifyListeners();
  }

  void updateDateOfBirth(DateTime? newDateOfBirth) {
    _dateOfBirth = newDateOfBirth;
    notifyListeners();
  }

  void updateGender(String? newGender) {
    _gender = newGender;
    notifyListeners();
  }

  // Optional: A method to clear or reset the state if needed for re-entry or cancellation
  void resetState() {
    _weight = null;
    _weightUnit = 'kg';
    _height = null;
    _heightUnit = 'cm';
    _fitnessGoal = null;
    _experienceLevel = null;
    _preferredTrainingDays = [];
    _dateOfBirth = null;
    _gender = null;
    _selectedFrequencyPreset = null; // Reset preset
    notifyListeners();
  }
}
