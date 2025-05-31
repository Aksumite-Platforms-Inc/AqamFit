import 'package:aksumfit/features/explore/explore_screen.dart';
import 'package:aksumfit/features/home/home_screen.dart';
import 'package:aksumfit/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:aksumfit/features/profile/profile_screen.dart';
import 'package:aksumfit/features/progress/progress_screen.dart'; // Re-added ProgressScreen import
import 'package:aksumfit/features/social/presentation/screens/social_screen.dart';
import 'package:aksumfit/features/workout/presentation/screens/workout_plans_screen.dart'; // Changed import
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  MainScaffoldState createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Updated PageView children to 5 tabs
        children: const [
          HomeScreen(),
          WorkoutPlansScreen(), // Assuming this is the intended 'Workout' tab screen
          NutritionScreen(),
          SocialScreen(),     // Assuming this is the intended 'Community' tab screen
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          // setState(() { // Already handled by onPageChanged
          //   _currentIndex = index;
          // });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant, // For better theme adaptation
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible for 5 items
        // Updated BottomNavigationBar items to 5 tabs
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), // Changed icon
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
