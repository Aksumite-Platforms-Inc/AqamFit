import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const WorkoutCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: const CircleAvatar(
        backgroundImage: NetworkImage('https://via.placeholder.com/40x40.png?text=W'),
      ),
      title: Text(title),
      subtitle: const Text('By Workout Inspiration'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}