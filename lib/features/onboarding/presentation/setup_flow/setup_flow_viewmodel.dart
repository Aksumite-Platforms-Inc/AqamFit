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
    if (_preferredTrainingDays.contains(day)) {
      _preferredTrainingDays.remove(day);
    } else {
      _preferredTrainingDays.add(day);
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
    notifyListeners();
  }
}
