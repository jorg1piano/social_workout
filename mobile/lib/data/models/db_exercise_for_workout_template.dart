/// Row from the `exercise_for_workout_template` table — a slot in a template.
///
/// Matches `sqlite/schema.sql` table #8. Rows sharing the same
/// `(workout_template_id, ordering)` but differing by `exercise_index` are
/// the allowed alternatives for that slot; swapping mid-workout just means
/// pointing subsequent `exercise_set` rows at a different sibling.
class DbExerciseForWorkoutTemplate {
  final String id;
  final String workoutTemplateId;
  final String exerciseId;
  final String? notes;
  final int ordering;
  final int exerciseIndex;

  const DbExerciseForWorkoutTemplate({
    required this.id,
    required this.workoutTemplateId,
    required this.exerciseId,
    this.notes,
    required this.ordering,
    required this.exerciseIndex,
  });

  factory DbExerciseForWorkoutTemplate.fromRow(Map<String, Object?> row) {
    return DbExerciseForWorkoutTemplate(
      id: row['id']! as String,
      workoutTemplateId: row['workout_template_id']! as String,
      exerciseId: row['exercise_id']! as String,
      notes: row['notes'] as String?,
      ordering: row['ordering']! as int,
      exerciseIndex: row['exercise_index']! as int,
    );
  }
}
