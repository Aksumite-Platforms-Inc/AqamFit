import 'package:flutter/material.dart';

class CoachCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onFollow;

  const CoachCard({super.key, required this.name, required this.imageUrl, required this.onFollow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: onFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: const Text('Follow'),
        )
      ],
    );
  }
}