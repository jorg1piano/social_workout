import 'package:sqflite/sqflite.dart';

import '../models/db_program_enrollment.dart';
import '../models/db_program_slot.dart';
import '../models/db_training_program.dart';

/// Read-side DAO for training programs, slots, and enrollment state.
///
/// Schema-parity note: column names come from `sqlite/schema.sql` tables
/// #20–#22.
class TrainingProgramDao {
  TrainingProgramDao(this._db);

  final Database _db;

  /// All training programs, ordered by name.
  Future<List<DbTrainingProgram>> allPrograms() async {
    final rows = await _db.query('training_program', orderBy: 'name ASC');
    return rows.map(DbTrainingProgram.fromRow).toList();
  }

  /// Single program by id.
  Future<DbTrainingProgram?> findById(String id) async {
    final rows = await _db.query(
      'training_program',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbTrainingProgram.fromRow(rows.first);
  }

  /// All slots for a program, in schedule order.
  Future<List<DbProgramSlot>> slotsForProgram(String programId) async {
    final rows = await _db.query(
      'program_slot',
      where: 'training_program_id = ?',
      whereArgs: [programId],
      orderBy: 'week_number ASC, slot_order ASC',
    );
    return rows.map(DbProgramSlot.fromRow).toList();
  }

  /// Active enrollment for a user on a specific program, if any.
  Future<DbProgramEnrollment?> activeEnrollment(
    String userId,
    String programId,
  ) async {
    final rows = await _db.query(
      'program_enrollment',
      where: 'user_id = ? AND training_program_id = ? AND is_active = 1',
      whereArgs: [userId, programId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DbProgramEnrollment.fromRow(rows.first);
  }

  /// All active enrollments for a user (typically just one).
  Future<List<DbProgramEnrollment>> activeEnrollments(String userId) async {
    final rows = await _db.query(
      'program_enrollment',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
    );
    return rows.map(DbProgramEnrollment.fromRow).toList();
  }
}
