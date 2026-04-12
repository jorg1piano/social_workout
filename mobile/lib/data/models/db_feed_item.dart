import 'feed_item_type.dart';

/// Row from the `feed_item` table joined with `user_profile`.
///
/// This is a read-view used by [FeedDao.loadFeed] — it denormalizes the
/// user display_name and username onto the feed row so the list can render
/// without a second query.
class DbFeedItem {
  final String id;
  final String userId;
  final FeedItemType itemType;
  final String title;
  final String? description;
  final String? workoutId;
  final String? exerciseId;
  final double? metricValue;
  final String? metricUnit;
  final int likeCount;
  final int commentCount;
  final int occurredAt; // Unix epoch seconds

  // Joined from user_profile
  final String userDisplayName;
  final String username;
  final String? userAvatarUrl;

  const DbFeedItem({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.title,
    this.description,
    this.workoutId,
    this.exerciseId,
    this.metricValue,
    this.metricUnit,
    required this.likeCount,
    required this.commentCount,
    required this.occurredAt,
    required this.userDisplayName,
    required this.username,
    this.userAvatarUrl,
  });

  factory DbFeedItem.fromRow(Map<String, Object?> row) {
    return DbFeedItem(
      id: row['id']! as String,
      userId: row['user_id']! as String,
      itemType: FeedItemType.fromDb(row['item_type']! as String),
      title: row['title']! as String,
      description: row['description'] as String?,
      workoutId: row['workout_id'] as String?,
      exerciseId: row['exercise_id'] as String?,
      metricValue: row['metric_value'] != null
          ? (row['metric_value']! as num).toDouble()
          : null,
      metricUnit: row['metric_unit'] as String?,
      likeCount: row['like_count']! as int,
      commentCount: row['comment_count']! as int,
      occurredAt: row['occurred_at']! as int,
      userDisplayName: row['display_name']! as String,
      username: row['username']! as String,
      userAvatarUrl: row['avatar_url'] as String?,
    );
  }

  /// User initials for avatar fallback.
  String get userInitials {
    final parts = userDisplayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formatted metric string, e.g. "275 lbs" or "200 days".
  String? get formattedMetric {
    if (metricValue == null) return null;
    final v = metricValue!;
    final valueStr = v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(1);
    if (metricUnit != null && metricUnit!.isNotEmpty) {
      return '$valueStr $metricUnit';
    }
    return valueStr;
  }
}
