import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/settings_service.dart';

// Remove OnboardingScreen import if it's not used after navigation change
// import 'package:aksumfit/screens/onboarding_screen.dart'; // This might be the old path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();

    // Navigate to next screen after animations
    // Total animation time is roughly 300 + 200 + 300 + (longest of 1500, 1200, 1000) = 800 + 1500 = 2300ms
    // Adding a small delay for user to perceive the full animation.
    await Future.delayed(const Duration(milliseconds: 700)); // Adjusted delay

    if (mounted) {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      final settingsService = Provider.of<SettingsService>(context, listen: false);

      final bool isLoggedIn = authManager.isLoggedIn; // Use correct getter
      final bool hasCompletedOnboarding = settingsService.hasCompletedOnboarding;

      if (isLoggedIn) {
        context.go('/main');
      } else {
        if (hasCompletedOnboarding) {
          context.go('/login');
        } else {
          context.go('/onboarding');
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the gradient background
    const BoxDecoration gradientBackground = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF0F172A), // Deep blue (dark slate 900)
          Color(0xFF1E293B), // Mid blue (dark slate 800)
          Color(0xFF3B82F6), // Lighter blue (blue 500) - for a touch of "health-tech"
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
      ),
    );

    return Scaffold(
      body: CupertinoPageScaffold(
        // backgroundColor: CupertinoColors.systemGroupedBackground, // Replaced by Container with gradient
        child: Container( // Wrap with Container for gradient
          decoration: gradientBackground,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              CupertinoColors.activeBlue,
                              CupertinoColors.activeGreen
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.activeBlue.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        // child: const Icon(
                        //   CupertinoIcons.heart_fill, // Replaced
                        //   size: 60,
                        //   color: CupertinoColors.white,
                        // ),
                        child: const FlutterLogo(size: 60), // Placeholder logo
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App Name Animation
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'AxumFit',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navLargeTitleTextStyle
                            .copyWith(
                                color: CupertinoColors.white, // Adjusted for dark background
                                fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The Future of Personalized Fitness', // Changed tagline
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                                color: CupertinoColors.systemGrey2, // Adjusted for dark background
                                letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Loading Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const CupertinoActivityIndicator(radius: 15),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing your fitness journey...',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .tabLabelTextStyle
                          .copyWith(color: CupertinoColors.systemGrey3), // Adjusted for dark background
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
