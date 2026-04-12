/// Controlled vocabulary for `competition.status`.
///
/// Maps to the CHECK constraint in `sqlite/schema.sql`:
/// `CHECK (status IN ('upcoming', 'active', 'completed'))`
enum CompetitionStatus {
  upcoming('upcoming'),
  active('active'),
  completed('completed');

  final String wireValue;
  const CompetitionStatus(this.wireValue);

  static CompetitionStatus fromWire(String? raw) {
    if (raw == null) return CompetitionStatus.upcoming;
    for (final s in CompetitionStatus.values) {
      if (s.wireValue == raw) return s;
    }
    return CompetitionStatus.upcoming;
  }

  String get displayLabel {
    switch (this) {
      case CompetitionStatus.upcoming:
        return 'Upcoming';
      case CompetitionStatus.active:
        return 'Active';
      case CompetitionStatus.completed:
        return 'Completed';
    }
  }
}
