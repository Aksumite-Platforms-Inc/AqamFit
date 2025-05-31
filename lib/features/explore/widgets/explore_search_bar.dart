import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: GoogleFonts.inter(color: theme.colorScheme.onSurface), // Use theme color
        decoration: InputDecoration(
          hintText: "Search workouts, articles, challenges...",
          // hintStyle will be inherited from theme.inputDecorationTheme.hintStyle
          prefixIcon: Icon(CupertinoIcons.search, color: theme.inputDecorationTheme.hintStyle?.color), // Use theme hint color for icon
          // filled, fillColor, border, enabledBorder, focusedBorder will be inherited from theme.
          // If specific borderRadius like 12 is needed and theme is 8, either theme should be updated,
          // or this specific instance can override parts of the theme's InputDecoration.
          // For now, let's assume the theme's default (borderRadius: 8) is acceptable for consistency.
          // If a larger radius (e.g. 30 as seen in a previous grep for another search bar) is desired,
          // then this decoration would need to be more custom.
        ),
      ),
    );
  }
}
