import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F172A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const AxumFitApp());
}

class AxumFitApp extends StatelessWidget {
  const AxumFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AxumFit - AI Powered Fitness',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1), // Primary purple
        secondary: Color(0xFF8B5CF6), // Secondary purple
        tertiary: Color(0xFF06B6D4), // Accent cyan
        surface: Color(0xFF1E293B), // Card background
        background: Color(0xFF0F172A), // Main background
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600, // Updated
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600, // Updated
            color: Colors.white,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600, // Updated
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500, // Updated
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.9), // Updated
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.7), // Updated
          ),
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Updated
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
        elevation: 0, // Updated
        shadowColor: Colors.transparent, // Updated
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Updated
          side: const BorderSide(color: Color(0xFF475569), width: 0.5), // Updated
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0, // Updated
          shadowColor: Colors.transparent, // Updated
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Updated
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Updated
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Updated
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E), // Updated
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Updated
          borderSide: BorderSide.none, // Updated
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Updated
          borderSide: const BorderSide(color: Color(0xFF545458), width: 0.5), // Updated
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Updated
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5), // Updated
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]), // Updated
        labelStyle: GoogleFonts.inter(color: Colors.grey[400]), // Updated
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF6366F1),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6366F1),
        linearTrackColor: Color(0xFF334155),
        circularTrackColor: Color(0xFF334155),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF545458), // Updated
        thickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2E), // Updated
        selectedColor: const Color(0xFF6366F1),
        labelStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500), // Updated
        secondaryLabelStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), // Updated
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Updated
        side: BorderSide.none,
        showCheckmark: false,
      ),
    );
  }
}
