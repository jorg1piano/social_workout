import 'set_type.dart';

/// Row from the `exercise_set_template` table — the planned sets for an
/// `exercise_for_workout_template`.
///
/// Matches `sqlite/schema.sql` table #9. Column notes:
///   * `weight` is `DECIMAL(5,2)` which SQLite stores as REAL — mapped to
///     Dart `double?`.
///   * `rep_count` is the planned reps (column name matches schema, NOT
///     `reps`).
///   * `set_type` is the source of truth for warmup vs working-set display
///     while Task C lands on `exercise_set` — we copy it across on insert.
class DbExerciseSetTemplate {
  final String id;
  final int? repCount;
  final double? weight;
  final int? duration;
  final String? unit;
  final int ordering;
  final SetType setType;
  final int restTime;
  final String exerciseId;
  final String exerciseForWorkoutTemplateId;

  const DbExerciseSetTemplate({
    required this.id,
    this.repCount,
    this.weight,
    this.duration,
    this.unit,
    required this.ordering,
    required this.setType,
    required this.restTime,
    required this.exerciseId,
    required this.exerciseForWorkoutTemplateId,
  });

  factory DbExerciseSetTemplate.fromRow(Map<String, Object?> row) {
    return DbExerciseSetTemplate(
      id: row['id']! as String,
      repCount: row['rep_count'] as int?,
      weight: (row['weight'] as num?)?.toDouble(),
      duration: row['duration'] as int?,
      unit: row['unit'] as String?,
      ordering: row['ordering']! as int,
      setType: SetType.fromWire(row['set_type'] as String?),
      restTime: row['rest_time']! as int,
      exerciseId: row['exercise_id']! as String,
      exerciseForWorkoutTemplateId:
          row['exercise_for_workout_template_id']! as String,
    );
  }
}
