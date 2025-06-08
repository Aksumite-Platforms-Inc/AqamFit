import 'dart:math'; // For Random
import 'package:flutter/cupertino.dart'; // For CupertinoIcons (if used by _SparkWidget or flame)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateFormat

class StreakDetailScreen extends StatelessWidget {
  const StreakDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Details'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: ListView(
        children: [
          _StreakHeaderSection(
            streakDurationText: "10 days",
            isOnStreak: true,
          ),
          const SizedBox(height: 24),
          const _StreakCalendarWidget(),
          const SizedBox(height: 24),
          const _StreakChallengeBar(currentStreakDays: 10),
          const SizedBox(height: 24), // Spacing before new section
          const _InviteFriendsSection(), // Add the new section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0), // Adjust padding for final message
            child: Center(
              child: Text(
                'Keep pushing your limits!', // Updated final message
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Header Section Widget (existing code)
class _StreakHeaderSection extends StatefulWidget {
  final String streakDurationText;
  final bool isOnStreak;

  const _StreakHeaderSection({
    super.key,
    required this.streakDurationText,
    required this.isOnStreak,
  });

  @override
  State<_StreakHeaderSection> createState() => _StreakHeaderSectionState();
}

class _StreakHeaderSectionState extends State<_StreakHeaderSection>
    with TickerProviderStateMixin {

  late AnimationController _flameAnimationController;
  late Animation<double> _flameScaleAnimation;
  late Animation<double> _flameFadeAnimation;
  List<Widget> _sparkWidgets = [];

  @override
  void initState() {
    super.initState();
    _flameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _flameScaleAnimation = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _flameAnimationController, curve: Curves.easeInOut));
    _flameFadeAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _flameAnimationController, curve: Curves.easeInOut));

    if (widget.isOnStreak) {
      _flameAnimationController.repeat(reverse: true);
      _initializeSparks();
    }
  }

  void _initializeSparks() {
    if (_sparkWidgets.isNotEmpty && !widget.isOnStreak) {
      _sparkWidgets.clear();
      return;
    }
    if (_sparkWidgets.isEmpty && widget.isOnStreak) {
      for (int i = 0; i < 10; i++) {
        final double sparkSize = Random().nextDouble() * 3.5 + 3.5;
        final Duration initialDelay = Duration(milliseconds: Random().nextInt(1500));
        final Color sparkColor = Random().nextBool() ? Colors.amberAccent[100]! : Colors.orangeAccent[100]!.withOpacity(0.7);
        _sparkWidgets.add(
            _SparkWidget(
              key: ValueKey('spark_$i'),
              delay: initialDelay,
              size: sparkSize,
              color: sparkColor,
            )
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant _StreakHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnStreak != oldWidget.isOnStreak) {
      if (widget.isOnStreak) {
        _flameAnimationController.repeat(reverse: true);
        _initializeSparks();
        setState(() {});
      } else {
        _flameAnimationController.stop();
        _flameAnimationController.reset();
        _sparkWidgets.clear();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _flameAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget animatedFlameIcon = ScaleTransition(
      scale: _flameScaleAnimation,
      child: FadeTransition(
        opacity: _flameFadeAnimation,
        child: Icon(
          CupertinoIcons.flame_fill,
          color: Colors.deepOrangeAccent[200],
          size: 48,
        ),
      ),
    );

    List<Widget> stackChildren = [];
    if (widget.isOnStreak) {
      for (int i = 0; i < _sparkWidgets.length; i++) {
        stackChildren.add(
            Positioned(
              right: Random().nextDouble() * 60.0 + 0,
              top: Random().nextDouble() * 60.0 + 0,
              child: _sparkWidgets[i],
            )
        );
      }
    }

    Widget mainHeaderContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🔥 You're on a ${widget.streakDurationText} streak!",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Keep it up and unlock rewards!",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (widget.isOnStreak) animatedFlameIcon,
      ],
    );
    stackChildren.insert(0, mainHeaderContent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.red[500]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}

// SparkWidget Definition (existing code)
class _SparkWidget extends StatefulWidget {
  final Duration delay;
  final double size;
  final Color color;

  const _SparkWidget({
    super.key,
    required this.delay,
    required this.size,
    required this.color,
  });

  @override
  _SparkWidgetState createState() => _SparkWidgetState();
}

class _SparkWidgetState extends State<_SparkWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + Random().nextInt(400)),
      vsync: this,
    );
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 0.7),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.15),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(Random().nextDouble() * 4 - 2, -widget.size * (2.5 + Random().nextDouble() * 1.5)),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: widget.size / 2,
                      spreadRadius: widget.size / 4,
                    )
                  ]
              ),
            ),
          ),
        );
      },
    );
  }
}

// Streak Calendar Widget (existing code)
class _StreakCalendarWidget extends StatefulWidget {
  const _StreakCalendarWidget({super.key});

  @override
  State<_StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends State<_StreakCalendarWidget> {
  final List<Map<String, dynamic>> _calendarDays = [];
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _generateMockCalendarData();
  }

  void _generateMockCalendarData() {
    final random = Random();
    _calendarDays.clear();
    for (int i = 0; i < 30; i++) {
      DateTime date = _today.subtract(Duration(days: 29 - i));
      bool isStreak = random.nextDouble() < 0.6;
      _calendarDays.add({
        'date': date,
        'isStreakDay': isStreak,
        'isMissedDay': !isStreak && random.nextDouble() < 0.2,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Your Streak Journey",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 100.0,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _calendarDays.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, index) {
              final dayData = _calendarDays[index];
              bool isToday = DateUtils.isSameDay(dayData['date'], _today);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _DayPill(
                  date: dayData['date'],
                  isStreakDay: dayData['isStreakDay'],
                  isMissedDay: dayData['isMissedDay'],
                  isToday: isToday,
                  onTap: () {
                    print("Tapped on ${DateFormat.yMd().format(dayData['date'])}");
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayPill extends StatefulWidget {
  final DateTime date;
  final bool isStreakDay;
  final bool isMissedDay;
  final bool isToday;
  final VoidCallback onTap;

  const _DayPill({
    super.key,
    required this.date,
    required this.isStreakDay,
    required this.isMissedDay,
    required this.isToday,
    required this.onTap,
  });

  @override
  State<_DayPill> createState() => _DayPillState();
}

class _DayPillState extends State<_DayPill> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _animationController.forward().then((_) {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color pillColor;
    Color textColor;
    Border? border;

    if (widget.isStreakDay) {
      pillColor = Colors.amber[700]!;
      textColor = Colors.white;
    } else if (widget.isMissedDay) {
      pillColor = Colors.grey[400]!;
      textColor = Colors.white70;
    } else {
      pillColor = Colors.grey[200]!;
      textColor = Colors.black87;
    }

    if (widget.isToday) {
      border = Border.all(color: Theme.of(context).colorScheme.primary, width: 2.5);
    }

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(30),
              border: border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('E').format(widget.date).substring(0,3).toUpperCase(),
                style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                DateFormat('d').format(widget.date),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Data Structure for Challenge Stage --- (existing code)
class ChallengeStage {
  final String id;
  final String label;
  final int targetDays;
  bool isCompleted;
  bool isActive;

  ChallengeStage({
    required this.id,
    required this.label,
    required this.targetDays,
    this.isCompleted = false,
    this.isActive = false,
  });
}

// --- _StreakChallengeBar Widget --- (existing code)
class _StreakChallengeBar extends StatefulWidget {
  final int currentStreakDays;

  const _StreakChallengeBar({super.key, required this.currentStreakDays});

  @override
  State<_StreakChallengeBar> createState() => _StreakChallengeBarState();
}

class _StreakChallengeBarState extends State<_StreakChallengeBar> {
  List<ChallengeStage> _stages = [];

  @override
  void initState() {
    super.initState();
    _initializeStages();
  }

  @override
  void didUpdateWidget(covariant _StreakChallengeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStreakDays != oldWidget.currentStreakDays) {
      _initializeStages();
    }
  }

  void _initializeStages() {
    var definedStages = [
      ChallengeStage(id: '1', label: "1 Week", targetDays: 7),
      ChallengeStage(id: '2', label: "2 Weeks", targetDays: 14),
      ChallengeStage(id: '3', label: "1 Month", targetDays: 30),
    ];

    bool foundActive = false;
    for (var stage in definedStages) {
      stage.isCompleted = widget.currentStreakDays >= stage.targetDays;
      stage.isActive = false;
      if (!stage.isCompleted && !foundActive) {
        stage.isActive = true;
        foundActive = true;
      }
    }
    if (!foundActive && definedStages.isNotEmpty && definedStages.every((s) => s.isCompleted)) {
      definedStages.last.isActive = true;
    }
    setState(() {
      _stages = definedStages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Streak Challenges",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _stages.map((stage) {
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _ChallengeStageTile(
                    label: stage.label,
                    isCompleted: stage.isCompleted,
                    isActive: stage.isActive,
                    onTap: () {
                      print("Tapped on challenge: ${stage.label}");
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// --- _ChallengeStageTile Widget --- (existing code)
class _ChallengeStageTile extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback onTap;

  const _ChallengeStageTile({
    super.key,
    required this.label,
    required this.isCompleted,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color tileColor = Colors.grey[300]!;
    Color textColor = Colors.black54;
    IconData iconData = Icons.star_border_rounded;
    List<Color> gradientColors = [Colors.grey[300]!, Colors.grey[400]!];
    bool useGradient = false;
    double elevation = 2.0;
    Border? border;

    if (isCompleted) {
      gradientColors = [Colors.amber[600]!, Colors.orange[700]!];
      useGradient = true;
      textColor = Colors.white;
      iconData = Icons.check_circle_rounded;
      elevation = 3.0;
    } else if (isActive) {
      gradientColors = [Colors.orange[500]!, Colors.amber[600]!];
      useGradient = true;
      textColor = Colors.white;
      iconData = Icons.emoji_events_outlined; // Changed icon for active challenge stage
      elevation = 5.0;
      border = Border.all(color: Colors.white.withOpacity(0.7), width: 2);
    } else {
      elevation = 1.0;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            border: border,
            gradient: useGradient
                ? LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: useGradient ? null : tileColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: textColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- _InviteFriendsSection Widget ---
class _InviteFriendsSection extends StatefulWidget {
  const _InviteFriendsSection({super.key});

  @override
  State<_InviteFriendsSection> createState() => _InviteFriendsSectionState();
}

class _InviteFriendsSectionState extends State<_InviteFriendsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Consistent padding
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Slightly larger radius
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Increased padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  Icons.groups_3_rounded,
                  size: 60, // Slightly adjusted size
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20), // Increased spacing
              Text(
                "Double the Gains, Double the Fuel! 🚀",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith( // Used titleLarge for more impact
                  fontWeight: FontWeight.w600,
                  // color: theme.colorScheme.onSurface, // Default text color for cards
                ),
              ),
              const SizedBox(height: 24), // Increased spacing
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text("Invite Friends"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Adjusted padding
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 4.0, // Added elevation to button
                ),
                onPressed: () {
                  print("Invite Friends button tapped!");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
