import 'package:sqflite/sqflite.dart';

import '../models/db_exercise.dart';
import '../models/db_exercise_for_workout_template.dart';
import '../models/db_exercise_set_template.dart';
import '../models/db_workout_template.dart';

/// Read-side DAO for workout templates and their planned slot structure.
///
/// The active-workout screen uses this to:
///   1. Resolve the Push Day template row.
///   2. Load its slots (one card per distinct `ordering`).
///   3. For each slot, load the sibling variants (same ordering, different
///      `exercise_index`) so the swap sheet has something to show.
///   4. For each chosen variant, load its planned `exercise_set_template`
///      rows so new workouts can preload matching `exercise_set` rows.
class TemplateDao {
  TemplateDao(this._db);

  final Database _db;

  /// Fetches a single template row. Returns null if the id doesn't exist.
  Future<DbWorkoutTemplate?> findById(String id) async {
    final rows = await _db.query(
      'workout_template',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbWorkoutTemplate.fromRow(rows.first);
  }

  /// All `exercise_for_workout_template` rows for [templateId], ordered by
  /// `(ordering, exercise_index)` — callers can group by `ordering` to get
  /// one card per slot with the sibling list for swap.
  Future<List<DbExerciseForWorkoutTemplate>> slotsForTemplate(
    String templateId,
  ) async {
    final rows = await _db.query(
      'exercise_for_workout_template',
      where: 'workout_template_id = ?',
      whereArgs: [templateId],
      orderBy: 'ordering ASC, exercise_index ASC',
    );
    return rows.map(DbExerciseForWorkoutTemplate.fromRow).toList();
  }

  /// Resolves the display exercise rows for a list of variant ids in a
  /// single round-trip. Returned map is keyed by `exercise.id`.
  Future<Map<String, DbExercise>> exercisesByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await _db.query(
      'exercise',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return {
      for (final row in rows)
        (row['id']! as String): DbExercise.fromRow(row),
    };
  }

  /// Planned sets for a given variant (one specific
  /// `exercise_for_workout_template` row), in set order.
  Future<List<DbExerciseSetTemplate>> plannedSetsForVariant(
    String exerciseForWorkoutTemplateId,
  ) async {
    final rows = await _db.query(
      'exercise_set_template',
      where: 'exercise_for_workout_template_id = ?',
      whereArgs: [exerciseForWorkoutTemplateId],
      orderBy: 'ordering ASC',
    );
    return rows.map(DbExerciseSetTemplate.fromRow).toList();
  }
}
