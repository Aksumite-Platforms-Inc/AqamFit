import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aksumfit/models/user.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/models/workout_plan.dart';
import 'package:aksumfit/services/api_service.dart'; // Import ApiService for isAuthenticated (or use AuthManager)
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
import '../features/nutrition/presentation/screens/log_meal_screen.dart';
import '../features/workout/workout_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/explore/presentation/screens/exercise_library_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/workout/presentation/screens/workout_summary_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart'; // Import SettingsScreen

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
    final bool isLoggedIn = authManager.isLoggedIn; // Or await ApiService().isAuthenticated();

    final String location = state.uri.toString();
    final bool isSplash = location == '/splash';
    final bool isOnboarding = location == '/onboarding';
    final bool isLoggingIn = location == '/login';
    final bool isRegistering = location == '/register';

    // If on splash, let it build. Splash screen will navigate away.
    if (isSplash) {
      return null;
    }

    // If logged in and trying to access auth/onboarding pages, redirect to main
    if (isLoggedIn && (isOnboarding || isLoggingIn || isRegistering)) {
      return '/main';
    }

    // If not logged in and trying to access a protected route (anything not auth/onboarding)
    if (!isLoggedIn && !isLoggingIn && !isRegistering && !isOnboarding) {
      return '/login'; // Or '/onboarding' if you want to force onboarding for new sessions
    }

    // Role-based redirection example for a hypothetical '/admin' route
    if (location == '/admin' && isLoggedIn && !authManager.hasRole(UserRole.trainer)) { // Assuming trainer is admin
        return '/not-authorized';
    }

    return null; // No redirection needed
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
        // LogMealScreen needs a date. We pass today's date.
        // Optional: could also pass a specific MealType via `extra` if quick actions were more specific.
        child: LogMealScreen(date: DateTime.now()),
      ),
    ),
  ],
);
