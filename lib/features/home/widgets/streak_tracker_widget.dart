import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakTrackerWidget extends StatefulWidget {
  final int streakCount;

  const StreakTrackerWidget({super.key, required this.streakCount});

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
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate( // Reduced scale slightly
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Play animation only if streak is active
    if (widget.streakCount > 0) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StreakTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakCount != oldWidget.streakCount) {
      if (widget.streakCount > 0 && !_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      } else if (widget.streakCount == 0 && _animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset(); // Reset to initial scale
      }
    }
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
    const double cardBorderRadius = 12.0; // Define for consistency

    return Card(
      clipBehavior: Clip.antiAlias, // Ensures content respects card's shape
      shape: RoundedRectangleBorder( // Ensure Card shape is defined if not default
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      child: Stack(
        children: [
          // Layer 1: Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cardBorderRadius),
              child: Image.asset(
                'assets/images/streak_background.png', // Path to your image
                fit: BoxFit.cover,
                // Optional: Add errorBuilder for placeholder if image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported)));
                },
              ),
            ),
          ),
          // Layer 2: Semi-transparent Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cardBorderRadius),
              child: Container(
                color: Colors.black.withOpacity(0.4), // Adjust opacity as needed
              ),
            ),
          ),
          // Layer 3: Content
          Padding(
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
                        color: Colors.orangeAccent, // Changed for better visibility
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Current Streak",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // Changed for better visibility
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "${widget.streakCount} Day${widget.streakCount == 1 ? '' : 's'}",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed for better visibility (or a light primary shade)
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.streakCount > 0 ? "Keep the fire alive!" : "Log a workout to start a streak!",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85), // Changed for better visibility
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
