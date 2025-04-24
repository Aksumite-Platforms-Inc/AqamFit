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
