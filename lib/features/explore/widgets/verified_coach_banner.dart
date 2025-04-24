import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifiedCoachBanner extends StatelessWidget {
  const VerifiedCoachBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Become a Verified Lyfta Coach', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('It’s easy to get started as a coach and get extra clients.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/coach/apply'),
            child: const Text('Apply'),
          )
        ],
      ),
    );
  }
}