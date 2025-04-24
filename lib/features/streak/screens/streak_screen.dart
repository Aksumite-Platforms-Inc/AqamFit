import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime focusedDay = DateTime.utc(2025, 4, 1);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("Streak"),
        actions: const [
          Icon(Icons.share_outlined, size: 24),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              Text(
                "1",
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                "week streak!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Icon(Icons.local_fire_department, color: Colors.orange, size: 56),
            ],
          ),
          const SizedBox(height: 16),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.local_fire_department, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You’ve kept a Workout Streak for 1 week. Keep it up!",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("Streak Calendar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Calendar
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 4, 1),
              lastDay: DateTime.utc(2025, 4, 30),
              focusedDay: focusedDay,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  shape: BoxShape.circle,
                ),
              ),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
            ),
          ),

          const SizedBox(height: 30),
          const Text("Streak Challenge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Streak challenge tracker
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: 1 / 3,
                  color: Colors.orange,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _ChallengeDay(day: "1", isComplete: true),
                    _ChallengeDay(day: "2"),
                    _ChallengeDay(day: "3"),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("1/3 WEEKS", style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeDay extends StatelessWidget {
  final String day;
  final bool isComplete;

  const _ChallengeDay({required this.day, this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.calendar_today,
          color: isComplete ? Colors.orange : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isComplete ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}
