import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aksumfit/services/auth_manager.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/workout_log.dart';
import 'package:aksumfit/models/personal_record.dart';
import 'package:aksumfit/core/extensions/string_extensions.dart'; // For capitalize
import 'package:intl/intl.dart'; // For date formatting

// Helper function to format duration
String formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
  } else {
    return "${duration.inMinutes}m";
  }
}

class DetailedProgressScreen extends StatefulWidget {
  const DetailedProgressScreen({super.key});

  @override
  State<DetailedProgressScreen> createState() => _DetailedProgressScreenState();
}

class _DetailedProgressScreenState extends State<DetailedProgressScreen> {
  String? _userId;
  List<Goal> _activeGoals = [];
  List<Goal> _pastGoals = [];
  bool _isLoadingGoals = true;
  String? _goalsError;

  List<Map<String, dynamic>> _monthlyProgressData = [];
  bool _isLoadingMonthlyProgress = true;
  String? _monthlyProgressError;

  List<PersonalRecord> _personalRecords = [];
  bool _isLoadingPRs = true;
  String? _prError;

  Map<String, dynamic> _otherMetrics = {};
  bool _isLoadingOtherMetrics = true;
  String? _otherMetricsError;


  @override
  void initState() {
    super.initState();
    _userId = Provider.of<AuthManager>(context, listen: false).currentUser?.id;
    if (_userId != null) {
      _fetchGoals();
      _fetchMonthlyProgress();
      _fetchPersonalRecords();
      _fetchOtherPerformanceMetrics(); // Call new method
    } else {
      setState(() {
        _isLoadingGoals = false;
        _goalsError = "User not logged in.";
        _isLoadingMonthlyProgress = false;
        _monthlyProgressError = "User not logged in.";
        _isLoadingPRs = false;
        _prError = "User not logged in.";
        _isLoadingOtherMetrics = false;
        _otherMetricsError = "User not logged in.";
      });
    }
  }

  Future<void> _fetchGoals() async {
    if (_userId == null) return;
    setState(() { _isLoadingGoals = true; _goalsError = null; });
    try {
      final active = await ApiService().getGoals(userId: _userId!, isActive: true);
      final past = await ApiService().getGoals(userId: _userId!, isActive: false);
      if (mounted) setState(() { _activeGoals = active; _pastGoals = past; _isLoadingGoals = false; });
    } catch (e) {
      if (mounted) setState(() { _goalsError = "Error fetching goals: ${e.toString()}"; _isLoadingGoals = false; });
    }
  }

  Future<void> _fetchMonthlyProgress() async {
    if (_userId == null) return;
    setState(() { _isLoadingMonthlyProgress = true; _monthlyProgressError = null; });
    try {
      final logs = await ApiService().getWorkoutLogs(userId: _userId!, startDate: DateTime.now().subtract(const Duration(days: 365)), endDate: DateTime.now());
      Map<String, Map<String, dynamic>> monthlyDataAggregator = {};
      for (var log in logs) {
        final monthYearKey = DateFormat('MMMM yyyy').format(log.startTime);
        final duration = log.endTime.difference(log.startTime);
        if (monthlyDataAggregator.containsKey(monthYearKey)) {
          monthlyDataAggregator[monthYearKey]!['workouts'] += 1;
          monthlyDataAggregator[monthYearKey]!['totalDuration'] += duration;
        } else {
          monthlyDataAggregator[monthYearKey] = {
            'monthYear': monthYearKey, 'workouts': 1, 'totalDuration': duration,
            'dateForSort': DateTime(log.startTime.year, log.startTime.month, 1),
          };
        }
      }
      List<Map<String, dynamic>> processedDataList = monthlyDataAggregator.values.toList();
      processedDataList.sort((a, b) => (b['dateForSort'] as DateTime).compareTo(a['dateForSort'] as DateTime));
      if (mounted) setState(() { _monthlyProgressData = processedDataList; _isLoadingMonthlyProgress = false; });
    } catch (e) {
      if (mounted) setState(() { _monthlyProgressError = "Error fetching monthly progress: ${e.toString()}"; _isLoadingMonthlyProgress = false; });
    }
  }

  Future<void> _fetchPersonalRecords() async {
    if (_userId == null) return;
    setState(() { _isLoadingPRs = true; _prError = null; });
    try {
      final records = await ApiService().getPersonalRecords(userId: _userId!);
      records.sort((a, b) => b.dateAchieved.compareTo(a.dateAchieved));
      if (mounted) setState(() { _personalRecords = records; _isLoadingPRs = false; });
    } catch (e) {
      if (mounted) setState(() { _prError = "Error fetching PRs: ${e.toString()}"; _isLoadingPRs = false; });
    }
  }

  Future<void> _fetchOtherPerformanceMetrics() async {
    if (_userId == null) return;
    setState(() { _isLoadingOtherMetrics = true; _otherMetricsError = null; });
    try {
      final logs = await ApiService().getWorkoutLogs(
        userId: _userId!,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      int totalWorkoutsLast30d = logs.length;
      Duration totalDurationLast30d = logs.fold(Duration.zero, (prev, log) => prev + log.endTime.difference(log.startTime));
      // Assuming caloriesBurned is nullable in WorkoutLog and defaulting to 0 if null
      int totalCaloriesBurnedLast30d = logs.fold(0, (prev, log) => prev + (log.caloriesBurned ?? 0));

      if (mounted) {
        setState(() {
          _otherMetrics = {
            'totalWorkouts': totalWorkoutsLast30d,
            'totalDuration': totalDurationLast30d,
            'totalCalories': totalCaloriesBurnedLast30d,
          };
          _isLoadingOtherMetrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _otherMetricsError = "Error fetching other metrics: ${e.toString()}";
          _isLoadingOtherMetrics = false;
        });
      }
    }
  }


  Widget _buildGoalItem(Goal goal, ThemeData theme, {bool isPastGoal = false}) {
    final progress = goal.progressPercentage;
    final targetDateFormatted = goal.targetDate != null ? DateFormat.yMd().format(goal.targetDate!) : 'N/A';
    return Opacity(opacity: isPastGoal ? 0.7 : 1.0, child: Card(elevation: isPastGoal ? 1 : 2, margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, decoration: isPastGoal && !goal.isAchieved ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 4),
            Text("Target: ${goal.targetValue.toStringAsFixed(1)} ${goal.metricUnit ?? ''} by $targetDateFormatted", style: theme.textTheme.bodySmall),
            Text("Current: ${goal.currentValue.toStringAsFixed(1)} ${goal.metricUnit ?? ''} (Started: ${goal.startValue.toStringAsFixed(1)})", style: theme.textTheme.bodySmall),
            if (!isPastGoal || goal.isAchieved) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(value: progress, backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(goal.isAchieved ? Colors.green : (isPastGoal ? Colors.grey : theme.colorScheme.primary)),
                  minHeight: 8, borderRadius: BorderRadius.circular(4)),
              Align(alignment: Alignment.centerRight, child: Text("${(progress * 100).toStringAsFixed(0)}% ${goal.isAchieved ? '(Achieved!)' : (isPastGoal ? '(Not Achieved)' : '')}",
                  style: theme.textTheme.labelSmall?.copyWith(color: goal.isAchieved ? Colors.green : (isPastGoal ? Colors.grey : theme.textTheme.labelSmall?.color)))),
            ] else if (isPastGoal && !goal.isAchieved) ...[
              const SizedBox(height: 6), Text("Not Achieved", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.error)),
            ]
    ]))));
  }

  Widget _buildMonthlyProgressItem(Map<String, dynamic> monthData, ThemeData theme) {
    final String monthYear = monthData['monthYear'];
    final int workouts = monthData['workouts'];
    final Duration totalDuration = monthData['totalDuration'];
    return ListTile(title: Text(monthYear, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text("$workouts workouts, Total duration: ${formatDuration(totalDuration)}"), dense: true);
  }

  Widget _buildPersonalRecordItem(PersonalRecord pr, ThemeData theme) {
    return ListTile(
      title: Text("${pr.exerciseName} - ${pr.recordType}", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text("${pr.value} (Achieved: ${DateFormat.yMd().format(pr.dateAchieved)})"),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Detailed Progress")),
      body: ListView(padding: const EdgeInsets.all(16.0), children: <Widget>[
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(leading: const Icon(Icons.calendar_month_outlined), title: Text("Monthly Progress", style: theme.textTheme.titleLarge), contentPadding: EdgeInsets.zero),
              const SizedBox(height: 8),
              if (_isLoadingMonthlyProgress) const Center(child: CircularProgressIndicator())
              else if (_monthlyProgressError != null) Center(child: Text(_monthlyProgressError!, style: TextStyle(color: theme.colorScheme.error)))
              else if (_monthlyProgressData.isEmpty) const Center(child: Text("No monthly workout data available."))
              else Column(children: _monthlyProgressData.map((data) => _buildMonthlyProgressItem(data, theme)).toList()),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(leading: const Icon(Icons.flag_outlined), title: Text("Goal Tracking", style: theme.textTheme.titleLarge), contentPadding: EdgeInsets.zero),
              const SizedBox(height: 8),
              if (_isLoadingGoals) const Center(child: CircularProgressIndicator())
              else if (_goalsError != null) Center(child: Text(_goalsError!, style: TextStyle(color: theme.colorScheme.error)))
              else if (_activeGoals.isEmpty && _pastGoals.isEmpty) const Center(child: Text("No goals set yet."))
              else ...[
                  Text("Active Goals", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  if (_activeGoals.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text("No active goals."))
                  else Column(children: _activeGoals.map((goal) => _buildGoalItem(goal, theme)).toList()),
                  const SizedBox(height: 16),
                  Text("Past Goals", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  if (_pastGoals.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text("No past goals found."))
                  else Column(children: _pastGoals.map((goal) => _buildGoalItem(goal, theme, isPastGoal: true)).toList()),
              ],
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(leading: const Icon(Icons.star_outline_rounded), title: Text("Personal Records (PRs)", style: theme.textTheme.titleLarge), contentPadding: EdgeInsets.zero),
              const SizedBox(height: 8),
              if (_isLoadingPRs) const Center(child: CircularProgressIndicator())
              else if (_prError != null) Center(child: Text(_prError!, style: TextStyle(color: theme.colorScheme.error)))
              else if (_personalRecords.isEmpty) const Center(child: Text("No personal records logged yet."))
              else Column(children: _personalRecords.map((pr) => _buildPersonalRecordItem(pr, theme)).toList()),
          ]))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(leading: const Icon(Icons.insights_rounded), title: Text("Other Performance Metrics", style: theme.textTheme.titleLarge), contentPadding: EdgeInsets.zero),
            const SizedBox(height: 8),
            if (_isLoadingOtherMetrics) const Center(child: CircularProgressIndicator())
            else if (_otherMetricsError != null) Center(child: Text(_otherMetricsError!, style: TextStyle(color: theme.colorScheme.error)))
            else if (_otherMetrics.isEmpty || (_otherMetrics['totalWorkouts'] == 0 && _otherMetrics['totalDuration'] == Duration.zero && _otherMetrics['totalCalories'] == 0) )
                const Center(child: Text("Not enough data for other metrics (last 30 days)."))
            else
              Column(children: [
                ListTile(title: const Text("Workouts (Last 30 Days)"), trailing: Text(_otherMetrics['totalWorkouts'].toString()), dense: true),
                ListTile(title: const Text("Active Time (Last 30 Days)"), trailing: Text(formatDuration(_otherMetrics['totalDuration'] as Duration)), dense: true),
                ListTile(title: const Text("Est. Calories Burned (Last 30 Days)"), trailing: Text("${_otherMetrics['totalCalories']} kcal"), dense: true),
              ]),
          ]))),
          const SizedBox(height: 12),
          const Card(child: ListTile(leading: Icon(Icons.accessibility_new_rounded), title: Text("Body Measurement Trends"), subtitle: Text("Changes in weight, body fat, etc."), trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16))),
      ]),
    );
  }
}
