/// Row from `planned_workout` joined with `user_profile` and `workout_template`.
///
/// Used by [FeedDao.loadTodaysPlannedWorkouts] to power the "who's working out
/// today" Stories row without extra queries.
class DbPlannedWorkout {
  final String id;
  final String userId;
  final String workoutTemplateId;
  final int plannedDate; // Unix epoch seconds, start-of-day
  final int? plannedTime; // Unix epoch seconds, nullable
  final String? notes;

  // Joined from user_profile
  final String userDisplayName;
  final String username;
  final String? userAvatarUrl;

  // Joined from workout_template
  final String workoutTemplateName;

  const DbPlannedWorkout({
    required this.id,
    required this.userId,
    required this.workoutTemplateId,
    required this.plannedDate,
    this.plannedTime,
    this.notes,
    required this.userDisplayName,
    required this.username,
    this.userAvatarUrl,
    required this.workoutTemplateName,
  });

  factory DbPlannedWorkout.fromRow(Map<String, Object?> row) {
    return DbPlannedWorkout(
      id: row['id']! as String,
      userId: row['user_id']! as String,
      workoutTemplateId: row['workout_template_id']! as String,
      plannedDate: row['planned_date']! as int,
      plannedTime: row['planned_time'] as int?,
      notes: row['notes'] as String?,
      userDisplayName: row['display_name']! as String,
      username: row['username']! as String,
      userAvatarUrl: row['avatar_url'] as String?,
      workoutTemplateName: row['template_name']! as String,
    );
  }

  /// User initials for avatar fallback.
  String get userInitials {
    final parts = userDisplayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formatted planned time (e.g. "6:00 PM"), or null if no time set.
  String? get formattedTime {
    if (plannedTime == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(plannedTime! * 1000);
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
