/// Row from the `program_enrollment` table.
///
/// Matches `sqlite/schema.sql` table #22.
class DbProgramEnrollment {
  final String id;
  final String userId;
  final String trainingProgramId;
  final int currentWeek;
  final int currentSlotOrder;
  final int startedAt;
  final bool isActive;
  final int cycleCount;

  const DbProgramEnrollment({
    required this.id,
    required this.userId,
    required this.trainingProgramId,
    this.currentWeek = 1,
    this.currentSlotOrder = 1,
    required this.startedAt,
    this.isActive = true,
    this.cycleCount = 0,
  });

  factory DbProgramEnrollment.fromRow(Map<String, Object?> row) {
    return DbProgramEnrollment(
      id: row['id']! as String,
      userId: row['user_id']! as String,
      trainingProgramId: row['training_program_id']! as String,
      currentWeek: row['current_week']! as int,
      currentSlotOrder: row['current_slot_order']! as int,
      startedAt: row['started_at']! as int,
      isActive: (row['is_active']! as int) == 1,
      cycleCount: row['cycle_count']! as int,
    );
  }
}
