import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

class StreakTrackerWidget extends StatefulWidget {
  final int streakCount;

  const StreakTrackerWidget({super.key, required this.streakCount});

  @override
  State<StreakTrackerWidget> createState() => _StreakTrackerWidgetState();
}

class _StreakTrackerWidgetState extends State<StreakTrackerWidget> {
  // AnimationController and ScaleAnimation are removed as Lottie will handle its own animation.
  // If specific control over Lottie playback is needed (e.g., start/stop based on streak),
  // an AnimationController for Lottie can be added here.

  @override
  void initState() {
    super.initState();
    // If you need to control Lottie animation (e.g. play once, then stop)
    // you might initialize a Lottie controller here.
    // For a simple looping flame, Lottie's default behavior might be sufficient.
  }

  @override
  void didUpdateWidget(covariant StreakTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Logic related to _animationController is removed.
    // If Lottie animation needs to change based on streakCount, add logic here.
  }

  @override
  void dispose() {
    // Dispose Lottie controller if it was initialized.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    // final TextTheme textTheme = theme.textTheme; // Kept for potential future use
    const double cardBorderRadius = 12.0;

    String subtitleText;
    if (widget.streakCount > 0) {
      subtitleText =
          "You’ve worked out ${widget.streakCount} days in a row – Keep the fire burning!";
    } else {
      subtitleText = "Log a workout to start a streak!";
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      // Consider adding a subtle background color to the card if needed,
      // e.g., color: colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            Lottie.asset(
              'assets/lottie/flame_animation.json',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              // controller: _lottieController, // Add if you need specific Lottie animation control
              // repeat: true, // Ensure it loops, Lottie might do this by default
            ),
            const SizedBox(height: 12),
            Text(
              "Current Streak", // This title can remain or be removed if Lottie is self-explanatory
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface, // Adjusted for card background
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.streakCount} Day${widget.streakCount == 1 ? '' : 's'}",
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Use primary color for emphasis
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              textAlign: TextAlign.center, // Ensure subtitle is centered
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant, // Adjusted for card background
              ),
            ),
          ],
        ),
      ),
    );
  }
}
