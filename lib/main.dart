import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navigation/app_router.dart'; // Import the app router

// Removed import 'screens/splash_screen.dart'; - router handles this

void main() {
  runApp(AxumFitApp());
}

class AxumFitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Changed to MaterialApp.router
      title: 'AxumFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1E88E5)),
        // scaffoldBackgroundColor: Color(0xFFF8F9FA), // Removed for M3 default
        appBarTheme: AppBarTheme(
          // backgroundColor: Colors.white, // Removed for M3 default
          // foregroundColor: Color(0xFF2D3748), // Removed for M3 default
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          // backgroundColor: Colors.white, // Removed for M3 default
          // selectedItemColor: Color(0xFF1E88E5), // Removed for M3 default
          // unselectedItemColor: Colors.grey[600], // Removed for M3 default
          type: BottomNavigationBarType.fixed,
        ),
        // No explicit textTheme here to inherit M3 defaults first
      ),
      routerConfig: router, // Set the routerConfig
      // home: SplashScreen(), // Removed home property
    );
  }
}

// All screen classes and their helper methods,
// as well as OnboardingPageWidget,
// have been moved to their respective files
// in lib/screens/.
// Model classes (OnboardingPage, WorkoutExercise, MealEntry, LeaderboardEntry, Challenge)
// have been moved to their respective files in lib/models/.
