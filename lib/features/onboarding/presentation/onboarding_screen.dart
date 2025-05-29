import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      icon: Icons.smart_toy_outlined, // Updated icon
      title: 'Personalized AI Workouts', // Updated title
      description:
          'Intelligent workout plans tailored to your goals and progress.', // Updated description
      // color field will be ignored as per instructions
    ),
    OnboardingPage(
      icon: Icons.analytics_outlined, // Updated icon
      title: 'Track Your Journey', // Updated title
      description:
          'Log meals, monitor body metrics, and see your strength grow with detailed analytics.', // Updated description
      // color field will be ignored
    ),
    OnboardingPage(
      icon: Icons.emoji_events_outlined, // Updated icon
      title: 'Stay Motivated', // Updated title
      description:
          'Join challenges, earn badges, and connect with the AxumFit community.', // Updated description
      // color field will be ignored
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background
      body: SafeArea(
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
                  return OnboardingPageWidget(page: _pages[index]);
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
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? colorScheme.primary // Use theme primary color
                              : colorScheme.surface.withOpacity(0.5), // Use theme surface color
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // Button style will be inherited from ElevatedButtonThemeData in main.dart
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/main'); // Navigate using GoRouter
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        // Text style will be inherited from ElevatedButtonThemeData
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
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              // Use theme colors instead of page.color
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: colorScheme.primary, // Use theme primary color for icon
            ),
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            textAlign: TextAlign.center,
            // Use GoogleFonts.inter and styles from theme
            style: textTheme.headlineMedium?.copyWith(color: colorScheme.onBackground),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            // Use GoogleFonts.inter and styles from theme
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
