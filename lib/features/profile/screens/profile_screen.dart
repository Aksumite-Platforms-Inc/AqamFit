import 'package:flutter/material.dart';
import '../../../core/widgets/base_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/workout_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Profile',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
      ],
      body: ListView(children: const [ProfileHeader(), WorkoutStats()]),
    );
  }
}
