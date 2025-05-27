import 'package:flutter/material.dart';

class HomeProgressItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const HomeProgressItem({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
