import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// Dummy streak data for the concept screen.
class _StreakData {
  _StreakData._();

  static const int currentStreak = 12;
  static const int longestStreak = 23;
  static const int totalThisMonth = 16;
  static const int totalThisWeek = 4;

  /// Which days of the current week had a workout (Mon=0 .. Sun=6).
  static const List<bool> thisWeek = [true, false, true, true, false, true, false];

  /// Friends and their current streaks with recent workout history.
  static const List<({
    String name,
    int streak,
    bool activeToday,
    int longest,
    List<String> recentWorkouts,
    List<bool> thisWeek,
  })> friends = [
    (
      name: 'Erik',
      streak: 45,
      activeToday: true,
      longest: 60,
      recentWorkouts: ['Pull Day', 'Legs', 'Push Day', 'Cardio', 'Pull Day'],
      thisWeek: [true, true, true, true, true, false, false],
    ),
    (
      name: 'Marte',
      streak: 30,
      activeToday: true,
      longest: 30,
      recentWorkouts: ['Upper Body', 'Running', 'Yoga', 'Lower Body'],
      thisWeek: [true, false, true, true, false, false, false],
    ),
    (
      name: 'Silje',
      streak: 18,
      activeToday: false,
      longest: 22,
      recentWorkouts: ['Push Day', 'Legs', 'Pull Day'],
      thisWeek: [true, false, true, false, false, false, false],
    ),
    (
      name: 'Kristian',
      streak: 7,
      activeToday: true,
      longest: 14,
      recentWorkouts: ['Full Body', 'Cardio', 'Full Body'],
      thisWeek: [true, false, false, true, false, false, false],
    ),
    (
      name: 'Jonas',
      streak: 3,
      activeToday: false,
      longest: 11,
      recentWorkouts: ['Push Day', 'Pull Day'],
      thisWeek: [true, false, true, false, false, false, false],
    ),
    (
      name: 'Hanna',
      streak: 0,
      activeToday: false,
      longest: 8,
      recentWorkouts: [],
      thisWeek: [false, false, false, false, false, false, false],
    ),
  ];

  /// 12 weeks of activity for the heatmap.
  /// Each inner list is Mon-Sun, value 0-4 (intensity level).
  static const List<List<int>> heatmap = [
    [0, 1, 0, 2, 0, 1, 0],
    [1, 0, 2, 0, 3, 0, 0],
    [0, 2, 0, 3, 0, 2, 0],
    [2, 0, 3, 0, 2, 0, 1],
    [0, 3, 0, 2, 0, 3, 0],
    [1, 0, 2, 0, 3, 0, 0],
    [0, 2, 0, 4, 0, 2, 0],
    [3, 0, 2, 0, 3, 0, 1],
    [0, 3, 0, 3, 0, 4, 0],
    [2, 0, 4, 0, 3, 0, 0],
    [0, 3, 0, 4, 0, 3, 0],
    [3, 0, 3, 0, 4, 0, 2],
  ];

  static const List<String> heatmapMonths = [
    'Jan', 'Feb', 'Mar',
  ];

  /// Month label positions (column index where label appears).
  static const List<int> monthColumns = [0, 4, 8];
}

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      body: ListView(
        padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapL, bottom: 40.0),
        children: const [
          _FriendsSection(),
          SizedBox(height: AppStyle.gapXL),
          _CurrentStreakCard(),
          SizedBox(height: AppStyle.gapL),
          _WeeklyActivityStrip(),
          SizedBox(height: AppStyle.gapXL),
          _StatsRow(),
          SizedBox(height: AppStyle.gapXL),
          _ActivityHeatmap(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current streak hero card
// ---------------------------------------------------------------------------

class _CurrentStreakCard extends StatelessWidget {
  const _CurrentStreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: AppStyle.gapL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.streakOrange.withAlpha(51)),
      ),
      child: Column(
        children: [
          // Flame icon
          Container(
            width: 56.0,
            height: 56.0,
            decoration: const BoxDecoration(
              color: AppStyle.streakOrangeTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded,
                color: AppStyle.streakOrange, size: 32.0),
          ),
          const SizedBox(height: AppStyle.gapM),
          const Text(
            '${_StreakData.currentStreak}',
            style: AppStyle.streakCountStyle,
          ),
          const SizedBox(height: AppStyle.gapXS),
          const Text('day streak', style: AppStyle.streakLabelStyle),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly activity strip (Mon – Sun dots)
// ---------------------------------------------------------------------------

class _WeeklyActivityStrip extends StatelessWidget {
  const _WeeklyActivityStrip();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This week', style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final active = _StreakData.thisWeek[i];
            return Column(
              children: [
                Text(_days[i], style: AppStyle.weekdayLabelStyle),
                const SizedBox(height: AppStyle.gapS),
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: active ? AppStyle.streakOrange : AppStyle.streakInactiveDay,
                    shape: BoxShape.circle,
                  ),
                  child: active
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20.0)
                      : null,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row — longest / this month / this week
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatTile(value: '${_StreakData.longestStreak}', label: 'Longest')),
        Expanded(child: _StatTile(value: '${_StreakData.totalThisMonth}', label: 'This month')),
        Expanded(child: _StatTile(value: '${_StreakData.totalThisWeek}', label: 'This week')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyle.streakStatValueStyle),
          const SizedBox(height: AppStyle.gapXS),
          Text(label, style: AppStyle.streakStatCaptionStyle),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Friends' streaks
// ---------------------------------------------------------------------------

class _FriendsSection extends StatelessWidget {
  const _FriendsSection();

  /// All entries: the user ("You") merged with friends, sorted by streak desc.
  static List<({
    String name, int streak, bool activeToday, bool isMe,
    int longest, List<String> recentWorkouts, List<bool> thisWeek,
  })> get _allEntries {
    final entries = <({
      String name, int streak, bool activeToday, bool isMe,
      int longest, List<String> recentWorkouts, List<bool> thisWeek,
    })>[
      (
        name: 'You',
        streak: _StreakData.currentStreak,
        activeToday: true,
        isMe: true,
        longest: _StreakData.longestStreak,
        recentWorkouts: const ['Push Day', 'Legs', 'Pull Day', 'Push Day'],
        thisWeek: _StreakData.thisWeek,
      ),
      ..._StreakData.friends.map((f) => (
        name: f.name,
        streak: f.streak,
        activeToday: f.activeToday,
        isMe: false,
        longest: f.longest,
        recentWorkouts: f.recentWorkouts,
        thisWeek: f.thisWeek,
      )),
    ];
    entries.sort((a, b) => b.streak.compareTo(a.streak));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _allEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Streaks', style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        ...List.generate(entries.length, (i) {
          final entry = entries[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < entries.length - 1 ? AppStyle.gapS : 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showStreakDetail(context, entry),
              child: _StreakRow(
                name: entry.name,
                streak: entry.streak,
                activeToday: entry.activeToday,
                isMe: entry.isMe,
              ),
            ),
          );
        }),
      ],
    );
  }

  static void _showStreakDetail(BuildContext context, dynamic entry) {
    final String name = entry.name;
    final int streak = entry.streak;
    final bool isMe = entry.isMe;
    final int longest = entry.longest;
    final List<String> recentWorkouts = entry.recentWorkouts;
    final List<bool> thisWeek = entry.thisWeek;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StreakDetailSheet(
        name: name,
        streak: streak,
        isMe: isMe,
        longest: longest,
        recentWorkouts: recentWorkouts,
        thisWeek: thisWeek,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak detail bottom sheet
// ---------------------------------------------------------------------------

class _StreakDetailSheet extends StatelessWidget {
  const _StreakDetailSheet({
    required this.name,
    required this.streak,
    required this.isMe,
    required this.longest,
    required this.recentWorkouts,
    required this.thisWeek,
  });

  final String name;
  final int streak;
  final bool isMe;
  final int longest;
  final List<String> recentWorkouts;
  final List<bool> thisWeek;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.sheetRadius,
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: AppStyle.streakInactiveDay,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: AppStyle.gapXL),

          // Avatar + name
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: isMe
                  ? AppStyle.streakOrange
                  : streak > 0
                      ? AppStyle.streakOrangeTint
                      : AppStyle.streakInactiveDay,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isMe
                ? const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 28.0)
                : Text(
                    name[0],
                    style: TextStyle(
                      color: streak > 0 ? AppStyle.streakOrange : AppStyle.textSecondary,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: AppStyle.gapM),
          Text(name, style: AppStyle.sheetTitleStyle),
          const SizedBox(height: AppStyle.gapXL),

          // Streak + longest row
          Row(
            children: [
              Expanded(
                child: _DetailStat(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppStyle.streakOrange,
                  value: '$streak',
                  label: 'Current streak',
                ),
              ),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: _DetailStat(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFAB40),
                  value: '$longest',
                  label: 'Longest streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapXL),

          // This week strip
          Align(
            alignment: Alignment.centerLeft,
            child: Text('This week',
                style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppStyle.gapM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = thisWeek[i];
              return Column(
                children: [
                  Text(_days[i], style: AppStyle.weekdayLabelStyle),
                  const SizedBox(height: AppStyle.gapS),
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: active ? AppStyle.streakOrange : AppStyle.streakInactiveDay,
                      shape: BoxShape.circle,
                    ),
                    child: active
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20.0)
                        : null,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: AppStyle.gapXL),

          // Recent workouts
          if (recentWorkouts.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent workouts',
                  style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppStyle.gapM),
            Wrap(
              spacing: AppStyle.gapS,
              runSpacing: AppStyle.gapS,
              children: recentWorkouts.map((w) => Container(
                padding: AppStyle.pillPadding,
                decoration: BoxDecoration(
                  color: AppStyle.streakOrangeTint,
                  borderRadius: AppStyle.pillRadius,
                ),
                child: Text(
                  w,
                  style: const TextStyle(
                    color: AppStyle.streakOrange,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: AppStyle.cardPadding,
              decoration: BoxDecoration(
                color: AppStyle.streakInactiveDay.withAlpha(128),
                borderRadius: AppStyle.cardRadius,
              ),
              child: const Text(
                'No recent workouts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppStyle.textSecondary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppStyle.gapL, horizontal: AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24.0),
          const SizedBox(height: AppStyle.gapS),
          Text(value, style: AppStyle.streakStatValueStyle),
          const SizedBox(height: AppStyle.gapXS),
          Text(label, style: AppStyle.streakStatCaptionStyle),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.name,
    required this.streak,
    required this.activeToday,
    required this.isMe,
  });

  final String name;
  final int streak;
  final bool activeToday;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.gapL, vertical: AppStyle.gapM),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFF8F0) : AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(
          color: isMe ? AppStyle.streakOrange.withAlpha(77) : AppStyle.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isMe
                  ? AppStyle.streakOrange
                  : streak > 0
                      ? AppStyle.streakOrangeTint
                      : AppStyle.streakInactiveDay,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isMe
                ? const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 20.0)
                : Text(
                    name[0],
                    style: TextStyle(
                      color: streak > 0 ? AppStyle.streakOrange : AppStyle.textSecondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: AppStyle.gapM),
          // Name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: AppStyle.textPrimary,
                fontSize: isMe ? 16.0 : 15.0,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          // Active-today dot
          if (activeToday)
            Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.only(right: AppStyle.gapS),
              decoration: const BoxDecoration(
                color: AppStyle.finishGreen,
                shape: BoxShape.circle,
              ),
            ),
          // Streak count + flame
          if (streak > 0) ...[
            Text(
              '$streak',
              style: TextStyle(
                color: AppStyle.streakOrange,
                fontSize: isMe ? 20.0 : 17.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppStyle.gapXS),
            Icon(Icons.local_fire_department_rounded,
                color: AppStyle.streakOrange, size: isMe ? 20.0 : 18.0),
          ] else
            const Text(
              '—',
              style: TextStyle(
                color: AppStyle.textSecondary,
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity heatmap (GitHub-style contribution grid)
// ---------------------------------------------------------------------------

class _ActivityHeatmap extends StatelessWidget {
  const _ActivityHeatmap();

  static const double _cellSize = 22.0;
  static const double _cellGap = 3.0;

  Color _colorForLevel(int level) {
    switch (level) {
      case 1:
        return AppStyle.heatmapLevel1;
      case 2:
        return AppStyle.heatmapLevel2;
      case 3:
        return AppStyle.heatmapLevel3;
      case 4:
        return AppStyle.heatmapLevel4;
      default:
        return AppStyle.heatmapLevel0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity', style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),

        // Month labels
        SizedBox(
          height: 16.0,
          child: Row(
            children: List.generate(_StreakData.heatmap.length, (col) {
              final monthIdx = _StreakData.monthColumns.indexOf(col);
              return SizedBox(
                width: _cellSize + _cellGap,
                child: monthIdx != -1
                    ? Text(_StreakData.heatmapMonths[monthIdx], style: AppStyle.heatmapMonthStyle)
                    : null,
              );
            }),
          ),
        ),
        const SizedBox(height: AppStyle.gapXS),

        // Grid: 7 rows (Mon-Sun) x 12 columns (weeks)
        Column(
          children: List.generate(7, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 6 ? _cellGap : 0),
              child: Row(
                children: List.generate(_StreakData.heatmap.length, (col) {
                  final level = _StreakData.heatmap[col][row];
                  return Padding(
                    padding: EdgeInsets.only(right: col < _StreakData.heatmap.length - 1 ? _cellGap : 0),
                    child: Container(
                      width: _cellSize,
                      height: _cellSize,
                      decoration: BoxDecoration(
                        color: _colorForLevel(level),
                        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        const SizedBox(height: AppStyle.gapS),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less', style: AppStyle.heatmapMonthStyle),
            const SizedBox(width: AppStyle.gapXS),
            for (final level in [0, 1, 2, 3, 4])
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: _colorForLevel(level),
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                  ),
                ),
              ),
            const SizedBox(width: AppStyle.gapXS),
            const Text('More', style: AppStyle.heatmapMonthStyle),
          ],
        ),
      ],
    );
  }
}
