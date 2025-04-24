import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/section_header.dart';
import '../widgets/program_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/coach_card.dart';
import '../widgets/category_card.dart';
import '../widgets/verified_coach_banner.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = ['Dumbbell PPL', 'Reddit PPL'];
    final workouts = ['Chest & Tri', 'Leg Day', 'Back & Core'];
    final coaches = ['Raul Villarreal', 'Kolbjørn Lindberg'];
    final categories = ['Muscle Building', 'Strength', 'Fat Loss', 'Fitness'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const SectionHeader(title: 'Exercise Library'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/100'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          SectionHeader(
            title: 'Push/Pull/Legs',
            onViewAll: () => context.push('/ppl'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => ProgramCard(
                title: programs[i],
                onTap: () => context.push('/program/${programs[i]}'),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Popular Workouts'),
          const SizedBox(height: 8),
          ...workouts.map((w) => WorkoutCard(
                title: w,
                onTap: () => context.push('/workout/$w'),
              )),

          const SizedBox(height: 24),
          const SectionHeader(title: 'New Workouts'),
          const SizedBox(height: 8),
          ...workouts.map((w) => WorkoutCard(
                title: '$w (New)',
                onTap: () => context.push('/workout/$w-new'),
              )),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Verified Coaches'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: coaches.map((name) {
              return CoachCard(
                name: name,
                imageUrl: 'https://via.placeholder.com/60?text=$name',
                onFollow: () => debugPrint('Followed $name'),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          const VerifiedCoachBanner(),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Programs by Category'),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => CategoryCard(
                title: categories[i],
                onTap: () => context.push('/category/${categories[i]}'),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
