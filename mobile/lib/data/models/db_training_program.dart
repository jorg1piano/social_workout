import 'schedule_type.dart';

/// Row from the `training_program` table.
///
/// Matches `sqlite/schema.sql` table #20.
class DbTrainingProgram {
  final String id;
  final String name;
  final String? description;
  final ScheduleType scheduleType;
  final int? cycleLengthWeeks;
  final int? daysPerWeek;

  const DbTrainingProgram({
    required this.id,
    required this.name,
    this.description,
    required this.scheduleType,
    this.cycleLengthWeeks,
    this.daysPerWeek,
  });

  factory DbTrainingProgram.fromRow(Map<String, Object?> row) {
    return DbTrainingProgram(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      scheduleType: ScheduleType.fromDb(row['schedule_type']! as String),
      cycleLengthWeeks: row['cycle_length_weeks'] as int?,
      daysPerWeek: row['days_per_week'] as int?,
    );
  }
}
