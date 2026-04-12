/// Controlled vocabulary for `competition.competition_type`.
///
/// Maps to the CHECK constraint in `sqlite/schema.sql`:
/// `CHECK (competition_type IN ('total_volume', 'max_weight', 'streak', 'total_reps'))`
enum CompetitionType {
  totalVolume('total_volume'),
  maxWeight('max_weight'),
  streak('streak'),
  totalReps('total_reps');

  final String wireValue;
  const CompetitionType(this.wireValue);

  static CompetitionType fromWire(String? raw) {
    if (raw == null) return CompetitionType.totalVolume;
    for (final t in CompetitionType.values) {
      if (t.wireValue == raw) return t;
    }
    return CompetitionType.totalVolume;
  }

  String get displayLabel {
    switch (this) {
      case CompetitionType.totalVolume:
        return 'Total Volume';
      case CompetitionType.maxWeight:
        return 'Max Weight';
      case CompetitionType.streak:
        return 'Streak';
      case CompetitionType.totalReps:
        return 'Total Reps';
    }
  }
}
