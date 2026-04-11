import 'package:sqflite/sqflite.dart';

import '../db/ulid.dart';
import '../models/db_exercise_set.dart';
import '../models/db_exercise_set_template.dart';
import '../models/db_workout.dart';
import '../models/set_type.dart';

/// Write-side DAO for live workout sessions and their `exercise_set` rows.
///
/// Schema-parity note: column names come from `sqlite/schema.sql`. In
/// particular:
///   * `workout` uses `start_time` / `stop_time` (NOT `started_at` /
///     `ended_at`); an in-progress session has `stop_time IS NULL`.
///   * `exercise_set` uses `rep_count` (NOT `reps`) and `is_completed` as
///     a 0/1 INTEGER.
///   * `attempt_number` is 1 for the normal case (retry-at-same-slot is
///     out of scope for this task).
///
/// Every INSERT here generates a client-side `app-`-prefixed ULID via
/// [Ulid.generate] — IDs are never allocated by the server, in line with
/// the offline-first rule in `.claude/agents/mobile.md`.
class WorkoutDao {
  WorkoutDao(this._db);

  final Database _db;

  /// Returns the most recent in-progress workout for [templateId], or null
  /// if every prior session for that template is finished. Used on screen
  /// open to decide "resume" vs "start new".
  Future<DbWorkout?> findInProgressForTemplate(String templateId) async {
    final rows = await _db.query(
      'workout',
      where: 'template_id = ? AND stop_time IS NULL',
      whereArgs: [templateId],
      orderBy: 'id DESC', // ULID = chronological
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbWorkout.fromRow(rows.first);
  }

  /// Inserts a new `workout` row with `start_time = now` and
  /// `stop_time = NULL`. Returns the full row.
  Future<DbWorkout> startWorkout({required String templateId}) async {
    final id = Ulid.generate();
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.rawInsert(
      '''
      INSERT INTO workout (id, template_id, start_time, stop_time)
      VALUES (?, ?, ?, NULL)
      ''',
      [id, templateId, nowSec],
    );
    return DbWorkout(
      id: id,
      templateId: templateId,
      startTime: nowSec,
      stopTime: null,
    );
  }

  /// Closes an in-progress workout by setting `stop_time = now`. The
  /// schema's `updated_at` default expression will NOT auto-update on
  /// UPDATE (SQLite defaults are INSERT-time only), so we set it explicitly.
  Future<void> finishWorkout(String workoutId) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.update(
      'workout',
      {'stop_time': nowSec, 'updated_at': nowSec},
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  /// Single `exercise_set` row by id. Returns null if no such row exists
  /// (e.g. caller has a stale id after a swap deleted incomplete rows).
  Future<DbExerciseSet?> getSet(String id) async {
    final rows = await _db.query(
      'exercise_set',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbExerciseSet.fromRow(rows.first);
  }

  /// All `exercise_set` rows for a workout slot, in set order. Reads
  /// `set_type` directly from the column backend Task C added.
  Future<List<DbExerciseSet>> setsForSlot({
    required String workoutId,
    required String exerciseForWorkoutTemplateId,
  }) async {
    final rows = await _db.query(
      'exercise_set',
      where: 'workout_id = ? AND exercise_for_workout_template_id = ?',
      whereArgs: [workoutId, exerciseForWorkoutTemplateId],
      orderBy: 'ordering ASC, attempt_number ASC',
    );
    return rows.map(DbExerciseSet.fromRow).toList();
  }

  /// Preloads `exercise_set` rows for a slot based on its planned
  /// `exercise_set_template` rows, copying weight / rep_count / ordering /
  /// rest_time / set_type across. All new rows start with `is_completed = 0`.
  Future<List<DbExerciseSet>> preloadSetsFromTemplate({
    required String workoutId,
    required String exerciseForWorkoutTemplateId,
    required String exerciseId,
    required List<DbExerciseSetTemplate> plannedSets,
  }) async {
    if (plannedSets.isEmpty) return const [];
    final batch = _db.batch();
    final inserted = <DbExerciseSet>[];
    for (final plan in plannedSets) {
      final id = Ulid.generate();
      batch.rawInsert(
        '''
        INSERT INTO exercise_set (
          id, rep_count, weight, duration, unit, ordering, attempt_number,
          set_type, rest_time, workout_id, exercise_id,
          exercise_for_workout_template_id, is_completed
        )
        VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, 0)
        ''',
        [
          id,
          plan.repCount,
          plan.weight,
          plan.duration,
          plan.unit,
          plan.ordering,
          plan.setType.wireValue,
          plan.restTime,
          workoutId,
          exerciseId,
          exerciseForWorkoutTemplateId,
        ],
      );
      inserted.add(
        DbExerciseSet(
          id: id,
          repCount: plan.repCount,
          weight: plan.weight,
          duration: plan.duration,
          unit: plan.unit,
          ordering: plan.ordering,
          attemptNumber: 1,
          restTime: plan.restTime,
          workoutId: workoutId,
          exerciseId: exerciseId,
          exerciseForWorkoutTemplateId: exerciseForWorkoutTemplateId,
          isCompleted: false,
          setType: plan.setType,
        ),
      );
    }
    await batch.commit(noResult: true);
    return inserted;
  }

  /// Inserts a new blank working set at `ordering = max+1` for a slot.
  /// Returns the inserted row (weight/rep_count null until the user types).
  Future<DbExerciseSet> addSet({
    required String workoutId,
    required String exerciseForWorkoutTemplateId,
    required String exerciseId,
  }) async {
    final id = Ulid.generate();
    // Compute the next ordering inside a transaction so two rapid taps
    // can't race and produce two rows with the same ordering (which would
    // violate idx_exercise_set_attempt).
    await _db.transaction((txn) async {
      final result = await txn.rawQuery(
        '''
        SELECT COALESCE(MAX(ordering), 0) + 1 AS next_ordering
        FROM exercise_set
        WHERE workout_id = ?
          AND exercise_for_workout_template_id = ?
        ''',
        [workoutId, exerciseForWorkoutTemplateId],
      );
      final nextOrdering = (result.first['next_ordering']! as int);
      await txn.rawInsert(
        '''
        INSERT INTO exercise_set (
          id, ordering, attempt_number, set_type, rest_time,
          workout_id, exercise_id, exercise_for_workout_template_id,
          is_completed
        )
        VALUES (?, ?, 1, 'regularSet', 0, ?, ?, ?, 0)
        ''',
        [
          id,
          nextOrdering,
          workoutId,
          exerciseId,
          exerciseForWorkoutTemplateId,
        ],
      );
    });
    // Re-read the row so the caller gets the populated record (easier than
    // guessing ordering here after the transaction).
    final rows = await _db.query(
      'exercise_set',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return DbExerciseSet.fromRow(rows.first);
  }

  /// Updates weight + rep_count on a specific set. `updated_at` is bumped
  /// manually since SQLite default expressions only fire on INSERT.
  Future<void> updateSetValues({
    required String setId,
    required double? weight,
    required int? repCount,
  }) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.update(
      'exercise_set',
      {
        'weight': weight,
        'rep_count': repCount,
        'updated_at': nowSec,
      },
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Updates `set_type` on a single `exercise_set` row. The wire value
  /// goes through [SetType.wireValue] so the four allowed strings line up
  /// exactly with the schema CHECK constraint
  /// (`'warmup','regularSet','dropSet','failure'`).
  Future<void> updateSetType({
    required String setId,
    required SetType setType,
  }) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.update(
      'exercise_set',
      {
        'set_type': setType.wireValue,
        'updated_at': nowSec,
      },
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Toggles the `is_completed` flag on a set.
  Future<void> setCompleted({
    required String setId,
    required bool completed,
  }) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.update(
      'exercise_set',
      {
        'is_completed': completed ? 1 : 0,
        'updated_at': nowSec,
      },
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  /// Deletes every NOT-YET-completed `exercise_set` row for a slot in the
  /// given workout. Used when the user swaps exercise variants mid-workout:
  /// the old variant's completed rows are preserved (history), the pending
  /// rows are cleared so the new variant can preload fresh planned sets.
  Future<void> deleteIncompleteSetsForSlot({
    required String workoutId,
    required String exerciseForWorkoutTemplateId,
  }) async {
    await _db.delete(
      'exercise_set',
      where:
          'workout_id = ? AND exercise_for_workout_template_id = ? AND is_completed = 0',
      whereArgs: [workoutId, exerciseForWorkoutTemplateId],
    );
  }

  /// "Previous session" lookup for the Previous column. Returns completed
  /// sets from the most recent PRIOR workout (any template) that logged
  /// against [exerciseForWorkoutTemplateId], in set order.
  ///
  /// ULID-based chronology: `ORDER BY workout_id DESC` is the same as
  /// most-recent first because ULIDs sort lexicographically by creation
  /// time.
  Future<List<DbExerciseSet>> previousSessionSets({
    required String currentWorkoutId,
    required String exerciseForWorkoutTemplateId,
  }) async {
    // 1. Find the most recent prior workout_id that has completed sets for
    //    this slot, excluding the current workout.
    final priorRows = await _db.rawQuery(
      '''
      SELECT workout_id
      FROM exercise_set
      WHERE exercise_for_workout_template_id = ?
        AND is_completed = 1
        AND workout_id != ?
      ORDER BY workout_id DESC
      LIMIT 1
      ''',
      [exerciseForWorkoutTemplateId, currentWorkoutId],
    );
    if (priorRows.isEmpty) return const [];
    final priorWorkoutId = priorRows.first['workout_id']! as String;

    // 2. Pull that workout's completed sets for this slot, in set order.
    final rows = await _db.query(
      'exercise_set',
      where:
          'workout_id = ? AND exercise_for_workout_template_id = ? AND is_completed = 1',
      whereArgs: [priorWorkoutId, exerciseForWorkoutTemplateId],
      orderBy: 'ordering ASC',
    );
    return rows.map(DbExerciseSet.fromRow).toList();
  }
}
