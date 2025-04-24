import 'package:flutter/material.dart';

class BodyMeasurements extends StatelessWidget {
  const BodyMeasurements({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MeasurementTile(
          icon: Icons.monitor_weight,
          title: 'Body weight',
          onTap: () {},
        ),
        _MeasurementTile(icon: Icons.percent, title: 'Body fat', onTap: () {}),
        _MeasurementTile(
          icon: Icons.fastfood,
          title: 'Calorie intake',
          onTap: () {},
        ),
        const Divider(height: 32),
        const Text(
          'Body Parts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _BodyPartTile(
          icon: 'assets/icons/neck.png',
          title: 'Neck',
          onTap: () {},
        ),
        _BodyPartTile(
          icon: 'assets/icons/chest.png',
          title: 'Chest',
          onTap: () {},
        ),
        // Add more body parts...
      ],
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MeasurementTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _BodyPartTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _BodyPartTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(icon, width: 24, height: 24),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
