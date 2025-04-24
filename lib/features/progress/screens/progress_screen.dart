import 'package:flutter/material.dart';
import '../../../core/widgets/base_screen.dart';
import '../widgets/progress_overview.dart';
import '../widgets/body_measurements.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BaseScreen(
        title: 'Progress',
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Exercises'),
                Tab(text: 'Measures'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ProgressOverview(),
                  const Center(child: Text('Exercises')),
                  const BodyMeasurements(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
