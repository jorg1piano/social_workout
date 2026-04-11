import 'set_type.dart';

/// Row from the `exercise_set` table — an actual set the user performed (or
/// is about to perform) in a workout session.
///
/// Matches `sqlite/schema.sql` table #10. Column notes:
///   * `weight` → Dart `double?` (DECIMAL(5,2) → REAL affinity).
///   * `rep_count` matches schema column name (NOT `reps`).
///   * `is_completed` is INTEGER (0/1) in SQLite → Dart `bool`.
///   * `setType` does NOT yet exist on this table as of v1 schema — Task C
///     is adding it. Until then we derive the display type by joining back
///     to `exercise_set_template` on `(exercise_for_workout_template_id,
///     ordering)`. Field is here so the DAO can populate it from either
///     source without callers caring.
class DbExerciseSet {
  final String id;
  final int? repCount;
  final double? weight;
  final int? duration;
  final String? unit;
  final int? ordering;
  final int attemptNumber;
  final String? notes;
  final int restTime;
  final String workoutId;
  final String exerciseId;
  final String exerciseForWorkoutTemplateId;
  final bool isCompleted;
  final SetType setType;

  const DbExerciseSet({
    required this.id,
    this.repCount,
    this.weight,
    this.duration,
    this.unit,
    this.ordering,
    required this.attemptNumber,
    this.notes,
    required this.restTime,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseForWorkoutTemplateId,
    required this.isCompleted,
    required this.setType,
  });

  /// Builds from a joined row. Expects an optional `set_type` column that
  /// may come either from `exercise_set.set_type` (post-Task-C) or from a
  /// JOINed `exercise_set_template.set_type` (pre-Task-C); both paths are
  /// transparent to the caller.
  factory DbExerciseSet.fromRow(Map<String, Object?> row) {
    return DbExerciseSet(
      id: row['id']! as String,
      repCount: row['rep_count'] as int?,
      weight: (row['weight'] as num?)?.toDouble(),
      duration: row['duration'] as int?,
      unit: row['unit'] as String?,
      ordering: row['ordering'] as int?,
      attemptNumber: row['attempt_number']! as int,
      notes: row['notes'] as String?,
      restTime: row['rest_time']! as int,
      workoutId: row['workout_id']! as String,
      exerciseId: row['exercise_id']! as String,
      exerciseForWorkoutTemplateId:
          row['exercise_for_workout_template_id']! as String,
      isCompleted: (row['is_completed']! as int) != 0,
      setType: SetType.fromWire(row['set_type'] as String?),
    );
  }
}
