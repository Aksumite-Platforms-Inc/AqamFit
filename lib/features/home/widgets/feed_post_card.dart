import 'package:flutter/material.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Evening session", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage("https://picsum.photos/300"), // Placeholder
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Icon(Icons.timer, size: 18, color: Colors.grey),
            SizedBox(width: 4),
            Text("34min", style: TextStyle(fontSize: 13)),
            SizedBox(width: 12),
            Icon(Icons.monitor_weight, size: 18, color: Colors.grey),
            SizedBox(width: 4),
            Text("3,547.09 kg", style: TextStyle(fontSize: 13)),
            Spacer(),
            Icon(Icons.emoji_events_outlined, color: Colors.orange),
            SizedBox(width: 4),
            Text("27", style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
