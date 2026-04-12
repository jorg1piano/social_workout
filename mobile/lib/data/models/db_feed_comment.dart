/// Row from the `feed_comment` table joined with `user_profile`.
class DbFeedComment {
  final String id;
  final String feedItemId;
  final String userId;
  final String body;
  final int createdAt; // Unix epoch seconds

  // Joined from user_profile
  final String userDisplayName;
  final String username;

  const DbFeedComment({
    required this.id,
    required this.feedItemId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.userDisplayName,
    required this.username,
  });

  factory DbFeedComment.fromRow(Map<String, Object?> row) {
    return DbFeedComment(
      id: row['id']! as String,
      feedItemId: row['feed_item_id']! as String,
      userId: row['user_id']! as String,
      body: row['body']! as String,
      createdAt: row['created_at']! as int,
      userDisplayName: row['display_name']! as String,
      username: row['username']! as String,
    );
  }

  /// User initials for avatar fallback.
  String get userInitials {
    final parts = userDisplayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
