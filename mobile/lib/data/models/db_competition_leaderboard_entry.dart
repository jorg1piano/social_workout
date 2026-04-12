/// Row from the `competition_leaderboard_entry` table.
///
/// Matches `sqlite/schema.sql` table #18. `score` is DECIMAL(10,2) in the
/// schema — stored as a Dart `double`.
class DbCompetitionLeaderboardEntry {
  final String id;
  final String competitionId;
  final String userId;
  final double score;
  final int? rank;
  final int? lastActivityAt;

  const DbCompetitionLeaderboardEntry({
    required this.id,
    required this.competitionId,
    required this.userId,
    required this.score,
    this.rank,
    this.lastActivityAt,
  });

  factory DbCompetitionLeaderboardEntry.fromRow(Map<String, Object?> row) {
    return DbCompetitionLeaderboardEntry(
      id: row['id']! as String,
      competitionId: row['competition_id']! as String,
      userId: row['user_id']! as String,
      score: (row['score']! as num).toDouble(),
      rank: row['rank'] as int?,
      lastActivityAt: row['last_activity_at'] as int?,
    );
  }
}
