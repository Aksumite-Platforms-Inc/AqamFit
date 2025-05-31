import 'package:flutter/cupertino.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notifications'),
      ),
      child: Center(
        child: Text(
          'Notifications Screen',
          style: cupertinoTheme.textTheme.navTitleTextStyle
              .copyWith(color: CupertinoColors.label),
        ),
      ),
    );
  }
}
