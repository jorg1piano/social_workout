/// Row from the `user_profile` table.
///
/// Matches `sqlite/schema.sql` table #11.
class DbUserProfile {
  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final bool isCurrentUser;

  const DbUserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.isCurrentUser,
  });

  factory DbUserProfile.fromRow(Map<String, Object?> row) {
    return DbUserProfile(
      id: row['id']! as String,
      displayName: row['display_name']! as String,
      username: row['username']! as String,
      avatarUrl: row['avatar_url'] as String?,
      bio: row['bio'] as String?,
      isCurrentUser: (row['is_current_user'] as int) == 1,
    );
  }

  /// Returns the initials (up to 2 chars) from the display name, used for
  /// the avatar circle fallback.
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
