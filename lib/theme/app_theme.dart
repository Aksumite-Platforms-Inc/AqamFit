import 'package:flutter/material.dart';

class AppTheme {
  // --- Colors ---
  // Primary colors for a light theme
  static const Color primaryColor = Color(0xFF0D47A1); // A deep blue
  static const Color primaryColorLight = Color(0xFF1E88E5); // A lighter blue
  static const Color primaryColorDark = Color(0xFF0D47A1); // A darker blue for contrast if needed

  // Accent colors
  static const Color accentColor = Color(0xFF4CAF50); // A vibrant green for CTAs
  static const Color secondaryAccentColor = Color(0xFFFFC107); // A warm yellow/gold for secondary elements

  // Background and Text colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey for background
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Color(0xFF212121); // Dark grey for text (almost black)
  static const Color secondaryTextColor = Color(0xFF757575); // Medium grey for less important text

  // Ethiopian cultural accent color placeholder
  // This color can be used for specific highlights, icons, or decorative elements
  // that reflect Ethiopian cultural aesthetics (e.g., traditional textiles, art).
  static const Color culturalAccentColor = Color(0xFFD4AF37); // Example: A muted gold/bronze

  // --- Typography ---
  // Using system fonts for now. Custom fonts can be integrated later.
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: textColor),
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: textColor),
    headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: textColor),
    titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: textColor),
    titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: textColor),
    titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: textColor),
    bodyLarge: TextStyle(fontSize: 16.0, color: textColor, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14.0, color: secondaryTextColor, height: 1.5),
    bodySmall: TextStyle(fontSize: 12.0, color: secondaryTextColor, height: 1.4),
    labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.white), // For buttons
    labelMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: textColor),
    labelSmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: secondaryTextColor),
  );

  // --- Component Themes ---

  static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white, // Text color for ElevatedButton
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: textTheme.labelLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // More rounded corners
      elevation: 2,
    ),
  );

  static final CardTheme cardTheme = CardTheme(
    color: cardBackgroundColor,
    elevation: 1.0, // Subtle shadow
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Consistent margins
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded corners
      // Cultural patterns could be used as subtle background textures on cards or screens.
      // Example: side: BorderSide(color: culturalAccentColor.withOpacity(0.2)),
    ),
  );

  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.8),
    hintStyle: textTheme.bodyMedium?.copyWith(color: secondaryTextColor.withOpacity(0.7)),
    labelStyle: textTheme.bodyMedium?.copyWith(color: primaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: accentColor, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.redAccent, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  );

  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: backgroundColor, // Light background for app bar
    foregroundColor: textColor,       // Dark text/icons on app bar
    elevation: 0,                     // No shadow for a flatter look
    iconTheme: IconThemeData(color: primaryColorLight),
    titleTextStyle: textTheme.titleLarge?.copyWith(color: textColor),
    // Iconography could incorporate Ethiopian symbols or art styles for specific actions.
  );

  static final BottomNavigationBarThemeData bottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: secondaryTextColor.withOpacity(0.7),
    selectedLabelStyle: textTheme.labelSmall?.copyWith(color: primaryColor),
    unselectedLabelStyle: textTheme.labelSmall?.copyWith(color: secondaryTextColor.withOpacity(0.7)),
    type: BottomNavigationBarType.fixed, // Fixed type for 3-5 items
    elevation: 2.0, // Subtle shadow
    // A specific cultural accent color can be used for decorative elements or special highlights.
  );

  // --- Main Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorLight: primaryColorLight,
      primaryColorDark: primaryColorDark,
      scaffoldBackgroundColor: backgroundColor,
      // Using ColorScheme.fromSeed for a good base and then customizing
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
        surface: cardBackgroundColor,
        onSurface: textColor,
      ).copyWith(
        // Further customize specific scheme colors if needed
        // For example, the cultural accent can be introduced here if it has a semantic role
        // tertiary: culturalAccentColor,
        // onTertiary: Colors.black, // Or an appropriate contrasting color
      ),
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
      appBarTheme: appBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      iconTheme: IconThemeData(color: primaryColorLight, size: 24.0),
      // --- Comments on Cultural Integration ---
      // 1. Cultural patterns could be used as subtle background textures on cards or screens.
      //    (Example shown in CardTheme's borderSide)
      // 2. Iconography could incorporate Ethiopian symbols or art styles.
      //    (Consider for specific actions or bottom navigation items if appropriate)
      // 3. A specific cultural accent color (culturalAccentColor) can be used for decorative
      //    elements, special highlights, or even important but non-CTA actions.
      //    (Example placeholder defined, can be used in widget styling)
      // 4. Typography: If culturally significant fonts are identified, they can be integrated
      //    into the textTheme. For now, system fonts are used for broad compatibility.
    );
  }
}
