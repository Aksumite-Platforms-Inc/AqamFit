import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../models/onboarding_page.dart';
// Removed: import 'main_screen.dart'; // For navigation - Handled by GoRouter

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;

  List<OnboardingPage> pages = [
    OnboardingPage(
      icon: Icons.psychology,
      title: 'AI-Powered Workouts',
      description:
          'Get personalized workout plans that adapt to your progress and goals',
      color: Color(0xFF1E88E5),
    ),
    OnboardingPage(
      icon: Icons.restaurant,
      title: 'Smart Nutrition Tracking',
      description: 'AI recognizes your food and tracks macros automatically',
      color: Color(0xFF43A047),
    ),
    OnboardingPage(
      icon: Icons.people,
      title: 'Social & Gamified',
      description: 'Compete with friends, earn badges, and stay motivated',
      color: Color(0xFFFF7043),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return OnboardingPageWidget(page: pages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? Color(0xFF1E88E5)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentPage == pages.length - 1) {
                        // Navigate to main screen using GoRouter
                        context.go('/main');
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentPage == pages.length - 1 ? 'Get Started' : 'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Icon(page.icon, size: 80, color: page.color),
          ),
          SizedBox(height: 50),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
