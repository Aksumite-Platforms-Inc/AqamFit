import 'package:flutter/material.dart';

class ActivityFeedItem extends StatelessWidget {
  final String activity;
  final String time;
  final IconData icon;

  const ActivityFeedItem({
    Key? key,
    required this.activity,
    required this.time,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF9C27B0)
                  .withOpacity(0.1), // Example color from SocialScreen
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                Icon(icon, color: Color(0xFF9C27B0), size: 20), // Example color
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
