import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      // Navigate to the login screen after splash
      context.go('/login');
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration( // Use theme colors for gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withBlue(theme.colorScheme.surface.blue + 20), // Darker shade of surface
              theme.colorScheme.surface,
              theme.colorScheme.surface.withBlue(theme.colorScheme.surface.blue - 20), // Lighter shade of surface
            ],
          ),
        ),
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
                          gradient: LinearGradient( // Use theme primary and secondary for logo gradient
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.7), // Shadow from theme primary
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon( // Icon color from theme
                          CupertinoIcons.heart_fill,
                          size: 60,
                          color: theme.colorScheme.onPrimary,
                        ),
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
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient( // Use theme colors for text gradient
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary, theme.colorScheme.tertiary],
                        ).createShader(bounds),
                        child: Text(
                          'AxumFit',
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onPrimary, // This color is masked by ShaderMask
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'AI Powered Fitness',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.7), // Use onSurface from theme
                          letterSpacing: 2,
                        ),
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
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator( // Use theme for progress indicator
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing your fitness journey...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.54), // Use onSurface from theme
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
