import 'package:sqflite/sqflite.dart';

import '../models/db_exercise.dart';

/// Read-side DAO for the exercise library (`exercise` table).
///
/// Separate from [TemplateDao] so that a future "browse catalog" screen
/// can reach library rows without dragging template-specific queries
/// along.
class ExerciseDao {
  ExerciseDao(this._db);

  final Database _db;

  /// Fetches a single exercise by id.
  Future<DbExercise?> findById(String id) async {
    final rows = await _db.query(
      'exercise',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbExercise.fromRow(rows.first);
  }
}
