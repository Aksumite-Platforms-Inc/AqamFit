import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: colorScheme.onPrimary, // Or onBackground if AppBar is transparent
          ),
        ),
        backgroundColor: colorScheme.primary, // Or theme.appBarTheme.backgroundColor
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Or theme.appBarTheme.iconTheme
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Notifications",
              style: GoogleFonts.inter(color: colorScheme.onSurface),
            ),
            leading: Icon(CupertinoIcons.bell, color: colorScheme.secondary),
            onTap: () {
              // TODO: Navigate to Notification Settings
              print("Notifications tapped");
            },
          ),
          ListTile(
            title: Text(
              "Account & Privacy",
              style: GoogleFonts.inter(color: colorScheme.onSurface),
            ),
            leading: Icon(CupertinoIcons.shield_lefthalf_fill, color: colorScheme.secondary),
            onTap: () {
              // TODO: Navigate to Account & Privacy Settings
              print("Account & Privacy tapped");
            },
          ),
          ListTile(
            title: Text(
              "App Appearance",
              style: GoogleFonts.inter(color: colorScheme.onSurface),
            ),
            leading: Icon(CupertinoIcons.slider_horizontal_3, color: colorScheme.secondary),
            onTap: () {
              // TODO: Navigate to App Appearance Settings
              print("App Appearance tapped");
            },
          ),
        ],
      ),
    );
  }
}
