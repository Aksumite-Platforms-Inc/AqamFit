import 'package:aksumfit/models/goal.dart';
import 'package:aksumfit/models/weight_entry.dart';
import 'package:aksumfit/services/api_service.dart';
import 'package:aksumfit/services/auth_manager.dart';
// import 'package:aksumfit/features/progress/widgets/line_chart_widget_placeholder.dart'; // Will replace
// import 'package:aksumfit/features/progress/widgets/radar_chart_widget_placeholder.dart'; // Will replace
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _userId;
  Future<List<WeightEntry>>? _weightEntriesFuture;
  Future<List<Goal>>? _goalsFuture;

  // Chart time range selection
  TimeRange _selectedTimeRange = TimeRange.threeMonths;

  @override
  void initState() {
    super.initState();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    _userId = authManager.currentUser?.id;
    if (_userId != null) {
      _loadData();
    }
  }

  void _loadData() {
    if (_userId == null) return;
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedTimeRange) {
      case TimeRange.oneMonth:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimeRange.threeMonths:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case TimeRange.sixMonths:
        startDate = now.subtract(const Duration(days: 180));
        break;
      case TimeRange.allTime:
      default:
        startDate = DateTime(2000); // A very early date for all time
        break;
    }
    setState(() {
      _weightEntriesFuture = ApiService().getWeightEntries(_userId!, startDate: startDate, endDate: now);
      _goalsFuture = ApiService().getGoals(_userId!, isActive: true); // Load active goals
    });
  }

  Future<void> _showLogWeightDialog({WeightEntry? entryToEdit}) async {
    final weightController = TextEditingController(text: entryToEdit?.weightKg.toString() ?? '');
    final notesController = TextEditingController(text: entryToEdit?.notes ?? '');
    DateTime selectedDate = entryToEdit?.date ?? DateTime.now();
    final bool isEditing = entryToEdit != null;

    if (_userId == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: Text(isEditing ? "Edit Weight Entry" : "Log New Weight"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Date: ${DateFormat.yMd().format(selectedDate)}"),
                    trailing: const Icon(CupertinoIcons.calendar),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedDate) {
                        stfSetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Weight (kg)", prefixIcon: Icon(CupertinoIcons.gauge)),
                    autofocus: true,
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes (optional)", prefixIcon: Icon(CupertinoIcons.text_bubble)),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  final weight = double.tryParse(weightController.text);
                  if (weight == null || weight <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text("Please enter a valid weight.")));
                    return;
                  }
                  final newEntry = WeightEntry(
                    id: entryToEdit?.id ?? _uuid.v4(),
                    userId: _userId!,
                    date: selectedDate,
                    weightKg: weight,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );
                  try {
                    await ApiService().saveWeightEntry(newEntry);
                    Navigator.of(dialogContext).pop(true);
                  } catch (e) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text("Error saving entry: $e")));
                  }
                },
                child: Text(isEditing ? "Update" : "Save"),
              ),
            ],
          );
        });
      },
    );

    if (result == true) {
      _loadData(); // Refresh charts and data
    }
  }

  Future<void> _showSetGoalDialog({Goal? existingGoal}) async {
    if (_userId == null) return;
    final bool isEditing = existingGoal != null;

    final nameController = TextEditingController(text: existingGoal?.name ?? '');
    GoalMetricType selectedMetricType = existingGoal?.metricType ?? GoalMetricType.weight;
    final exerciseNameController = TextEditingController(text: existingGoal?.exerciseName ?? '');
    final targetValueController = TextEditingController(text: existingGoal?.targetValue.toString() ?? '');
    final startValueController = TextEditingController(text: existingGoal?.startValue.toString() ?? '');
    final unitController = TextEditingController(text: existingGoal?.metricUnit ?? _getUnitForMetricType(selectedMetricType));
    DateTime? targetDate = existingGoal?.targetDate;

    if (!isEditing && _userId != null) {
        try {
            if (selectedMetricType == GoalMetricType.weight && _weightEntriesFuture != null) {
                final weights = await _weightEntriesFuture;
                if (weights != null && weights.isNotEmpty) {
                    startValueController.text = weights.first.weightKg.toString();
                } else {
                  startValueController.text = '';
                }
            }
        } catch(e) {
            if (kDebugMode) print("Error prefilling start value for goal: $e");
            startValueController.text = '';
        }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Goal" : "Set New Goal"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Goal Name", hintText: "e.g., Lose 5kg, Bench 100kg")),
                    DropdownButtonFormField<GoalMetricType>(
                      value: selectedMetricType,
                      decoration: const InputDecoration(labelText: "Metric to Track"),
                      items: GoalMetricType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last.capitalize()),
                      )).toList(),
                      onChanged: (GoalMetricType? newValue) {
                        if (newValue != null) {
                          stfSetState(() {
                            selectedMetricType = newValue;
                            unitController.text = _getUnitForMetricType(newValue);
                            if (newValue != GoalMetricType.exerciseMaxWeight &&
                                newValue != GoalMetricType.exerciseMaxReps &&
                                newValue != GoalMetricType.exerciseFastestTime) {
                              exerciseNameController.clear();
                            }
                          });
                        }
                      },
                    ),
                    if (selectedMetricType == GoalMetricType.exerciseMaxWeight ||
                        selectedMetricType == GoalMetricType.exerciseMaxReps ||
                        selectedMetricType == GoalMetricType.exerciseFastestTime)
                      TextField(controller: exerciseNameController, decoration: const InputDecoration(labelText: "Exercise Name (if applicable)")),

                    TextField(controller: startValueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Starting Value")),
                    TextField(controller: targetValueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Value")),
                    TextField(controller: unitController, decoration: const InputDecoration(labelText: "Unit (e.g., kg, %, reps)")),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Target Date: ${targetDate == null ? 'Optional' : DateFormat.yMd().format(targetDate!)}"),
                      trailing: const Icon(CupertinoIcons.calendar),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          stfSetState(() { targetDate = picked; });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final target = double.tryParse(targetValueController.text);
                    final start = double.tryParse(startValueController.text);

                    if (name.isEmpty || target == null || start == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text("Please fill all required fields correctly.")));
                      return;
                    }

                    final newGoal = Goal(
                      id: existingGoal?.id ?? _uuid.v4(),
                      userId: _userId!,
                      name: name,
                      metricType: selectedMetricType,
                      exerciseName: exerciseNameController.text.isNotEmpty &&
                                    (selectedMetricType == GoalMetricType.exerciseMaxWeight ||
                                     selectedMetricType == GoalMetricType.exerciseMaxReps ||
                                     selectedMetricType == GoalMetricType.exerciseFastestTime)
                                  ? exerciseNameController.text
                                  : null,
                      metricUnit: unitController.text.isNotEmpty ? unitController.text : null,
                      targetValue: target,
                      startValue: start,
                      currentValue: existingGoal?.currentValue ?? start,
                      startDate: existingGoal?.startDate ?? DateTime.now(),
                      targetDate: targetDate,
                      isActive: existingGoal?.isActive ?? true,
                      createdAt: existingGoal?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    try {
                      await ApiService().saveGoal(newGoal);
                      Navigator.of(dialogContext).pop(true);
                    } catch (e) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text("Error saving goal: $e")));
                    }
                  },
                  child: Text(isEditing ? "Update Goal" : "Set Goal"),
                ),
              ],
            );
          },
        );
      },
    );
     if (result == true) {
      _loadData();
    }
  }

  String _getUnitForMetricType(GoalMetricType type) {
    switch (type) {
      case GoalMetricType.weight: return "kg";
      case GoalMetricType.bodyFatPercentage: return "%";
      case GoalMetricType.muscleMass: return "kg";
      case GoalMetricType.waistCircumference: return "cm";
      case GoalMetricType.exerciseMaxWeight: return "kg";
      case GoalMetricType.exerciseMaxReps: return "reps";
      case GoalMetricType.exerciseFastestTime: return "seconds";
      case GoalMetricType.workoutFrequency: return "workouts/week";
      default: return "";
    }
  }

  // TODO: Implement _showLogBodyMeasurementDialog, _showLogPerformanceMetricDialog similar to _showLogWeightDialog

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Tracking", style: GoogleFonts.inter(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: _userId == null
          ? const Center(child: Text("Please login to track progress."))
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Time Range Selector for Charts
                  _buildTimeRangeSelector(theme),
                  const SizedBox(height: 20),

                  // Weight Chart Section
                  Text("Weight Progress", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: FutureBuilder<List<WeightEntry>>(
                      future: _weightEntriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.colorScheme.error)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text("No weight data logged for this period.", style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)),
                          );
                        }
                        return WeightLineChart(weightEntries: snapshot.data!);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text("Log Weight"),
                      onPressed: () => _showLogWeightDialog(),
                    ),
                  ),
                  const Divider(height: 30),

                  // Goals Section (Basic)
                  Text("Active Goals", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _buildGoalsSection(theme),
                  const SizedBox(height: 10),
                   Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text("Set New Goal"),
                      onPressed: () => _showSetGoalDialog(),
                    ),
                  ),
                  const Divider(height: 30),

                  // Placeholder for Body Measurements Chart
                  Text("Body Measurements", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(height: 150, color: theme.colorScheme.surfaceContainerHighest, child: Center(child: Text("Body Measurement Chart Placeholder", style: GoogleFonts.inter()))),
                   Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text("Log Measurements"),
                      onPressed: () { /* TODO: _showLogBodyMeasurementDialog(); */ },
                    ),
                  ),
                  const Divider(height: 30),

                  // Placeholder for Performance Metrics
                  Text("Performance Metrics", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(height: 150, color: theme.colorScheme.surfaceContainerHighest, child: Center(child: Text("Performance Metrics Placeholder", style: GoogleFonts.inter()))),
                   Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(CupertinoIcons.add_circled),
                      label: const Text("Log Performance"),
                      onPressed: () { /* TODO: _showLogPerformanceMetricDialog(); */ },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return SegmentedButton<TimeRange>(
      segments: TimeRange.values.map((range) => ButtonSegment(
          value: range,
          label: Text(range.displayName, style: GoogleFonts.inter(fontSize: 12)),
          // icon: Icon(range.icon) // Optional icon
      )).toList(),
      selected: {_selectedTimeRange},
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedTimeRange = newSelection.first;
          _loadData();
        });
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: theme.colorScheme.primaryContainer,
        selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Adjust padding
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildGoalsSection(ThemeData theme) {
    return FutureBuilder<List<Goal>>(
      future: _goalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) return Center(child: Text("Error loading goals.", style: TextStyle(color: theme.colorScheme.error)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No active goals set yet.", style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)));
        }
        final goals = snapshot.data!;
        return Column(
          children: goals.map((goal) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Target: ${goal.targetValue.toStringAsFixed(1)} ${goal.metricUnit ?? ''}", style: theme.textTheme.bodySmall),
                  Text("Current: ${goal.currentValue.toStringAsFixed(1)} ${goal.metricUnit ?? ''}", style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: goal.progressPercentage,
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${(goal.progressPercentage * 100).toStringAsFixed(0)}%", style: theme.textTheme.labelSmall),
                  )
                ],
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}

// Enum for chart time ranges
enum TimeRange { oneMonth, threeMonths, sixMonths, allTime }

extension TimeRangeExtension on TimeRange {
  String get displayName {
    switch (this) {
      case TimeRange.oneMonth: return "1M";
      case TimeRange.threeMonths: return "3M";
      case TimeRange.sixMonths: return "6M";
      case TimeRange.allTime: return "All";
    }
  }
}


// Simple Line Chart for Weight Entries using fl_chart
class WeightLineChart extends StatelessWidget {
  final List<WeightEntry> weightEntries;

  const WeightLineChart({super.key, required this.weightEntries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (weightEntries.length < 2) { // FLChart needs at least 2 points for a line
        return Center(child: Text("Not enough data to draw a chart. Log at least two weight entries.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant)));
    }

    List<FlSpot> spots = weightEntries.map((entry) {
      // Convert date to a double value, e.g., millisecondsSinceEpoch or daysSinceEpoch
      // For simplicity, using days since the first entry for X-axis to show progression
      final firstDate = weightEntries.last.date; // Entries are sorted descending by date
      final daysSinceFirst = entry.date.difference(firstDate).inDays.toDouble();
      return FlSpot(daysSinceFirst, entry.weightKg);
    }).toList();

    // Sort spots by X value (date) as FLChart expects them in order
    spots.sort((a,b) => a.x.compareTo(b.x));

    // Determine min/max X and Y for chart boundaries
    double minX = spots.first.x;
    double maxX = spots.last.x;
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2; // Add some padding
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2; // Add some padding

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5 > 0 ? (maxY - minY) / 5 : 1, // Adjust interval
          verticalInterval: (maxX - minX) / 5 > 0 ? (maxX-minX) / 5 : 1, // Adjust interval
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor.withOpacity(0.3), strokeWidth: 0.5),
          getDrawingVerticalLine: (value) => FlLine(color: theme.dividerColor.withOpacity(0.3), strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: (maxY - minY) / 5 > 0 ? (maxY - minY) / 5 : 1, getTitlesWidget: leftTitleWidgets)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: (maxX - minX) / 5 > 0 ? (maxX-minX) / 5 : 1, getTitlesWidget: bottomTitleWidgets)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: theme.dividerColor, width: 1)),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
        ],
        lineTouchData: LineTouchData(
             touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: theme.colorScheme.primaryContainer,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    // Find original entry to show date
                    // This is tricky because X is daysSinceFirst. Need to map back or store original date with spot.
                    // For now, just show Y value.
                    return LineTooltipItem(
                        '${flSpot.y.toStringAsFixed(1)} kg',
                        TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                }
            )
        )
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return Text(value.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.left);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // Convert 'daysSinceFirst' back to a date for display - this is a simplification
    // In a real app, you'd map X values to actual dates more robustly.
    final firstDate = weightEntries.last.date;
    final displayDate = firstDate.add(Duration(days: value.toInt()));
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(DateFormat('d MMM').format(displayDate), style: GoogleFonts.inter(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
