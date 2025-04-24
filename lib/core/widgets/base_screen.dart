import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final bool showBackButton;

  const BaseScreen({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: showBackButton,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }
}
