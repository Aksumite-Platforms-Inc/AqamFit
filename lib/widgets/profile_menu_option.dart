import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileMenuOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlighted;

  const ProfileMenuOption({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isHighlighted
                ? Color(0xFFFFD700).withOpacity(0.1) // Gold for highlighted
                : Color(0xFF1E88E5).withOpacity(0.1), // Default blue
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? Color(0xFFFFD700) : Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? Color(0xFFFFD700) : Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(CupertinoIcons.right_chevron, color: Colors.grey[400]),
      ),
    );
  }
}
