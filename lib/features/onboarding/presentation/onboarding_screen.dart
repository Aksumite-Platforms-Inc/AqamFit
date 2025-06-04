import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/services/settings_service.dart';
import '../../../models/onboarding_page.dart'; // Adjusted path

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Updated content for AxumFit
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: CupertinoIcons.flame_fill, // Screen 1 Icon
      title: 'AI-Powered Fitness', // Screen 1 Title
      description: 'Personalized plans based on your goals and progress.', // Screen 1 Desc
    ),
    OnboardingPage(
      icon: CupertinoIcons.cart_fill, // Screen 2 Icon (replaced food_fork_drink_fill)
      title: 'Smart Meal Tracking', // Screen 2 Title
      description: 'Snap your meals, track calories, and stay on top of your diet.', // Screen 2 Desc
    ),
    OnboardingPage(
      icon: CupertinoIcons.star_fill, // Screen 3 Icon
      title: 'Stay Motivated', // Screen 3 Title
      description: 'Social challenges, rewards, and expert support.', // Screen 3 Desc
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    Future<bool> _onWillPop() async {
      if (_pageController.page?.round() != 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        return false; // Prevent app from exiting
      }
      // If on the first page, show exit confirmation dialog
      return (await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit AksumFit?'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay in app
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Exit app
              child: const Text('Exit'),
            ),
          ],
        ),
      )) ?? false; // Default to false if dialog is dismissed
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorScheme.surface, // Use theme background
        body: Stack( // Wrap SafeArea with Stack for Skip button
          children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double factor = 1.0;
                      if (_pageController.position.hasContentDimensions) {
                        // Calculate the difference between the current page and the item's index
                        // Use _pageController.page for a double value representing current scroll position
                        double page = _pageController.page ?? _currentPage.toDouble();
                        factor = (page - index).abs();
                      }

                      // Apply scale and opacity based on the factor
                      // Scale down and fade out pages that are not in focus
                      // Clamp factor to avoid over-scaling/fading if using non-clamped page value
                      final double scaleFactor = (1 - (factor.clamp(0.0, 1.0) * 0.25)).toDouble(); // e.g. scale down to 75%
                      final double opacityFactor = (1 - (factor.clamp(0.0, 1.0) * 0.5)).toDouble(); // e.g. fade to 50%

                      return Opacity(
                        opacity: opacityFactor,
                        child: Transform.scale(
                          scale: scaleFactor,
                          child: child,
                        ),
                      );
                    },
                    child: OnboardingPageWidget(page: _pages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary // Use theme primary color
                              : theme.colorScheme.onSurface.withOpacity(0.3), // Use theme surface/variant
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // More rounded
                        ),
                        elevation: 5.0, // Add elevation
                      ),
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          Provider.of<SettingsService>(context, listen: false).setHasCompletedOnboarding(true);
                          context.go('/register'); // Navigate to Register Screen
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
          ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: TextButton(
              onPressed: () {
                Provider.of<SettingsService>(context, listen: false).setHasCompletedOnboarding(true);
                context.go('/register');
              },
              child: Text('Skip', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for styling

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.5), // Theme-aware background
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon, // This comes from the _pages list
              size: 80,
              color: theme.colorScheme.primary, // Theme-aware icon color
            ),
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
