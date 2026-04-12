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

  /// Friends and their current streaks.
  static const List<({String name, int streak, bool activeToday})> friends = [
    (name: 'Erik', streak: 45, activeToday: true),
    (name: 'Marte', streak: 30, activeToday: true),
    (name: 'Silje', streak: 18, activeToday: false),
    (name: 'Kristian', streak: 7, activeToday: true),
    (name: 'Jonas', streak: 3, activeToday: false),
    (name: 'Hanna', streak: 0, activeToday: false),
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
  static List<({String name, int streak, bool activeToday, bool isMe})> get _allEntries {
    final entries = <({String name, int streak, bool activeToday, bool isMe})>[
      (name: 'You', streak: _StreakData.currentStreak, activeToday: true, isMe: true),
      ..._StreakData.friends.map((f) =>
          (name: f.name, streak: f.streak, activeToday: f.activeToday, isMe: false)),
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
            child: _StreakRow(
              name: entry.name,
              streak: entry.streak,
              activeToday: entry.activeToday,
              isMe: entry.isMe,
            ),
          );
        }),
      ],
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
