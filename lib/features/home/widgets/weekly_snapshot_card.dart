import 'package:flutter/material.dart';

class WeeklySnapshotCard extends StatelessWidget {
  const WeeklySnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FB), // Light blue background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Your weekly snapshot',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'See more',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _SnapshotStat(
                value: '0',
                label: 'Workouts',
                icon: Icons.fitness_center,
              ),
              _SnapshotStat(
                value: '0min',
                label: 'Duration',
                icon: Icons.access_time,
              ),
              _SnapshotStat(
                value: '0kg',
                label: 'Volume',
                icon: Icons.fitness_center_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _SnapshotStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.black45),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
