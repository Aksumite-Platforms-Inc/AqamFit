import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardListItem extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardListItem({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser =
        entry.name == 'You'; // Assuming 'You' identifies the current user

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: entry.rank <= 3
                  ? (entry.rank == 1
                      ? const Color(0xFFFFD700) // Gold
                      : entry.rank == 2
                          ? const Color(0xFFC0C0C0) // Silver
                          : const Color(0xFFCD7F32)) // Bronze
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: entry.rank <= 3 ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            // AssetImage could be used here if avatar paths are valid
            // For simplicity, using the first letter as in original code
            child: Text(
              entry.name.isNotEmpty ? entry.name[0] : '?',
              style: const TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? const Color(0xFF1E88E5) : const Color(0xFF2D3748),
              ),
            ),
          ),
          Text(
            '${entry.points} pts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
