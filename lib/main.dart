import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/navigation/app_router.dart';
import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:aksumfit/services/settings_service.dart'; // Import SettingsService
import 'package:aksumfit/services/auth_manager.dart'; // Import AuthManager
import 'package:provider/provider.dart'; // Import Provider

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().initialize(); // Initialize ApiService

  final settingsService = SettingsService(); // Create instance
  await settingsService.loadSettings(); // Load settings

  // Set system UI overlay style - consider moving this after theme is determined or make it dynamic
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // This might need to change based on theme
    statusBarIconBrightness: Brightness.light, // For dark theme, dark for light theme
    systemNavigationBarColor: Color(0xFF0F172A), // Dark theme nav bar
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => AuthManager()),
      ],
      child: const AxumFitApp(),
    ),
  );
}

class AxumFitApp extends StatelessWidget {
  const AxumFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to SettingsService for theme changes
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        // Update System UI Overlay based on current theme
        // This is a common place to adjust system chrome based on theme
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: settingsService.themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: settingsService.themeMode == ThemeMode.light ? const Color(0xFFF0F2F5) : const Color(0xFF0F172A), // Example light/dark nav colors
          systemNavigationBarIconBrightness: settingsService.themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
        ));

        return MaterialApp.router(
          title: 'AxumFit - AI Powered Fitness',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(), // Light theme
          darkTheme: _buildDarkTheme(), // Dark theme
          themeMode: settingsService.themeMode, // Get themeMode from SettingsService
          routerConfig: router,
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1), // Primary purple
        secondary: Color(0xFF8B5CF6), // Secondary purple
        tertiary: Color(0xFF06B6D4), // Accent cyan
        surface: Color(0xFF1E293B), // Main background - dark slate
        background: Color(0xFF0F172A), // Deep dark slate for overall background
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: Color(0xFFEF4444), // Red for errors
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
          displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
          headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.9)),
          bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.7)),
          labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white), // For buttons
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B), // Dark slate, slightly lighter than deep background
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, // Icons should be light
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B), // Dark slate
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 1), // Slightly lighter border
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1), // Primary purple
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF8B5CF6), // Secondary purple for text buttons
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF475569)), // Medium slate border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A), // Deep dark input background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1), // Darker border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5), // Primary purple focus
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)), // Lighter grey for hint
        labelStyle: GoogleFonts.inter(color: const Color(0xFFE5E7EB)), // Even lighter for label
        errorStyle: GoogleFonts.inter(color: const Color(0xFFEF4444)), // Red for errors
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F172A), // Deep dark background
        selectedItemColor: Color(0xFF6366F1), // Primary purple
        unselectedItemColor: Color(0xFF9CA3AF), // Medium grey
        type: BottomNavigationBarType.fixed,
        elevation: 0, // No shadow, modern look
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4, // Reduced elevation
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6366F1),
        linearTrackColor: Color(0xFF334155), // Darker track
        circularTrackColor: Color(0xFF334155), // Darker track
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: Color(0xFF334155), thickness: 1), // Darker divider

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF334155), // Darker chip background
        selectedColor: const Color(0xFF6366F1), // Primary purple
        labelStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        side: BorderSide.none,
        showCheckmark: false,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E293B), // Dark slate for dialogs
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8)),
      ),

      // Cupertino Overrides (Optional but good for consistency if using Cupertino widgets)
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF6366F1), // Primary purple
        primaryContrastingColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFF0F172A), // Deep dark background
        barBackgroundColor: Color(0xFF1E293B), // Dark slate for nav bars
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF6366F1), // For interactive elements like buttons
          textStyle: TextStyle(color: Colors.white),
          // ... other text styles if needed
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6366F1), // Primary purple
        secondary: const Color(0xFF8B5CF6), // Secondary purple
        tertiary: const Color(0xFF06B6D4), // Accent cyan
        surface: const Color(0xFFFFFFFF), // White background for surfaces like cards
        background: const Color(0xFFF0F2F5), // Light grey for overall background
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.white, // Text on secondary color
        onSurface: const Color(0xFF1F2937), // Dark text on surfaces
        onBackground: const Color(0xFF1F2937), // Dark text on background
        error: const Color(0xFFD32F2F), // Red for errors
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
          displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
          headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
          headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)),
          bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF374151)),
          bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF4B5563)),
          labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white), // For buttons
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF), // White app bar
        elevation: 1, // Slight elevation for separation
        shadowColor: const Color(0xFFE5E7EB), // Light shadow
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Icons should be dark
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
        iconTheme: const IconThemeData(color: Color(0xFF4B5563)), // Darker icons
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF), // White cards
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1), // Light grey border
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1), // Primary purple
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF5B21B6), // Darker purple for text buttons in light mode
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1), // Primary purple
          side: const BorderSide(color: Color(0xFFD1D5DB)), // Medium grey border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB), // Very light grey for input background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1), // Light grey border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5), // Primary purple focus
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)), // Medium grey for hint
        labelStyle: GoogleFonts.inter(color: const Color(0xFF374151)), // Dark grey for label
        errorStyle: GoogleFonts.inter(color: const Color(0xFFD32F2F)), // Red for errors
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF), // White background
        selectedItemColor: const Color(0xFF6366F1), // Primary purple
        unselectedItemColor: const Color(0xFF6B7280), // Medium grey
        type: BottomNavigationBarType.fixed,
        elevation: 2, // Slight elevation for separation
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(0xFF6366F1),
        linearTrackColor: const Color(0xFFE5E7EB), // Light grey track
        circularTrackColor: const Color(0xFFE5E7EB), // Light grey track
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1), // Light grey divider

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE5E7EB), // Light grey chip background
        selectedColor: const Color(0xFF6366F1), // Primary purple
        labelStyle: GoogleFonts.inter(color: const Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        side: const BorderSide(color: Color(0xFFD1D5DB)), // Light border for unselected chips
        showCheckmark: false,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFFFFFFF), // White dialogs
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151)),
      ),

      // Cupertino Overrides (Optional but good for consistency if using Cupertino widgets)
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF6366F1), // Primary purple
        primaryContrastingColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFF0F2F5), // Light grey background
        barBackgroundColor: Color(0xFFFFFFFF), // White nav bars
         textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF6366F1), // For interactive elements like buttons
          textStyle: TextStyle(color: Color(0xFF1F2937)), // Dark text
          // ... other text styles if needed
        ),
      ),
    );
  }
}
