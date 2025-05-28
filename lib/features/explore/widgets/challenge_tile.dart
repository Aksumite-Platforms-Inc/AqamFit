import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengeTile extends StatelessWidget {
  final String title;
  final String description;

  const ChallengeTile({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement challenge tap functionality
      },
      child: Card(
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        // Clip the child container to respect the card's rounded corners
        clipBehavior: Clip.antiAlias, 
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            // The card's color will be the background. 
            // If an image is added, it would go here.
            borderRadius: BorderRadius.circular(12.0), 
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
