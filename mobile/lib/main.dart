import 'package:flutter/material.dart';

import 'data/db/database.dart';
import 'features/active_workout/active_workout_screen.dart';
import 'style/app_style.dart';

/// Push Day template ULID from `sqlite/new-test-data.sql` — the initial
/// template the active workout screen loads.
const String pushDayTemplateId = 'app-01KE6BHGJAFFKEAQ7X760EBPHJ';

Future<void> main() async {
  // Required before any async work that touches platform channels
  // (`path_provider`, asset bundle, sqflite), and before `runApp`.
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
      home: ActiveWorkoutScreen(
        database: database,
        templateId: pushDayTemplateId,
      ),
    );
  }
}
