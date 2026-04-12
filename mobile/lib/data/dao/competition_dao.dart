import 'package:sqflite/sqflite.dart';

import '../models/db_competition.dart';

/// Read-side DAO for competitions, participants, and leaderboard data.
///
/// Schema-parity note: column names come from `sqlite/schema.sql` tables
/// #15–#18. The `competition` table uses `start_date` / `end_date` as
/// INTEGER unix epoch seconds and `competition_type` / `status` as TEXT
/// with CHECK constraints.
class CompetitionDao {
  CompetitionDao(this._db);

  final Database _db;

  /// All competitions, most recently created first (ULID = chronological).
  Future<List<DbCompetition>> allCompetitions() async {
    final rows = await _db.query('competition', orderBy: 'id DESC');
    return rows.map(DbCompetition.fromRow).toList();
  }

  /// Single competition by id.
  Future<DbCompetition?> getCompetition(String id) async {
    final rows = await _db.query(
      'competition',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbCompetition.fromRow(rows.first);
  }

  /// Participant count for a competition.
  Future<int> participantCount(String competitionId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM competition_participant WHERE competition_id = ?',
      [competitionId],
    );
    return result.first['cnt']! as int;
  }

  /// Exercises linked to a competition, with the exercise name joined in.
  /// Returns rows with `exercise_name` alongside the standard
  /// `competition_exercise` columns.
  Future<List<Map<String, Object?>>> exercisesForCompetition(
      String competitionId) async {
    return _db.rawQuery(
      '''
      SELECT ce.*, e.name AS exercise_name
      FROM competition_exercise ce
      JOIN exercise e ON e.id = ce.exercise_id
      WHERE ce.competition_id = ?
      ORDER BY e.name
      ''',
      [competitionId],
    );
  }

  /// All participants for a competition, with display_name joined in.
  Future<List<Map<String, Object?>>> participantsForCompetition(
      String competitionId) async {
    return _db.rawQuery(
      '''
      SELECT cp.*, up.display_name, up.username
      FROM competition_participant cp
      JOIN user_profile up ON up.id = cp.user_id
      WHERE cp.competition_id = ?
      ORDER BY cp.joined_at ASC
      ''',
      [competitionId],
    );
  }

  /// Leaderboard entries for a competition, ranked by score descending.
  /// Joins `user_profile` for display_name.
  Future<List<Map<String, Object?>>> leaderboardForCompetition(
      String competitionId) async {
    return _db.rawQuery(
      '''
      SELECT le.*, up.display_name, up.username
      FROM competition_leaderboard_entry le
      JOIN user_profile up ON up.id = le.user_id
      WHERE le.competition_id = ?
      ORDER BY le.score DESC
      ''',
      [competitionId],
    );
  }
}
