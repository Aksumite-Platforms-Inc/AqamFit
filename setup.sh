#!/bin/bash

# Variables
APP_NAME=aksumfit
ORG_NAME="com.aksumiteplatforms"


# 2. Create Flutter app in the repo
echo "🚧 Creating Flutter project..."
flutter create --project-name=$APP_NAME --org $ORG_NAME .

# 3. Add dependencies
echo "📦 Adding dependencies..."
flutter pub add provider go_router fl_chart flutter_svg table_calendar share_plus web_socket_channel

# 4. Create folder structure
mkdir -p lib/core/navigation lib/core/widgets lib/core/constants
mkdir -p lib/features/{auth,workout,diet,progress,social,trainer,notifications}/screens

# 5. Add GoRouter setup
cat > lib/core/navigation/app_router.dart <<EOF
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/diet/screens/diet_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/social/screens/social_screen.dart';
import '../../features/trainer/screens/trainer_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/workout',
  routes: [
    GoRoute(path: '/', redirect: (_) => '/workout'),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/workout', builder: (_, __) => const WorkoutScreen()),
    GoRoute(path: '/diet', builder: (_, __) => const DietScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/social', builder: (_, __) => const SocialScreen()),
    GoRoute(path: '/trainer', builder: (_, __) => const TrainerScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
  ],
);
EOF

# 6. Bottom Navigation Bar
cat > lib/core/widgets/bottom_nav.dart <<EOF
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  final int index;
  const BottomNav({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/workout'); break;
          case 1: context.go('/diet'); break;
          case 2: context.go('/progress'); break;
          case 3: context.go('/social'); break;
          case 4: context.go('/trainer'); break;
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Trainer'),
      ],
    );
  }
}
EOF

# 7. Sample screen generator with UI mock
generate_screen() {
  local name=$1
  local index=$2
  local capitalized="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"

  cat > lib/features/$name/screens/${name}_screen.dart <<EOF
import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav.dart';

class ${capitalized}Screen extends StatelessWidget {
  const ${capitalized}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$capitalized')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Welcome to the $capitalized screen!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Design Preview Card')),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(index: $index),
    );
  }
}
EOF
}

generate_screen login 0
generate_screen workout 0
generate_screen diet 1
generate_screen progress 2
generate_screen social 3
generate_screen trainer 4
generate_screen notifications 0

# 8. Update main.dart
cat > lib/main.dart <<EOF
import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(const AksumFitApp());
}

class AksumFitApp extends StatelessWidget {
  const AksumFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AksumFit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
EOF

# 9. README.md
cat > README.md <<EOF
# 🏋️ AksumFit

A cross-platform fitness app built with Flutter, following clean architecture and modern UI principles.

## ✨ Features

- **Workout Logging**
- **Diet Tracking**
- **Progress & Analytics**
- **Trainer Collaboration**
- **Social Gamification**
- **Notifications & Scheduling**

## 📦 Tech Stack

- Flutter 3.x
- Dart
- Provider (state management)
- GoRouter (navigation)
- FL Chart
- Table Calendar
- WebSocket Channel
- Flutter SVG

## 📁 Folder Structure

\`\`\`bash
lib/
├── core/
│   ├── navigation/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── workout/
│   ├── diet/
│   ├── progress/
│   ├── social/
│   ├── trainer/
│   └── notifications/
└── main.dart
\`\`\`

## 🚀 Run App

```bash
flutter pub get
flutter run

