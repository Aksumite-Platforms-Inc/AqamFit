import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakTrackerWidget extends StatefulWidget {
  const StreakTrackerWidget({super.key});

  @override
  State<StreakTrackerWidget> createState() => _StreakTrackerWidgetState();
}

class _StreakTrackerWidgetState extends State<StreakTrackerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Card(
      // Using theme's cardTheme for color and shape
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    CupertinoIcons.flame_fill,
                    color: colorScheme.tertiary, // Using theme color
                    size: 24, // Adjusted size
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Streak",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textTheme.titleLarge?.color, // Use theme text color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Increased spacing
            Text(
              "5 Days", // Placeholder
              style: GoogleFonts.inter(
                fontSize: 30, // Increased font size for prominence
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Use theme primary color
              ),
            ),
            const SizedBox(height: 6), // Increased spacing
            Text(
              "Keep it up!", // Placeholder
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textTheme.bodyMedium?.color?.withOpacity(0.7), // Use theme text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
