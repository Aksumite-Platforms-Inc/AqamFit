import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axum_app/features/home/home_screen.dart';
import 'package:axum_app/features/explore/explore_screen.dart';
import 'package:axum_app/features/workout/workout_screen.dart';
import 'package:axum_app/features/progress/progress_screen.dart'; // Re-added ProgressScreen import
import 'package:axum_app/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:axum_app/features/social/presentation/screens/social_screen.dart';
import 'package:axum_app/features/profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
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
          WorkoutScreen(),
          ProgressScreen(), // Added ProgressScreen
          NutritionScreen(),
          SocialScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // No need to call setState here as CupertinoTabBar handles its own state.
          // However, we still need to update the PageView.
          _pageController.jumpToPage(index);
          // Optionally, if you want to keep track of the index in _MainScaffoldState:
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: CupertinoColors.inactiveGray,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sportscourt),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square), // Progress Icon
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.leaf_arrow_circlepath),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_3),
            label: 'Social',
          ),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_crop_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
