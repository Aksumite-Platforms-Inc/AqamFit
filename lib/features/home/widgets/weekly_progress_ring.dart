import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class WeeklyProgressRing extends StatefulWidget {
  final String title;
  final double currentProgress;
  final double goal;
  final Color primaryColor;
  final Color backgroundColor;

  const WeeklyProgressRing({
    super.key,
    required this.title,
    required this.currentProgress,
    required this.goal,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  State<WeeklyProgressRing> createState() => _WeeklyProgressRingState();
}

class _WeeklyProgressRingState extends State<WeeklyProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAnimatedValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    final double targetValue = widget.goal == 0 ? 0 : widget.currentProgress / widget.goal;
    _animation = Tween<double>(begin: _currentAnimatedValue, end: targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          // The AnimatedBuilder will use _animation.value directly
        });
      });

    _controller.forward(from: 0.0);
    _currentAnimatedValue = targetValue; // Store for next update
  }

  @override
  void didUpdateWidget(WeeklyProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentProgress != oldWidget.currentProgress || widget.goal != oldWidget.goal) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      // Using theme's cardTheme for color and shape
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Track
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: widget.backgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.backgroundColor.withOpacity(0.5)), // Or just widget.backgroundColor
                  ),
                  // Foreground Progress
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(0)..rotateZ(-math.pi / 2), // Rotate to start from top
                        child: CircularProgressIndicator(
                          value: _animation.value,
                          strokeWidth: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                          backgroundColor: Colors.transparent,
                          strokeCap: StrokeCap.round, // Rounded ends
                        ),
                      );
                    },
                  ),
                  // Center Text
                  Text(
                    "${widget.currentProgress.toInt()}/${widget.goal.toInt()}",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
