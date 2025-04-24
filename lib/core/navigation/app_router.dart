import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/streak/screens/streak_screen.dart';


// Navigation bar
import './bottom_nav_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// Shell route for tabs (bottom navigation)
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        int currentIndex = 0;

        if (location.startsWith('/explore')) {
          currentIndex = 1;
        } else if (location.startsWith('/workout')) {
          currentIndex = 2;
        } else if (location.startsWith('/progress')) {
          currentIndex = 3;
        } else if (location.startsWith('/profile')) {
          currentIndex = 4;
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNav(index: currentIndex),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/workout',
          builder: (context, state) => const WorkoutScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/streak',
          builder: (context, state) => const StreakScreen(),
        ),
      ],
    ),

    // Outside shell route
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
