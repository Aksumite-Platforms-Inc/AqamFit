import 'package:flutter/material.dart';

class SuggestedUsersCard extends StatelessWidget {
  const SuggestedUsersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Suggested Users", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _suggestedUser("Maxim", "https://picsum.photos/seed/maxim/100"),
            const SizedBox(width: 12),
            _suggestedUser("Toji", "https://picsum.photos/seed/toji/100"),
          ],
        )
      ],
    );
  }

  Widget _suggestedUser(String name, String imageUrl) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(radius: 36, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              backgroundColor: Colors.blue,
            ),
            child: const Text("Follow"),
          )
        ],
      ),
    );
  }
}
