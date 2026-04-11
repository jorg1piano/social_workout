/// Controlled vocabulary for `exercise_set_template.set_type` (and, once
/// Task C lands, `exercise_set.set_type`).
///
/// The schema column is `TEXT NOT NULL` with no CHECK constraint yet —
/// backend Task C will add the CHECK to match these exact string values,
/// which are the same strings used throughout `sqlite/new-test-data.sql`.
/// Keep this enum in sync if backend ever widens the vocabulary.
enum SetType {
  warmup('warmup'),
  regularSet('regularSet'),
  dropSet('dropSet'),
  failure('failure');

  final String wireValue;
  const SetType(this.wireValue);

  /// Parses a raw SQL string into the enum. Falls back to [regularSet] for
  /// unknown values so a future backend vocabulary expansion doesn't crash
  /// the UI — the row will just render as a normal working set.
  static SetType fromWire(String? raw) {
    if (raw == null) return SetType.regularSet;
    for (final t in SetType.values) {
      if (t.wireValue == raw) return t;
    }
    return SetType.regularSet;
  }
}
