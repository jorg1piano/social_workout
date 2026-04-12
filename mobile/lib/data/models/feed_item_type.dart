/// Discrete item types for the social feed.
///
/// Maps 1:1 to the `feed_item.item_type` CHECK constraint in
/// `sqlite/schema.sql`.
enum FeedItemType {
  workoutCompleted('workout_completed'),
  personalRecord('personal_record'),
  streakMilestone('streak_milestone');

  const FeedItemType(this.dbValue);

  /// The string stored in the `item_type` column.
  final String dbValue;

  /// Parses the DB string into the enum. Throws on unknown values so we
  /// catch schema drift early rather than silently swallowing new types.
  static FeedItemType fromDb(String value) {
    for (final t in FeedItemType.values) {
      if (t.dbValue == value) return t;
    }
    throw ArgumentError('Unknown feed_item.item_type: "$value"');
  }
}
