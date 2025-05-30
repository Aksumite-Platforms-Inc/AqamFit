import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileMenuOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlighted;

  const ProfileMenuOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFFFFD700).withOpacity(0.1) // Gold for highlighted
                : const Color(0xFF1E88E5).withOpacity(0.1), // Default blue
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(CupertinoIcons.right_chevron, color: Colors.grey[400]),
    final ThemeData theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xFFFFD700).withOpacity(0.1) // Gold for highlighted
                      : const Color(0xFF1E88E5).withOpacity(0.1), // Default blue
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF1E88E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16, // Consider using theme.textTheme.bodyLarge?.fontSize
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500, // Consider theme.textTheme.bodyLarge?.fontWeight
                  color: isHighlighted ? const Color(0xFFFFD700) : theme.colorScheme.onSurface, // Use theme color
                ),
              ),
              const Spacer(),
              Icon(CupertinoIcons.right_chevron, color: CupertinoColors.tertiarySystemFill),
            ],
          ),
        ),
      ),
    );
  }
}
