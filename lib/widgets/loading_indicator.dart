import 'package:flutter/material.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Image.asset('assets/images/logo.png'), // Assuming logo.png is in assets/images/
      ),
    );
  }
}
