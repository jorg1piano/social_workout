import 'package:flutter/material.dart';

import 'data/db/database.dart';
import 'features/active_workout/active_workout_screen.dart';
import 'features/body_measurements/body_measurements_screen.dart';
import 'features/competition/competition_list_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/home_variant_a.dart';
import 'features/home/home_variant_b.dart';
import 'features/home/home_variant_c.dart';
import 'features/paywall/paywall_flow_screen.dart';
import 'features/social_feed/social_feed_screen.dart';
import 'features/streak/streak_screen.dart';
import 'features/workout_summary/workout_summary_screen.dart';
import 'style/app_style.dart';

/// Push Day template ULID from `sqlite/new-test-data.sql` — the initial
/// template the active workout screen loads.
const String pushDayTemplateId = 'app-01KE6BHGJAFFKEAQ7X760EBPHJ';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.openAndInitialize();

  runApp(SocialWorkoutApp(database: database));
}

class SocialWorkoutApp extends StatelessWidget {
  const SocialWorkoutApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Workout',
      debugShowCheckedModeBanner: false,
      theme: AppStyle.theme(),
      home: FeatureListScreen(database: database),
    );
  }
}

class FeatureListScreen extends StatelessWidget {
  const FeatureListScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Workout')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppStyle.primaryBlue),
            title: const Text('Home Page'),
            subtitle: const Text('Scaffolding concept'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: AppStyle.primaryBlue),
            title: const Text('Home Variant A'),
            subtitle: const Text('Dashboard-first layout'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeVariantA()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded, color: AppStyle.primaryBlue),
            title: const Text('Home Variant B'),
            subtitle: const Text('Social-first layout'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeVariantB()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bolt_rounded, color: AppStyle.primaryBlue),
            title: const Text('Home Variant C'),
            subtitle: const Text('Action-first layout'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeVariantC()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department_rounded,
                color: AppStyle.streakOrange),
            title: const Text('Streak'),
            subtitle: const Text('Workout streak concept'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StreakScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.celebration_rounded, color: AppStyle.finishGreen),
            title: const Text('Workout Summary'),
            subtitle: const Text('Post-workout recap'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutSummaryScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Active Workout'),
            subtitle: const Text('Push Day template'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActiveWorkoutScreen(
                  database: database,
                  templateId: pushDayTemplateId,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Competitions'),
            subtitle: const Text('Compete with friends'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionListScreen(database: database),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Body Measurements'),
            subtitle: const Text('Track weight, body fat, circumferences'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BodyMeasurementsScreen(database: database),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Social Feed'),
            subtitle: const Text('Workout updates from friends'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SocialFeedScreen(database: database),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.diamond, color: Color(0xFFD4A017)),
            title: const Text('Paywall'),
            subtitle: const Text('Subscription onboarding flow'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaywallFlowScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
