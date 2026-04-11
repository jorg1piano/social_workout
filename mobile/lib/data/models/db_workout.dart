/// Row from the `workout` table — an actual workout session.
///
/// Matches `sqlite/schema.sql` table #7. Note the schema uses `start_time`
/// and `stop_time` (not `started_at` / `ended_at`). `stop_time IS NULL`
/// means the workout is still in progress.
class DbWorkout {
  final String id;
  final String? templateId;
  final int? startTime;
  final int? stopTime;

  const DbWorkout({
    required this.id,
    this.templateId,
    this.startTime,
    this.stopTime,
  });

  bool get isInProgress => stopTime == null;

  factory DbWorkout.fromRow(Map<String, Object?> row) {
    return DbWorkout(
      id: row['id']! as String,
      templateId: row['template_id'] as String?,
      startTime: row['start_time'] as int?,
      stopTime: row['stop_time'] as int?,
    );
  }
}
