import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home variant A — "dashboard-first" layout.
///
/// Design philosophy: information density meets calm. The user opens the app
/// and immediately sees their current state at a glance, inspired by Apple
/// Health and Fitbit dashboards.
///
/// All data is hardcoded dummy data — layout exploration only.
class HomeVariantA extends StatelessWidget {
  const HomeVariantA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Variant A — Dashboard'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: ListView(
        padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapM, bottom: 40.0),
          children: const [
            _CompactHeader(),
            SizedBox(height: AppStyle.gapL),
            _TodaysPlanHero(),
            SizedBox(height: AppStyle.gapL),
            _StatsRibbon(),
            SizedBox(height: AppStyle.gapXL),
            _ActivityTimeline(),
            SizedBox(height: AppStyle.gapXL),
            _UpcomingSection(),
          ],
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Compact header — greeting + avatar left, streak flame badge right
// ---------------------------------------------------------------------------

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40.0,
          height: 40.0,
          decoration: const BoxDecoration(
            color: AppStyle.primaryBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'J',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.0,
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
                'Good morning',
                style: AppStyle.captionStyle.copyWith(fontSize: 13.0),
              ),
              const SizedBox(height: 2.0),
              const Text(
                'Jorgen',
                style: TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Streak flame badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: AppStyle.streakOrangeTint,
            borderRadius: AppStyle.pillRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.local_fire_department_rounded,
                  color: AppStyle.streakOrange, size: 18.0),
              SizedBox(width: AppStyle.gapXS),
              Text(
                '12',
                style: TextStyle(
                  color: AppStyle.streakOrange,
                  fontSize: 16.0,
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
// 2. Today's plan hero — full-width card, THE most important element
// ---------------------------------------------------------------------------

class _TodaysPlanHero extends StatelessWidget {
  const _TodaysPlanHero();

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
          // Label + time estimate row
          Row(
            children: [
              Text(
                'TODAY\'S PLAN',
                style: AppStyle.captionStyle.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppStyle.primaryBlue,
                ),
              ),
              const Spacer(),
              const Icon(Icons.schedule_rounded,
                  color: AppStyle.textSecondary, size: AppStyle.metaIconSize),
              const SizedBox(width: AppStyle.gapXS),
              Text(
                '~55 min',
                style: AppStyle.captionStyle.copyWith(fontSize: 12.0),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapS),
          // Workout name
          const Text(
            'Push Day',
            style: TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppStyle.gapXS),
          Text(
            '6 exercises  ·  Bench Press, OHP, Incline DB +3',
            style: AppStyle.captionStyle.copyWith(fontSize: 13.0),
          ),
          const SizedBox(height: AppStyle.gapL),
          // Start button
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                color: AppStyle.primaryBlue,
                borderRadius: AppStyle.pillRadius,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20.0),
                  SizedBox(width: AppStyle.gapS),
                  Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Stats ribbon — horizontal scrollable row of mini stat cards
// ---------------------------------------------------------------------------

class _StatsRibbon extends StatelessWidget {
  const _StatsRibbon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: const [
          _RibbonCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppStyle.streakOrange,
            label: 'Streak',
            value: '12 days',
          ),
          SizedBox(width: AppStyle.gapM),
          _RibbonCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppStyle.finishGreen,
            label: 'This week',
            value: '3 of 4',
          ),
          SizedBox(width: AppStyle.gapM),
          _RibbonCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: AppStyle.primaryBlue,
            label: 'Weight',
            value: '82.3 kg',
            trend: '-0.4',
          ),
          SizedBox(width: AppStyle.gapM),
          _RibbonCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppStyle.dropSetPurple,
            label: 'Competitions',
            value: '2 active',
          ),
        ],
      ),
    );
  }
}

class _RibbonCard extends StatelessWidget {
  const _RibbonCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trend,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136.0,
      padding: const EdgeInsets.all(AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: AppStyle.smallIconSize),
              const SizedBox(width: AppStyle.gapXS),
              Expanded(
                child: Text(
                  label,
                  style: AppStyle.captionStyle.copyWith(fontSize: 12.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppStyle.textPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: AppStyle.gapXS),
                Text(
                  trend!,
                  style: const TextStyle(
                    color: AppStyle.finishGreen,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Activity timeline — recent events from friends and personal milestones
// ---------------------------------------------------------------------------

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  static const _events = [
    _TimelineEvent(
      avatar: 'E',
      avatarColor: AppStyle.finishGreen,
      text: 'Erik finished Pull Day',
      time: '2h ago',
      type: _EventType.friend,
    ),
    _TimelineEvent(
      avatar: null,
      avatarColor: AppStyle.warmupOrange,
      text: 'You hit a PR on Bench Press',
      time: 'Yesterday',
      type: _EventType.pr,
    ),
    _TimelineEvent(
      avatar: 'M',
      avatarColor: AppStyle.dropSetPurple,
      text: 'Marte started a new competition',
      time: 'Yesterday',
      type: _EventType.friend,
    ),
    _TimelineEvent(
      avatar: 'K',
      avatarColor: AppStyle.primaryBlue,
      text: 'Kristian completed Full Body',
      time: '2 days ago',
      type: _EventType.friend,
    ),
    _TimelineEvent(
      avatar: null,
      avatarColor: AppStyle.streakOrange,
      text: 'You reached a 10-day streak',
      time: '3 days ago',
      type: _EventType.milestone,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Activity',
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
        for (var i = 0; i < _events.length; i++) ...[
          _TimelineRow(event: _events[i], isLast: i == _events.length - 1),
        ],
      ],
    );
  }
}

enum _EventType { friend, pr, milestone }

class _TimelineEvent {
  const _TimelineEvent({
    required this.avatar,
    required this.avatarColor,
    required this.text,
    required this.time,
    required this.type,
  });

  final String? avatar;
  final Color avatarColor;
  final String text;
  final String time;
  final _EventType type;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.isLast});

  final _TimelineEvent event;
  final bool isLast;

  IconData get _eventIcon {
    switch (event.type) {
      case _EventType.friend:
        return Icons.fitness_center;
      case _EventType.pr:
        return Icons.emoji_events_rounded;
      case _EventType.milestone:
        return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 40.0,
            child: Column(
              children: [
                // Dot / avatar
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: event.avatarColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: event.avatar != null
                      ? Text(
                          event.avatar!,
                          style: TextStyle(
                            color: event.avatarColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Icon(_eventIcon,
                          color: event.avatarColor, size: AppStyle.smallIconSize),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: AppStyle.gapXS),
                      color: AppStyle.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppStyle.gapM),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : AppStyle.gapL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.text,
                    style: const TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(event.time, style: AppStyle.captionStyle.copyWith(fontSize: 12.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Upcoming — next 2-3 days preview
// ---------------------------------------------------------------------------

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  static const _upcoming = [
    (day: 'Tomorrow', label: 'Pull Day', icon: Icons.fitness_center, hasWorkout: true),
    (day: 'Tuesday', label: 'Rest', icon: Icons.self_improvement, hasWorkout: false),
    (day: 'Wednesday', label: 'Legs', icon: Icons.fitness_center, hasWorkout: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming',
            style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        Container(
          decoration: BoxDecoration(
            color: AppStyle.cardBackground,
            borderRadius: AppStyle.cardRadius,
            border: Border.all(color: AppStyle.cardBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _upcoming.length; i++) ...[
                _UpcomingRow(
                  day: _upcoming[i].day,
                  label: _upcoming[i].label,
                  icon: _upcoming[i].icon,
                  hasWorkout: _upcoming[i].hasWorkout,
                ),
                if (i < _upcoming.length - 1)
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppStyle.dividerColor,
                    indent: AppStyle.gapL,
                    endIndent: AppStyle.gapL,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    required this.day,
    required this.label,
    required this.icon,
    required this.hasWorkout,
  });

  final String day;
  final String label;
  final IconData icon;
  final bool hasWorkout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapM,
      ),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: hasWorkout
                  ? AppStyle.primaryBlue.withAlpha(20)
                  : AppStyle.streakInactiveDay,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: hasWorkout ? AppStyle.primaryBlue : AppStyle.textSecondary,
              size: AppStyle.topBarIconSize,
            ),
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppStyle.captionStyle.copyWith(fontSize: 12.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  label,
                  style: TextStyle(
                    color: hasWorkout ? AppStyle.textPrimary : AppStyle.textSecondary,
                    fontSize: 15.0,
                    fontWeight: hasWorkout ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (hasWorkout)
            const Icon(Icons.chevron_right_rounded,
                color: AppStyle.textSecondary, size: 20.0),
        ],
      ),
    );
  }
}
