import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home page scaffolding concept — explores what the main landing screen
/// of the app should look like. All data is hardcoded dummy data; the goal
/// is layout exploration, not data integration.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: ListView(
        padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapL, bottom: 40.0),
          children: const [
            _GreetingHeader(),
            SizedBox(height: AppStyle.gapXL),
            _TodaysWorkoutCard(),
            SizedBox(height: AppStyle.gapL),
            _WeekProgressStrip(),
            SizedBox(height: AppStyle.gapXL),
            _QuickActions(),
            SizedBox(height: AppStyle.gapXL),
            _FriendsActivitySection(),
            SizedBox(height: AppStyle.gapXL),
            _RecentStatsRow(),
          ],
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting header — time-of-day greeting + streak badge
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: AppStyle.captionStyle.copyWith(fontSize: 15.0),
              ),
              const SizedBox(height: AppStyle.gapXS),
              const Text(
                'Jørgen',
                style: TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppStyle.streakOrangeTint,
            borderRadius: AppStyle.pillRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.local_fire_department_rounded,
                  color: AppStyle.streakOrange, size: 20.0),
              SizedBox(width: AppStyle.gapXS),
              Text(
                '12',
                style: TextStyle(
                  color: AppStyle.streakOrange,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Today's workout card — the most important thing on the home page
// ---------------------------------------------------------------------------

class _TodaysWorkoutCard extends StatelessWidget {
  const _TodaysWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyle.gapL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.primaryBlue.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center,
                    color: AppStyle.primaryBlue, size: 20.0),
              ),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCHEDULED TODAY',
                      style: AppStyle.captionStyle.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppStyle.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppStyle.gapXS),
                    const Text(
                      'Push Day',
                      style: TextStyle(
                        color: AppStyle.textPrimary,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Exercise preview chips
          Wrap(
            spacing: AppStyle.gapS,
            runSpacing: AppStyle.gapS,
            children: const [
              _ExerciseChip('Bench Press'),
              _ExerciseChip('OHP'),
              _ExerciseChip('Incline DB'),
              _ExerciseChip('Tricep Pushdown'),
              _ExerciseChip('+2 more'),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Start workout button
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                color: AppStyle.primaryBlue,
                borderRadius: AppStyle.pillRadius,
              ),
              child: const Text(
                'Start Workout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: AppStyle.pillRadius,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppStyle.textPrimary,
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week progress strip — Mon-Sun with today highlighted
// ---------------------------------------------------------------------------

class _WeekProgressStrip extends StatelessWidget {
  const _WeekProgressStrip();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // Mon, Tue done; Wed planned (today); Thu, Sat planned
  static const _done = [true, false, true, true, false, false, false];
  static const _planned = [true, false, true, true, false, true, false];
  static const int _todayIndex = 5; // Saturday

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('This week',
                style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('3 of 4 workouts',
                style: AppStyle.captionStyle.copyWith(
                  color: AppStyle.primaryBlue,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        const SizedBox(height: AppStyle.gapM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final done = _done[i];
            final planned = _planned[i];
            final isToday = i == _todayIndex;
            return Column(
              children: [
                Text(_days[i],
                    style: AppStyle.weekdayLabelStyle.copyWith(
                      color: isToday ? AppStyle.primaryBlue : AppStyle.textSecondary,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    )),
                const SizedBox(height: AppStyle.gapS),
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: done
                        ? AppStyle.finishGreen
                        : isToday
                            ? AppStyle.primaryBlue
                            : planned
                                ? AppStyle.cardBorder
                                : AppStyle.streakInactiveDay,
                    shape: BoxShape.circle,
                    border: isToday && !done
                        ? Border.all(color: AppStyle.primaryBlue, width: 2.0)
                        : null,
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20.0)
                      : isToday
                          ? const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 20.0)
                          : planned
                              ? const Icon(Icons.circle_outlined,
                                  color: AppStyle.textSecondary, size: 14.0)
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
// Quick actions — shortcut buttons
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions',
            style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        Row(
          children: const [
            Expanded(
                child: _QuickActionTile(
              icon: Icons.add_rounded,
              label: 'Empty\nworkout',
              color: AppStyle.primaryBlue,
            )),
            SizedBox(width: AppStyle.gapM),
            Expanded(
                child: _QuickActionTile(
              icon: Icons.straighten,
              label: 'Log\nmeasurement',
              color: AppStyle.warmupOrange,
            )),
            SizedBox(width: AppStyle.gapM),
            Expanded(
                child: _QuickActionTile(
              icon: Icons.emoji_events_rounded,
              label: 'View\ncompetitions',
              color: AppStyle.dropSetPurple,
            )),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

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
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.0),
          ),
          const SizedBox(height: AppStyle.gapS),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Friends activity — who's been active recently
// ---------------------------------------------------------------------------

class _FriendsActivitySection extends StatelessWidget {
  const _FriendsActivitySection();

  static const _friends = [
    (name: 'Erik', workout: 'Pull Day', time: '2h ago', active: true),
    (name: 'Marte', workout: 'Running', time: '5h ago', active: false),
    (name: 'Kristian', workout: 'Full Body', time: 'Yesterday', active: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Friends',
                style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('See all',
                style: AppStyle.captionStyle.copyWith(
                  color: AppStyle.primaryBlue,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        const SizedBox(height: AppStyle.gapM),
        for (var i = 0; i < _friends.length; i++) ...[
          _FriendActivityRow(
            name: _friends[i].name,
            workout: _friends[i].workout,
            time: _friends[i].time,
            active: _friends[i].active,
          ),
          if (i < _friends.length - 1) const SizedBox(height: AppStyle.gapS),
        ],
      ],
    );
  }
}

class _FriendActivityRow extends StatelessWidget {
  const _FriendActivityRow({
    required this.name,
    required this.workout,
    required this.time,
    required this.active,
  });

  final String name;
  final String workout;
  final String time;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.gapL, vertical: AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: active ? AppStyle.finishGreen.withAlpha(30) : AppStyle.streakInactiveDay,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name[0],
              style: TextStyle(
                color: active ? AppStyle.finishGreen : AppStyle.textSecondary,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppStyle.textPrimary,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  workout,
                  style: AppStyle.captionStyle,
                ),
              ],
            ),
          ),
          // Active dot
          if (active)
            Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.only(right: AppStyle.gapS),
              decoration: const BoxDecoration(
                color: AppStyle.finishGreen,
                shape: BoxShape.circle,
              ),
            ),
          Text(time, style: AppStyle.captionStyle),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent stats row — body weight trend, PR count, competition rank
// ---------------------------------------------------------------------------

class _RecentStatsRow extends StatelessWidget {
  const _RecentStatsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your stats',
            style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        Row(
          children: const [
            Expanded(
              child: _MiniStatCard(
                label: 'Weight',
                value: '82.3 kg',
                trend: '-0.4',
                trendPositive: true,
              ),
            ),
            SizedBox(width: AppStyle.gapM),
            Expanded(
              child: _MiniStatCard(
                label: 'PRs this month',
                value: '3',
                trend: null,
                trendPositive: true,
              ),
            ),
            SizedBox(width: AppStyle.gapM),
            Expanded(
              child: _MiniStatCard(
                label: 'Comp rank',
                value: '#2',
                trend: null,
                trendPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  final String label;
  final String value;
  final String? trend;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyle.captionStyle),
          const SizedBox(height: AppStyle.gapS),
          Text(
            value,
            style: const TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppStyle.gapXS),
            Text(
              trend!,
              style: TextStyle(
                color: trendPositive ? AppStyle.finishGreen : AppStyle.failureRed,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
