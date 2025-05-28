import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '.dart_tool/flutter_gen/gen_l10n/app_localizations.dart' as S;
import 'navigation/app_router.dart'; // Import the app router
import 'providers/locale_provider.dart';
import 'theme/app_theme.dart'; // Import the AppTheme

// Removed import 'screens/splash_screen.dart'; - router handles this

void main() {
  final localeProvider = LocaleProvider(); // Create instance
  runApp(
    ChangeNotifierProvider(
      create: (context) => localeProvider,
      child: AxumFitApp(),
    ),
  );
}

class AxumFitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp.router(
      // Changed to MaterialApp.router
      title: 'AxumFit',
      locale: localeProvider.locale, // Pass locale
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use the AppTheme
      routerConfig: router, // Set the routerConfig
      // home: SplashScreen(), // Removed home property
      localizationsDelegates: [
        S.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.AppLocalizations.supportedLocales,
    );
  }
}

// All screen classes and their helper methods,
// as well as OnboardingPageWidget,
// have been moved to their respective files
// in lib/screens/.
// Model classes (OnboardingPage, WorkoutExercise, MealEntry, LeaderboardEntry, Challenge)
// have been moved to their respective files in lib/models/.
