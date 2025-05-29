import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // For Timer if needed, though AnimationController is primary

class ExerciseTimerWidget extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onTimerComplete;

  const ExerciseTimerWidget({
    super.key,
    required this.durationInSeconds,
    required this.onTimerComplete,
  });

  @override
  State<ExerciseTimerWidget> createState() => _ExerciseTimerWidgetState();
}

class _ExerciseTimerWidgetState extends State<ExerciseTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ValueNotifier<int> _remainingSeconds;
  bool _timerCompletedCalled = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = ValueNotifier<int>(widget.durationInSeconds);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );

    _controller.addListener(() {
      if (mounted) { // Ensure widget is still in the tree
        final newRemaining = (_controller.duration!.inSeconds * (1 - _controller.value)).round();
        if (_remainingSeconds.value != newRemaining) {
          _remainingSeconds.value = newRemaining;
        }
        if (_controller.status == AnimationStatus.completed && !_timerCompletedCalled) {
          _timerCompletedCalled = true;
          widget.onTimerComplete();
        }
      }
    });

    if (widget.durationInSeconds > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ExerciseTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.durationInSeconds != oldWidget.durationInSeconds) {
      _timerCompletedCalled = false; // Reset completion flag
      _controller.duration = Duration(seconds: widget.durationInSeconds);
      _remainingSeconds.value = widget.durationInSeconds;
      if (widget.durationInSeconds > 0) {
        _controller.reset();
        _controller.forward();
      } else {
        _controller.stop(); // Stop if duration is 0
      }
      setState(() {}); // To update play/pause icon if needed
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _remainingSeconds.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _togglePlayPause() {
    if (!mounted) return;
    setState(() {
      if (_controller.isAnimating) {
        _controller.stop();
      } else {
        if (_controller.status == AnimationStatus.completed) {
           _resetTimer(); // If completed, pressing play should reset and start
        } else {
          _controller.forward();
        }
      }
    });
  }

  void _resetTimer() {
    if (!mounted) return;
    _timerCompletedCalled = false;
    _controller.reset();
    if (widget.durationInSeconds > 0) {
       _controller.forward();
    }
    setState(() {}); // Update UI, especially play/pause icon
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    if (widget.durationInSeconds <= 0) {
      // Optionally display something different for rep-based exercises or 0 duration
      return Text(
        "Rep-based exercise",
        style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                backgroundColor: theme.colorScheme.surfaceVariant,
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    strokeCap: StrokeCap.round, // Make ends rounded
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: _remainingSeconds,
                builder: (context, value, child) {
                  return Text(
                    _formatTime(value),
                    style: GoogleFonts.inter( // Using GoogleFonts for consistency
                      fontSize: textTheme.headlineLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center buttons
          children: [
            IconButton(
              icon: Icon(_controller.isAnimating ? Icons.pause_circle_filled_outlined : Icons.play_circle_filled_outlined),
              onPressed: _togglePlayPause,
              iconSize: 40,
              color: theme.colorScheme.primary, // Theme color for icons
            ),
            const SizedBox(width: 20), // Spacing between buttons
            IconButton(
              icon: const Icon(Icons.replay_rounded),
              onPressed: _resetTimer,
              iconSize: 40,
              color: theme.colorScheme.secondary, // Theme color for icons
            ),
          ],
        ),
      ],
    );
  }
}
