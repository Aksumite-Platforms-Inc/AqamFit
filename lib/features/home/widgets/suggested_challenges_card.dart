import 'package:flutter/material.dart';

class SuggestedChallengesCard extends StatelessWidget {
  const SuggestedChallengesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Suggested Challenges", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("April Lift 50k", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Lift a total of 50,000kg in April", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Join"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
