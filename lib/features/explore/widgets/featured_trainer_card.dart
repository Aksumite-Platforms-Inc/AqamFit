import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedTrainerCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String? imageUrl; // Optional for future use

  const FeaturedTrainerCard({
    super.key,
    required this.name,
    required this.specialization,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      width: 150,
      child: Card(
        // Card styling will be inherited from theme (surfaceVariant or similar)
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder( // Ensure card has rounded corners for consistency
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make column children stretch width
          children: [
            // Image Placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surface, // A slightly different background for the image area
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            // Text Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialization,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
