import '../models/user.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  Future<User?> loginUser(String email, String password) async {
    try {
      final authResponse = await _apiService.login(email: email, password: password);
      if (authResponse.success) {
        await _apiService.saveToken(authResponse.token);
        return authResponse.user;
      }
    } catch (e) {
      print('Login failed: $e');
      // In a real app, handle different types of errors, e.g., DioException, etc.
      return null;
    }
    return null;
  }

  Future<User?> registerUser(String name, String email, String password) async {
    try {
      final authResponse = await _apiService.register(name: name, email: email, password: password);
      if (authResponse.success) {
        await _apiService.saveToken(authResponse.token);
        return authResponse.user;
      }
    } catch (e) {
      print('Registration failed: $e');
      return null;
    }
    return null;
  }

  Future<User?> getMyProfile() async {
    try {
      // In a real app, this method would likely require an auth token.
      // The ApiService's Dio instance would be configured with an interceptor
      // to automatically add the token from FlutterSecureStorage.
      // For this mock, we directly call the mock profile fetch.
      return await _apiService.getUserProfile();
    } catch (e) {
      print('Get profile failed: $e');
      return null;
    }
  }

  Future<void> logoutUser() async {
    await _apiService.clearToken();
    // Potentially notify other parts of the app about logout
  }

  Future<User?> updateUserProfileSetup({
    required String userId, // userId might be implicit if using a token-based API for self-update
    double? weight,
    String? weightUnit, // Note: User model has preferredWeightUnit, this could be it
    double? height,
    String? heightUnit,
    String? fitnessGoal,
    String? experienceLevel,
    List<String>? preferredTrainingDays,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final Map<String, dynamic> updateDataMap = {};

    if (weight != null) updateDataMap['weight'] = weight;
    // If weightUnit is provided and different from existing preferredWeightUnit, include it.
    // For simplicity, we'll assume preferredWeightUnit on User model is the target for weight's unit.
    if (weightUnit != null) updateDataMap['preferredWeightUnit'] = weightUnit;
    if (height != null) updateDataMap['height'] = height;
    if (heightUnit != null) updateDataMap['heightUnit'] = heightUnit;
    if (fitnessGoal != null) updateDataMap['fitnessGoal'] = fitnessGoal;
    if (experienceLevel != null) updateDataMap['experienceLevel'] = experienceLevel;
    if (preferredTrainingDays != null) updateDataMap['preferredTrainingDays'] = preferredTrainingDays;
    if (dateOfBirth != null) updateDataMap['dateOfBirth'] = dateOfBirth.toIso8601String();
    if (gender != null) updateDataMap['gender'] = gender;

    updateDataMap['hasCompletedSetup'] = true;

    try {
      // Placeholder for actual API call:
      print("UserRepository: Updating profile setup for user $userId with data: $updateDataMap");
      // final response = await _apiService.updateUserProfile(userId: userId, data: updateDataMap);
      // if (response.success) {
      //   return response.user; // Assuming API returns the updated user
      // } else {
      //   print('Update profile setup failed: API error');
      //   return null;
      // }

      // For local testing, let's fetch the current user and apply updates
      User? currentUser = await getMyProfile(); // This assumes getMyProfile() fetches the relevant user
      if (currentUser != null) {
        // Ensure userId matches if multiple users were possible, though getMyProfile usually implies current authenticated user
        if (currentUser.id == userId || true) { // Simplified check for this placeholder
             User updatedUser = currentUser.copyWith(
                weight: weight ?? currentUser.weight,
                preferredWeightUnit: weightUnit ?? currentUser.preferredWeightUnit, // Assuming weightUnit updates preferredWeightUnit
                height: height ?? currentUser.height,
                heightUnit: heightUnit ?? currentUser.heightUnit,
                fitnessGoal: fitnessGoal ?? currentUser.fitnessGoal,
                experienceLevel: experienceLevel ?? currentUser.experienceLevel,
                preferredTrainingDays: preferredTrainingDays ?? currentUser.preferredTrainingDays,
                dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
                gender: gender ?? currentUser.gender,
                hasCompletedSetup: true,
             );
             print("UserRepository: Locally updated user: ${updatedUser.toJson()}");
             return updatedUser;
        } else {
          print("UserRepository: User ID mismatch. Cannot update locally.");
          return null;
        }
      } else {
        print("UserRepository: Could not fetch current user to update locally.");
        return null;
      }

    } catch (e) {
      print('Update profile setup failed: $e');
      return null;
    }
  }
}
