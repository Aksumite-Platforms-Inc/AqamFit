import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:aksumfit/models/challenge.dart';
import 'package:aksumfit/services/api_service.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<Challenge> _featuredChallenges = [];
  List<Challenge> _hotChallenges = [];
  bool _isLoadingChallenges = true;
  String? _challengesError;

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() {
      _isLoadingChallenges = true;
      _challengesError = null;
    });
    try {
      final featured = await ApiService().getFeaturedChallenges();
      final hot = await ApiService().getHotChallenges();
      // Simple approach: filter hot challenges to not include ones already in featured
      final hotFiltered = hot.where((h) => !featured.any((f) => f.id == h.id)).toList();

      if (mounted) {
        setState(() {
          _featuredChallenges = featured;
          _hotChallenges = hotFiltered; // Use the filtered list
          _isLoadingChallenges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _challengesError = "Error fetching challenges: ${e.toString()}";
          _isLoadingChallenges = false;
        });
      }
    }
  }

  Widget _buildChallengeCard(Challenge challenge, ThemeData theme, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75, // Card takes 75% of screen width
      child: Card(
        margin: const EdgeInsets.only(right: 16.0, bottom: 8.0, top: 8.0), // Margin for horizontal list
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
              Image.asset(
                challenge.imageUrl!,
                height: 100, // Fixed height for the image
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported, color: theme.dividerColor),
                  );
                },
              )
            else
              Container( // Placeholder if no image
                height: 100,
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                alignment: Alignment.center,
                child: Icon(Icons.emoji_events, size: 40, color: theme.colorScheme.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text("${challenge.participantCount} participants", style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text("Ends: ${DateFormat.yMd().format(challenge.endDate)}", style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () { /* TODO: Navigate to challenge details */ },
                  child: const Text("View"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Community Hub",
          style: GoogleFonts.inter(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: _fetchChallenges,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Enhanced Community Feed Section
            Text("Community Feed", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // 1. Post Update Input Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Share your workout or thoughts...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                      ),
                      maxLines: 3,
                      readOnly: true, // Placeholder
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Post functionality coming soon!")),
                          );
                        },
                        child: const Text("Post")
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Example Group Discussion Post
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 8),
                      Text("UserA_FitnessFan", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Text("Anyone tried the new HIIT challenge? Looking for tips on pacing myself for the full 30 minutes!", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text("Reactions: 👍 (12) 🔥 (5) | Comments: 4", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Example Daily Motivational Thread
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Icons.star, color: theme.colorScheme.onPrimaryContainer)),
                      const SizedBox(width: 8),
                      Text("AksumFit Bot", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Text("Daily Motivation ✨: What's one small victory you're aiming for today, big or small?", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text("Reactions: ❤️ (30) 💪 (15) | Comments: 18", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Example User Workout Post
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const CircleAvatar(child: Icon(Icons.person_outline)),
                      const SizedBox(width: 8),
                      Text("RunnerGal_77", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Text("Just crushed my morning 5k! 🏃‍♀️ Feeling energized and ready for the day. #running #fitnessjourney", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text("Reactions: 🎉 (8) | Comments: 3", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
            const Divider(height: 30, thickness: 1),

            // Featured Challenges Section
            Text("Featured Challenges", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            _isLoadingChallenges
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : _challengesError != null
                    ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_challengesError!, style: TextStyle(color: theme.colorScheme.error))))
                    : _featuredChallenges.isEmpty
                        ? Container(
                            height: 150, alignment: Alignment.center, margin: const EdgeInsets.symmetric(vertical: 12.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                            ),
                            child: const Text("No featured challenges right now."),
                          )
                        : SizedBox(
                            height: 280, // Adjust height to fit card content + button
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _featuredChallenges.length,
                              itemBuilder: (context, index) => _buildChallengeCard(_featuredChallenges[index], theme, context),
                            ),
                          ),
            const Divider(height: 30, thickness: 1),

            // Hot Challenges Section
            Text("Hot Challenges", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
             _isLoadingChallenges
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : _challengesError != null // Assuming same error applies or fetch them separately with own error handling
                    ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_challengesError!, style: TextStyle(color: theme.colorScheme.error))))
                    : _hotChallenges.isEmpty
                        ? Container(
                            height: 150, alignment: Alignment.center, margin: const EdgeInsets.symmetric(vertical: 12.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                            ),
                            child: const Text("No hot challenges at the moment."),
                          )
                        : SizedBox(
                            height: 280, // Adjust height
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _hotChallenges.length,
                              itemBuilder: (context, index) => _buildChallengeCard(_hotChallenges[index], theme, context),
                            ),
                          ),
            const Divider(height: 30, thickness: 1),

            // Placeholder for Friends' Activity
            Text("Friends' Activity", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            Container(
              height: 100, alignment: Alignment.center, margin: const EdgeInsets.symmetric(vertical: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: const Text("Friends' achievements will appear here..."),
            ),
            const Divider(height: 30, thickness: 1),

            // Placeholder for Friend Suggestions
            Text("People You May Know", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            Container(
              height: 120, alignment: Alignment.center, margin: const EdgeInsets.symmetric(vertical: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: const Text("Friend suggestions will appear here..."),
            ),
          ],
        ),
      ),
    );
  }
}
