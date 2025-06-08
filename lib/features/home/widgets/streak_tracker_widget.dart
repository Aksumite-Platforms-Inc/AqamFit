import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
      } else if (widget.streakCount == 0) {
        _animationController.stop();
        _animationController.reset();
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
    final theme = Theme.of(context);
    const double radius = 20;

    return GestureDetector(
      onTap: () => context.go('/streak-details'), // Navigation link updated
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.streakCount > 0
                  ? [Colors.deepOrangeAccent, Colors.amberAccent]
                  : [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Icon(
                          CupertinoIcons.flame_fill,
                          color: widget.streakCount > 0
                              ? Colors.white
                              : Colors.grey.shade500,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${widget.streakCount} Day${widget.streakCount == 1 ? '' : 's'}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      widget.streakCount > 0
                          ? "You’ve worked out ${widget.streakCount} day${widget.streakCount == 1 ? '' : 's'} in a row"
                          : "Log a workout to start tracking streaks!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.streakCount > 0)
                ...List.generate(6, (index) {
                  final double size = Random().nextDouble() * 3 + 3;
                  return Positioned(
                    top: Random().nextDouble() * 80 + 20,
                    left: Random().nextDouble() * 120 + 20,
                    child: _SparkWidget(
                      size: size,
                      color: index.isEven
                          ? Colors.amberAccent
                          : Colors.orangeAccent.withOpacity(0.8),
                      delay: Duration(milliseconds: index * 300),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparkWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration delay;

  const _SparkWidget({
    required this.size,
    required this.color,
    required this.delay,
  });

  @override
  State<_SparkWidget> createState() => _SparkWidgetState();
}

class _SparkWidgetState extends State<_SparkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _movement;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 0.6),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.2),
    ]).animate(_controller);

    _movement = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -widget.size * 1.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _movement,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
