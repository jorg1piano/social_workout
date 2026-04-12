/// How a [DbTrainingProgram] organises its slots across the week.
enum ScheduleType {
  weeklyFixed,
  rotation,
  multiWeekCycle,
  freeform;

  /// DB column value → enum.
  static ScheduleType fromDb(String value) => switch (value) {
        'weekly_fixed' => weeklyFixed,
        'rotation' => rotation,
        'multi_week_cycle' => multiWeekCycle,
        'freeform' => freeform,
        _ => throw ArgumentError('Unknown schedule_type: $value'),
      };

  /// Enum → DB column value.
  String toDb() => switch (this) {
        weeklyFixed => 'weekly_fixed',
        rotation => 'rotation',
        multiWeekCycle => 'multi_week_cycle',
        freeform => 'freeform',
      };

  /// Human-readable label for the UI.
  String get label => switch (this) {
        weeklyFixed => 'Weekly',
        rotation => 'Rotation',
        multiWeekCycle => 'Multi-Week Cycle',
        freeform => 'Freeform',
      };
}
