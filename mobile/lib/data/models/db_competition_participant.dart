/// Row from the `competition_participant` table.
///
/// Matches `sqlite/schema.sql` table #17.
class DbCompetitionParticipant {
  final String id;
  final String competitionId;
  final String userId;
  final int joinedAt;

  const DbCompetitionParticipant({
    required this.id,
    required this.competitionId,
    required this.userId,
    required this.joinedAt,
  });

  factory DbCompetitionParticipant.fromRow(Map<String, Object?> row) {
    return DbCompetitionParticipant(
      id: row['id']! as String,
      competitionId: row['competition_id']! as String,
      userId: row['user_id']! as String,
      joinedAt: row['joined_at']! as int,
    );
  }
}
