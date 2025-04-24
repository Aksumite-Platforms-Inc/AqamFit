import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  final int index;
  const BottomNav({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/workout'); break;
          case 1: context.go('/diet'); break;
          case 2: context.go('/progress'); break;
          case 3: context.go('/social'); break;
          case 4: context.go('/trainer'); break;
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Trainer'),
      ],
    );
  }
}
