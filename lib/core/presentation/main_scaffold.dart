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
        children: const [
          HomeScreen(),
          ExploreScreen(),
          WorkoutPlansScreen(), // Changed to WorkoutPlansScreen
          ProgressScreen(), // Added ProgressScreen
          NutritionScreen(),
          SocialScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart), // Progress Icon
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Social',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
