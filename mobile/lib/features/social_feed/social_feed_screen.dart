import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/dao/feed_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_feed_comment.dart';
import '../../data/models/db_feed_item.dart';
import '../../data/models/db_planned_workout.dart';
import '../../data/models/feed_item_type.dart';
import '../../style/app_style.dart';

/// Social feed screen — a scrollable list of feed cards showing workout
/// completions, personal records, and streak milestones from friends.
class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  late final FeedDao _feedDao;
  List<DbFeedItem>? _items;
  List<DbPlannedWorkout>? _plannedWorkouts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _feedDao = FeedDao(widget.database.raw);
    _loadFeed();
    _loadPlannedWorkouts();
  }

  Future<void> _loadFeed() async {
    try {
      final items = await _feedDao.loadFeed();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _loadPlannedWorkouts() async {
    try {
      final workouts = await _feedDao.loadTodaysPlannedWorkouts();
      if (mounted) setState(() => _plannedWorkouts = workouts);
    } catch (_) {
      // Non-critical — feed still works without the Stories row.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.feedBackground,
      appBar: AppBar(
        backgroundColor: AppStyle.scaffoldBackground,
        title: const Text(
          'Feed',
          style: TextStyle(
            color: AppStyle.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppStyle.screenPadding,
          child: Text(
            'Failed to load feed:\n$_error',
            style: AppStyle.captionStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items!.isEmpty) {
      return const Center(
        child: Text('No feed items yet.', style: AppStyle.captionStyle),
      );
    }
    final hasStories =
        _plannedWorkouts != null && _plannedWorkouts!.isNotEmpty;
    // +1 for the Stories row when present.
    final itemCount = _items!.length + (hasStories ? 1 : 0);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapL,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppStyle.gapM),
      itemBuilder: (context, index) {
        if (hasStories && index == 0) {
          return _StoriesRow(workouts: _plannedWorkouts!);
        }
        final feedIndex = hasStories ? index - 1 : index;
        return _FeedCard(
          item: _items![feedIndex],
          feedDao: _feedDao,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Feed card
// ---------------------------------------------------------------------------

class _FeedCard extends StatefulWidget {
  const _FeedCard({required this.item, required this.feedDao});

  final DbFeedItem item;
  final FeedDao feedDao;

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _expanded = false;
  List<DbFeedComment>? _comments;

  DbFeedItem get item => widget.item;

  void _toggleComments() async {
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }
    if (_comments == null && item.commentCount > 0) {
      final comments = await widget.feedDao.loadComments(item.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _expanded = true;
      });
    } else {
      setState(() => _expanded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(item.itemType);
    final tintColor = _tintColor(item.itemType);

    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: AppStyle.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: avatar, name, timestamp, badge
                _buildHeader(accentColor, tintColor),
                const SizedBox(height: AppStyle.gapM),

                // Title
                Text(item.title, style: AppStyle.feedTitleStyle),
                if (item.description != null) ...[
                  const SizedBox(height: AppStyle.gapXS),
                  Text(item.description!, style: AppStyle.feedDescriptionStyle),
                ],

                // Metric pill
                if (item.formattedMetric != null) ...[
                  const SizedBox(height: AppStyle.gapM),
                  _buildMetricPill(accentColor, tintColor),
                ],

                // Actions row
                const SizedBox(height: AppStyle.gapM),
                _buildActionsRow(),
              ],
            ),
          ),

          // Expanded comments section
          if (_expanded && _comments != null && _comments!.isNotEmpty) ...[
            const Divider(height: 1, color: AppStyle.dividerColor),
            _buildCommentsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Color accentColor, Color tintColor) {
    return Row(
      children: [
        // Avatar circle with initials
        _AvatarCircle(
          initials: item.userInitials,
          color: accentColor,
          size: 40,
        ),
        const SizedBox(width: AppStyle.gapM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.userDisplayName,
                      style: AppStyle.feedUserNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppStyle.gapS),
                  Text(
                    '@${item.username}',
                    style: AppStyle.feedUsernameHandle,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _relativeTimestamp(item.occurredAt),
                style: AppStyle.feedTimestampStyle,
              ),
            ],
          ),
        ),
        // Item type badge
        _buildBadge(accentColor),
      ],
    );
  }

  Widget _buildBadge(Color color) {
    final (label, icon) = switch (item.itemType) {
      FeedItemType.workoutCompleted => ('Workout', Icons.fitness_center),
      FeedItemType.personalRecord => ('PR', Icons.emoji_events),
      FeedItemType.streakMilestone => ('Streak', Icons.local_fire_department),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppStyle.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: AppStyle.feedBadgeStyle),
        ],
      ),
    );
  }

  Widget _buildMetricPill(Color accentColor, Color tintColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: AppStyle.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _metricValueOnly(),
            style: AppStyle.feedMetricStyle.copyWith(color: accentColor),
          ),
          if (item.metricUnit != null) ...[
            const SizedBox(width: 6),
            Text(
              item.metricUnit!,
              style: AppStyle.feedMetricUnitStyle.copyWith(color: accentColor),
            ),
          ],
        ],
      ),
    );
  }

  String _metricValueOnly() {
    if (item.metricValue == null) return '';
    final v = item.metricValue!;
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        // Like button
        _ActionChip(
          icon: Icons.favorite_border,
          iconColor: item.likeCount > 0 ? AppStyle.heartRed : AppStyle.textSecondary,
          label: item.likeCount > 0 ? item.likeCount.toString() : '',
          onTap: () {},
        ),
        const SizedBox(width: AppStyle.gapL),
        // Comment button
        _ActionChip(
          icon: Icons.chat_bubble_outline,
          iconColor: AppStyle.textSecondary,
          label: item.commentCount > 0 ? item.commentCount.toString() : '',
          onTap: item.commentCount > 0 ? _toggleComments : null,
        ),
        const Spacer(),
        // Relative time repeated for context on card scroll
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _comments!.length; i++) ...[
            if (i > 0) const SizedBox(height: AppStyle.gapS),
            _CommentRow(comment: _comments![i]),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Color _accentColor(FeedItemType type) => switch (type) {
        FeedItemType.workoutCompleted => AppStyle.primaryBlue,
        FeedItemType.personalRecord => AppStyle.prGold,
        FeedItemType.streakMilestone => AppStyle.streakGreen,
      };

  static Color _tintColor(FeedItemType type) => switch (type) {
        FeedItemType.workoutCompleted => AppStyle.workoutBlueTint,
        FeedItemType.personalRecord => AppStyle.prGoldTint,
        FeedItemType.streakMilestone => AppStyle.streakGreenTint,
      };

  static String _relativeTimestamp(int epochSeconds) {
    final now = DateTime.now();
    final then = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final diff = now.difference(then);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

// ---------------------------------------------------------------------------
// Avatar circle
// ---------------------------------------------------------------------------

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.initials,
    required this.color,
    this.size = 40,
  });

  final String initials;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stories row — "Who's working out today"
// ---------------------------------------------------------------------------

class _StoriesRow extends StatelessWidget {
  const _StoriesRow({required this.workouts});

  final List<DbPlannedWorkout> workouts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: AppStyle.gapS),
          child: Text('Working out today', style: AppStyle.storiesLabelStyle),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: workouts.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppStyle.gapM),
            itemBuilder: (context, index) =>
                _StoryAvatar(workout: workouts[index]),
          ),
        ),
      ],
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({required this.workout});

  final DbPlannedWorkout workout;

  void _showPopover(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final avatarCenter = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, 0),
      ancestor: overlay,
    );

    showMenu<void>(
      context: context,
      // Position just above the avatar.
      position: RelativeRect.fromLTRB(
        avatarCenter.dx - 100,
        avatarCenter.dy - 8,
        avatarCenter.dx + 100,
        avatarCenter.dy,
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: AppStyle.cardRadius),
      color: AppStyle.popoverBackground,
      elevation: 8,
      shadowColor: AppStyle.popoverShadow,
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(workout.userDisplayName, style: AppStyle.popoverNameStyle),
              const SizedBox(height: AppStyle.gapXS),
              Row(
                children: [
                  const Icon(Icons.fitness_center,
                      size: 14, color: AppStyle.primaryBlue),
                  const SizedBox(width: AppStyle.gapXS),
                  Flexible(
                    child: Text(workout.workoutTemplateName,
                        style: AppStyle.popoverWorkoutStyle,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: AppStyle.gapXS),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 14, color: AppStyle.textSecondary),
                  const SizedBox(width: AppStyle.gapXS),
                  Text(
                    workout.formattedTime ?? 'No time set',
                    style: AppStyle.popoverDetailStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopover(context),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GradientRingAvatar(
              initials: workout.userInitials,
              size: 56,
            ),
            const SizedBox(height: AppStyle.gapXS),
            Text(
              workout.username,
              style: AppStyle.storiesUsernameStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar wrapped in a gradient ring, Instagram Stories style.
class _GradientRingAvatar extends StatelessWidget {
  const _GradientRingAvatar({required this.initials, this.size = 56});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    const ringWidth = 2.5;
    const gapWidth = 2.0;
    final innerSize = size - (ringWidth + gapWidth) * 2;

    return CustomPaint(
      painter: _GradientRingPainter(
        ringWidth: ringWidth,
        colors: const [AppStyle.storiesRingStart, AppStyle.storiesRingEnd],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: _AvatarCircle(
            initials: initials,
            color: AppStyle.primaryBlue,
            size: innerSize,
          ),
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.ringWidth, required this.colors});

  final double ringWidth;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(colors: colors).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;
    final radius = math.min(size.width, size.height) / 2 - ringWidth / 2;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  bool shouldRepaint(_GradientRingPainter old) =>
      ringWidth != old.ringWidth || colors != old.colors;
}

// ---------------------------------------------------------------------------
// Action chip (like / comment)
// ---------------------------------------------------------------------------

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(label, style: AppStyle.feedActionStyle),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comment row
// ---------------------------------------------------------------------------

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final DbFeedComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarCircle(
          initials: comment.userInitials,
          color: AppStyle.textSecondary,
          size: 28,
        ),
        const SizedBox(width: AppStyle.gapS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.userDisplayName,
                    style: AppStyle.feedCommentAuthorStyle,
                  ),
                  const SizedBox(width: AppStyle.gapS),
                  Text(
                    _relativeTimestamp(comment.createdAt),
                    style: AppStyle.feedTimestampStyle,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(comment.body, style: AppStyle.feedCommentBodyStyle),
            ],
          ),
        ),
      ],
    );
  }

  static String _relativeTimestamp(int epochSeconds) {
    final now = DateTime.now();
    final then = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
