import 'package:sqflite/sqflite.dart';

import '../models/db_feed_comment.dart';
import '../models/db_feed_item.dart';
import '../models/db_planned_workout.dart';

/// Read-side DAO for the social feed tables (`feed_item`, `feed_like`,
/// `feed_comment`, `user_profile`).
class FeedDao {
  FeedDao(this._db);

  final Database _db;

  /// Loads all feed items joined with user_profile, newest first.
  ///
  /// [limit] caps the result set (default 50). [offset] supports pagination.
  Future<List<DbFeedItem>> loadFeed({int limit = 50, int offset = 0}) async {
    final rows = await _db.rawQuery('''
      SELECT
        fi.id,
        fi.user_id,
        fi.item_type,
        fi.title,
        fi.description,
        fi.workout_id,
        fi.exercise_id,
        fi.metric_value,
        fi.metric_unit,
        fi.like_count,
        fi.comment_count,
        fi.occurred_at,
        up.display_name,
        up.username,
        up.avatar_url
      FROM feed_item fi
      JOIN user_profile up ON fi.user_id = up.id
      ORDER BY fi.occurred_at DESC
      LIMIT ? OFFSET ?
    ''', [limit, offset]);

    return rows.map(DbFeedItem.fromRow).toList();
  }

  /// Loads comments for a single feed item, oldest first.
  Future<List<DbFeedComment>> loadComments(String feedItemId) async {
    final rows = await _db.rawQuery('''
      SELECT
        fc.id,
        fc.feed_item_id,
        fc.user_id,
        fc.body,
        fc.created_at,
        up.display_name,
        up.username
      FROM feed_comment fc
      JOIN user_profile up ON fc.user_id = up.id
      WHERE fc.feed_item_id = ?
      ORDER BY fc.created_at ASC
    ''', [feedItemId]);

    return rows.map(DbFeedComment.fromRow).toList();
  }

  /// Loads planned workouts for today, joined with user_profile and
  /// workout_template. Returns one row per user who has a workout planned
  /// today, ordered by planned_time (nulls last), then display_name.
  Future<List<DbPlannedWorkout>> loadTodaysPlannedWorkouts() async {
    final rows = await _db.rawQuery('''
      SELECT
        pw.id,
        pw.user_id,
        pw.workout_template_id,
        pw.planned_date,
        pw.planned_time,
        pw.notes,
        up.display_name,
        up.username,
        up.avatar_url,
        wt.name AS template_name
      FROM planned_workout pw
      JOIN user_profile up ON pw.user_id = up.id
      JOIN workout_template wt ON pw.workout_template_id = wt.id
      WHERE pw.planned_date = CAST(strftime('%s', 'now', 'start of day') AS INTEGER)
      ORDER BY
        CASE WHEN pw.planned_time IS NULL THEN 1 ELSE 0 END,
        pw.planned_time ASC,
        up.display_name ASC
    ''');

    return rows.map(DbPlannedWorkout.fromRow).toList();
  }

  /// Checks whether the current user has liked a given feed item.
  Future<bool> hasCurrentUserLiked(String feedItemId) async {
    final rows = await _db.rawQuery('''
      SELECT 1
      FROM feed_like fl
      JOIN user_profile up ON fl.user_id = up.id
      WHERE fl.feed_item_id = ? AND up.is_current_user = 1
      LIMIT 1
    ''', [feedItemId]);
    return rows.isNotEmpty;
  }
}
