/// Row from the `competition_exercise` table.
///
/// Matches `sqlite/schema.sql` table #16. Links exercises to a competition.
class DbCompetitionExercise {
  final String id;
  final String competitionId;
  final String exerciseId;

  const DbCompetitionExercise({
    required this.id,
    required this.competitionId,
    required this.exerciseId,
  });

  factory DbCompetitionExercise.fromRow(Map<String, Object?> row) {
    return DbCompetitionExercise(
      id: row['id']! as String,
      competitionId: row['competition_id']! as String,
      exerciseId: row['exercise_id']! as String,
    );
  }
}
