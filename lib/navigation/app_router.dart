import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/models/workout_plan.dart';
// Import ApiService for isAuthenticated (or use AuthManager)
import 'package:aksumfit/features/auth/presentation/screens/login_screen.dart';
import 'package:aksumfit/features/auth/presentation/screens/registration_screen.dart';
// Removed duplicate import for registration_screen.dart
import 'package:aksumfit/features/nutrition/presentation/screens/log_meal_screen.dart'; // For /log-meal-quick
import 'package:aksumfit/features/profile/presentation/screens/change_password_screen.dart';
import 'package:aksumfit/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:aksumfit/features/workout/workout_screen.dart'; // For /workout-session
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../core/presentation/main_scaffold.dart';
import '../features/notifications/notification_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/explore/presentation/screens/exercise_library_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/workout/presentation/screens/workout_summary_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart'; // Import SettingsScreen
// Setup Flow Screens
// import '../features/onboarding/presentation/setup_flow/weight_height_screen.dart'; // Will be removed
import '../features/onboarding/presentation/setup_flow/weight_input_screen.dart';   // Added
import '../features/onboarding/presentation/setup_flow/height_input_screen.dart';  // Added
import '../features/onboarding/presentation/setup_flow/fitness_goal_screen.dart';
import '../features/onboarding/presentation/setup_flow/experience_level_screen.dart';
import '../features/onboarding/presentation/setup_flow/training_prefs_screen.dart';
import '../features/onboarding/presentation/setup_flow/additional_info_screen.dart';
// Explore Screens
import '../features/explore/presentation/screens/browse_workouts_screen.dart';
// Progress Screens
import '../features/progress/presentation/screens/detailed_progress_screen.dart';
// Challenges Screens
import '../features/challenges/presentation/screens/challenges_screen.dart';


// Example of a simple "Not Authorized" screen
class NotAuthorizedScreen extends StatelessWidget {
  const NotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are not authorized to view this page.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/splash', // Initial location can remain splash
  refreshListenable: AuthManager(), // Re-evaluate routes when AuthManager notifies listeners
  redirect: (BuildContext context, GoRouterState state) async {
    final authManager = AuthManager();
    final bool isLoggedIn = authManager.isLoggedIn;
    final User? currentUser = authManager.currentUser;

    final String location = state.uri.toString();
    final bool isSplash = location == '/splash';
    final bool isOnboarding = location == '/onboarding';
    final bool isLoggingIn = location == '/login';
    final bool isRegistering = location == '/register';
    final bool isNavigatingToSetupFlow = location.startsWith('/setup/');

    // 1. If on splash, let it build. Splash screen will navigate away.
    if (isSplash) {
      return null;
    }

    // 2. Handle redirection for logged-in users
    if (isLoggedIn) {
      // 2a. User has NOT completed setup
      if (currentUser != null && currentUser.hasCompletedSetup != true) {
        // If trying to access auth/onboarding pages OR any other page that is NOT setup flow, redirect to setup
        if (isOnboarding || isLoggingIn || isRegistering) {
          return '/setup/weight-input'; // Updated redirect to new first screen
        }
        if (!isNavigatingToSetupFlow) {
          return '/setup/weight-input'; // Updated redirect to new first screen
        }
      }
      // 2b. User HAS completed setup
      else if (currentUser != null && currentUser.hasCompletedSetup == true) {
        // If trying to access auth/onboarding pages or setup flow, redirect to main
        if (isOnboarding || isLoggingIn || isRegistering || isNavigatingToSetupFlow) {
          return '/main';
        }
      }
    }
    // 3. Handle redirection for logged-out users
    else {
      // If not logged in and trying to access a protected route (anything not auth/onboarding/splash)
      if (!isLoggingIn && !isRegistering && !isOnboarding) {
        return '/login'; // Or '/onboarding' if you want to force onboarding for new sessions
      }
    }

    // 4. Role-based redirection example (can be placed here or after other general checks)
    if (location == '/admin' && isLoggedIn && !authManager.hasRole(UserRole.trainer)) { // Assuming trainer is admin
        return '/not-authorized';
    }

    // 5. No redirection needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/challenges', // New Challenges Route
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ChallengesScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const RegistrationScreen(),
      ),
    ),
     GoRoute(
      path: '/not-authorized', // Simple screen for unauthorized access
      builder: (context, state) => const NotAuthorizedScreen(),
    ),
    // Protected routes from here:
    GoRoute(
      path: '/main',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const MainScaffold(),
      ),
      // Example of per-route redirect if needed, though global is often better
      // redirect: (context, state) async {
      //   if (!AuthManager().isLoggedIn) return '/login';
      //   return null;
      // },
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const NotificationScreen(),
      ),
    ),
    // Removed redundant /log-meal route. Use /log-meal-quick or pass date via extra.
    // Removed /workout route as WorkoutScreen now requires a plan.
    // Access workouts via /workout-plans or /workout-session.
    GoRoute(
      path: '/progress',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ProgressScreen(),
      ),
    ),
    GoRoute(
      path: '/exercise-library',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ExerciseLibraryScreen(),
      ),
    ),
    GoRoute(
      path: '/nutrition',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const NutritionScreen(),
      ),
    ),
    GoRoute(
      path: '/social',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SocialScreen(),
      ),
    ),
    GoRoute(
      path: '/workout-summary',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const WorkoutSummaryScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/edit', // Route for EditProfileScreen
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/change-password', // Route for ChangePasswordScreen
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ChangePasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/workout-session', // For starting a specific workout plan
      pageBuilder: (context, state) {
        final workoutPlan = state.extra as WorkoutPlan?;
        if (workoutPlan != null) {
          return CupertinoPage(key: state.pageKey, child: WorkoutScreen(plan: workoutPlan));
        }
        // Handle error or redirect if plan is null, though ideally UI prevents this navigation
        return CupertinoPage(key: state.pageKey, child: const Scaffold(body: Center(child: Text("Error: Workout plan not provided."))));
      },
    ),
    GoRoute(
      path: '/log-meal-quick', // For logging a meal with today's date
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: Builder(builder: (context) {
          final extra = state.extra as Map<String, dynamic>?;
          final imagePath = extra?['imagePath'] as String?;
          // Ensure date is still handled, default to DateTime.now() if not provided in extra
          final date = extra?['date'] as DateTime? ?? DateTime.now();
          return LogMealScreen(date: date, imagePath: imagePath);
        }),
      ),
    ),
    // Setup Flow Routes
    GoRoute(
      path: '/setup/weight-input', // New route
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const WeightInputScreen(),
      ),
    ),
    GoRoute(
      path: '/setup/height-input', // New route
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const HeightInputScreen(),
      ),
    ),
    GoRoute(
      path: '/setup/fitness-goal',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const FitnessGoalScreen(),
      ),
    ),
    GoRoute(
      path: '/setup/experience-level',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const ExperienceLevelScreen(),
      ),
    ),
    GoRoute(
      path: '/setup/training-prefs',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const TrainingPrefsScreen(),
      ),
    ),
    GoRoute(
      path: '/setup/additional-info',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const AdditionalInfoScreen(),
      ),
    ),
    GoRoute(
      path: '/browse-workouts',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: const BrowseWorkoutsScreen(),
      ),
    ),
    GoRoute(
      path: '/detailed-progress',
      pageBuilder: (context, state) => const CupertinoPage(
        key: ValueKey('detailed_progress'),
        child: DetailedProgressScreen(),
      ),
    ),
  ],
);

// Helper function for custom page transitions
Page<dynamic> buildPageWithCustomTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOutQuad; // A common easing curve

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      // Combine with FadeTransition
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn), // Fade in as it slides
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350), // Adjust duration as needed
  );
}
