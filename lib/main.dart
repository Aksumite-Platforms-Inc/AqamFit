import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aksumfit/navigation/app_router.dart';
import 'package:aksumfit/services/api_service.dart'; // Import ApiService
import 'package:aksumfit/services/settings_service.dart'; // Import SettingsService
import 'package:aksumfit/services/auth_manager.dart'; // Import AuthManager
import 'package:aksumfit/repositories/user_repository.dart'; // Import UserRepository
import 'package:provider/provider.dart'; // Import Provider
import 'package:aksumfit/widgets/loading_indicator.dart'; // Import LoadingIndicatorWidget
import 'features/onboarding/presentation/setup_flow/setup_flow_viewmodel.dart'; // Import SetupFlowViewModel

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services before running the app
  final apiService = ApiService(); // Use the instance
  apiService.initialize();

  final settingsService = SettingsService();
  await settingsService.loadSettings();

  final userRepository = UserRepository(apiService: apiService); // Create UserRepository

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
        Provider<ApiService>.value(value: apiService), // Provide ApiService
        Provider<UserRepository>.value(value: userRepository), // Provide UserRepository
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => AuthManager()), // AuthManager might internally use ApiService singleton or could be refactored to take it
        ChangeNotifierProvider(create: (_) => SetupFlowViewModel()),
      ],
      child: const AxumFitApp(),
    ),
  );
}

class AxumFitApp extends StatefulWidget {
  const AxumFitApp({super.key});

  @override
  State<AxumFitApp> createState() => _AxumFitAppState();
}

class _AxumFitAppState extends State<AxumFitApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Set _isLoading to false after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Future<void> _initializeApp() async { // Removed this method
  //   // Initialize services
  //   // ApiService().initialize(); // Moved to main()
  //   // await context.read<SettingsService>().loadSettings(); // Moved to main()
  //
  //   // Simulate other initializations if necessary
  //   // await Future.delayed(const Duration(seconds: 2)); // Example delay
  //
  //   // if (mounted) {
  //   //   setState(() {
  //   //     _isLoading = false;
  //   //   });
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Assuming LoadingIndicatorWidget includes its own Scaffold
      return const LoadingIndicatorWidget();
    }

    // Listen to SettingsService for theme changes
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        // Update System UI Overlay based on current theme
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: settingsService.themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: settingsService.themeMode == ThemeMode.light ? const Color(0xFFF0F2F5) : const Color(0xFF0F172A),
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
        surface: Color(0xFF1E293B), // Deep dark slate for overall background
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
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
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1), // Primary purple
        secondary: Color(0xFF8B5CF6), // Secondary purple
        tertiary: Color(0xFF06B6D4), // Accent cyan
        surface: Color(0xFFFFFFFF), // Light grey for overall background
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.white, // Text on secondary color
        onSurface: Color(0xFF1F2937), // Dark text on background
        error: Color(0xFFD32F2F), // Red for errors
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF), // White background
        selectedItemColor: Color(0xFF6366F1), // Primary purple
        unselectedItemColor: Color(0xFF6B7280), // Medium grey
        type: BottomNavigationBarType.fixed,
        elevation: 2, // Slight elevation for separation
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6366F1),
        linearTrackColor: Color(0xFFE5E7EB), // Light grey track
        circularTrackColor: Color(0xFFE5E7EB), // Light grey track
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
