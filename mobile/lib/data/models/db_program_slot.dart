/// Row from the `program_slot` table.
///
/// Matches `sqlite/schema.sql` table #21.
class DbProgramSlot {
  final String id;
  final String trainingProgramId;
  final String? workoutTemplateId;
  final int? weekNumber;
  final int? dayOfWeek;
  final int slotOrder;
  final bool isRestDay;
  final String? notes;

  const DbProgramSlot({
    required this.id,
    required this.trainingProgramId,
    this.workoutTemplateId,
    this.weekNumber,
    this.dayOfWeek,
    required this.slotOrder,
    this.isRestDay = false,
    this.notes,
  });

  factory DbProgramSlot.fromRow(Map<String, Object?> row) {
    return DbProgramSlot(
      id: row['id']! as String,
      trainingProgramId: row['training_program_id']! as String,
      workoutTemplateId: row['workout_template_id'] as String?,
      weekNumber: row['week_number'] as int?,
      dayOfWeek: row['day_of_week'] as int?,
      slotOrder: row['slot_order']! as int,
      isRestDay: (row['is_rest_day']! as int) == 1,
      notes: row['notes'] as String?,
    );
  }

  /// Human-readable day name for weekly schedules.
  String? get dayName => dayOfWeek == null
      ? null
      : const [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][dayOfWeek!];
}
