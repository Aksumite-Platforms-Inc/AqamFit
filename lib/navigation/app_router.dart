import 'package:flutter/material.dart'; // For Widget type, if needed, and for context
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => MainScreen(),
    ),
  ],
);
