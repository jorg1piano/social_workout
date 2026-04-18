import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home variant — "last session" layout.
///
/// Design philosophy: when you open the app, the first thing you want to see
/// is what you did last time. That context tells you how sore you are,
/// what's next in your split, and where to pick up weights from. This
/// variant makes the previous session the hero, with a prominent "Repeat"
/// CTA for users who run their own rotation and a "What's next" suggestion
/// card below for users following a plan.
class HomeLastSession extends StatelessWidget {
  const HomeLastSession({super.key});

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
        padding: AppStyle.screenPadding.copyWith(
          top: AppStyle.gapL,
          bottom: 40.0,
        ),
        children: const [
          _GreetingHeader(),
          SizedBox(height: AppStyle.gapL),
          _LastSessionHero(),
          SizedBox(height: AppStyle.gapXL),
          _NextUpCard(),
          SizedBox(height: AppStyle.gapXL),
          _WeekProgressStrip(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting header — "Welcome back" rather than time-of-day, to reinforce
// that this variant is about picking back up where you left off.
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
                'Welcome back,',
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
// Last session hero — the centerpiece of this variant.
// ---------------------------------------------------------------------------

class _LastSessionData {
  _LastSessionData._();

  static const String workoutName = 'Push Day';
  static const String relativeDate = '2 days ago';
  static const String absoluteDate = 'Tuesday, 16 Apr';
  static const String duration = '47:32';
  static const int totalVolumeKg = 8450;
  static const int setsCompleted = 16;
  static const int personalRecords = 2;

  /// Top working set per exercise — enough to remind the user what they
  /// hit without cluttering the hero card with every set.
  static const List<_LastExercise> topSets = [
    _LastExercise(name: 'Bench Press', weight: 90, reps: 6, isPR: true),
    _LastExercise(name: 'Incline DB Press', weight: 32, reps: 9),
    _LastExercise(name: 'Cable Fly', weight: 17.5, reps: 12, isPR: true),
    _LastExercise(name: 'Tricep Pushdown', weight: 30, reps: 10),
  ];
}

class _LastExercise {
  const _LastExercise({
    required this.name,
    required this.weight,
    required this.reps,
    this.isPR = false,
  });
  final String name;
  final double weight;
  final int reps;
  final bool isPR;
}

class _LastSessionHero extends StatelessWidget {
  const _LastSessionHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyle.gapL),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.primaryBlue.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: AppStyle.primaryBlue.withAlpha(15),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppStyle.primaryBlue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppStyle.primaryBlue, size: 20.0),
              ),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR LAST SESSION',
                      style: AppStyle.captionStyle.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppStyle.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    const Text(
                      _LastSessionData.workoutName,
                      style: TextStyle(
                        color: AppStyle.textPrimary,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapS),
          // Date + duration meta row.
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppStyle.textSecondary, size: AppStyle.metaIconSize),
              const SizedBox(width: AppStyle.gapXS),
              Text(
                '${_LastSessionData.absoluteDate} · ${_LastSessionData.relativeDate}',
                style: AppStyle.headerMetaStyle,
              ),
              const SizedBox(width: AppStyle.gapM),
              const Icon(Icons.timer_outlined,
                  color: AppStyle.textSecondary, size: AppStyle.metaIconSize),
              const SizedBox(width: AppStyle.gapXS),
              const Text(_LastSessionData.duration,
                  style: AppStyle.headerMetaStyle),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Quick stats.
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '${_LastSessionData.totalVolumeKg}',
                  unit: 'kg',
                  label: 'Volume',
                ),
              ),
              const SizedBox(width: AppStyle.gapS),
              Expanded(
                child: _MiniStat(
                  value: '${_LastSessionData.setsCompleted}',
                  label: 'Sets',
                ),
              ),
              const SizedBox(width: AppStyle.gapS),
              Expanded(
                child: _MiniStat(
                  value: '${_LastSessionData.personalRecords}',
                  label: 'PRs',
                  highlight: _LastSessionData.personalRecords > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Top set per exercise — compact list with a per-row PR mark.
          for (var i = 0; i < _LastSessionData.topSets.length; i++) ...[
            _TopSetRow(exercise: _LastSessionData.topSets[i]),
            if (i < _LastSessionData.topSets.length - 1)
              const SizedBox(height: AppStyle.gapS),
          ],
          const SizedBox(height: AppStyle.gapL),
          // Primary CTA — repeat this workout with the same template.
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
                  Icon(Icons.replay_rounded,
                      color: Colors.white, size: 22.0),
                  SizedBox(width: AppStyle.gapS),
                  Text(
                    'Repeat this workout',
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
          const SizedBox(height: AppStyle.gapS),
          // Secondary — see full breakdown.
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: AppStyle.accentBlueTint,
                borderRadius: AppStyle.pillRadius,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights_rounded,
                      color: AppStyle.primaryBlue, size: 18.0),
                  SizedBox(width: AppStyle.gapS),
                  Text(
                    'See full summary',
                    style: TextStyle(
                      color: AppStyle.primaryBlue,
                      fontSize: 14.0,
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    this.unit,
    this.highlight = false,
  });

  final String value;
  final String label;
  final String? unit;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final valueColor = highlight ? AppStyle.prGold : AppStyle.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppStyle.gapM, horizontal: AppStyle.gapS),
      decoration: BoxDecoration(
        color: highlight ? AppStyle.prGoldTint : AppStyle.inputPillBackground,
        borderRadius: AppStyle.pillRadius,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2.0),
                Text(
                  unit!,
                  style: AppStyle.streakStatCaptionStyle,
                ),
              ],
            ],
          ),
          const SizedBox(height: 2.0),
          Text(label, style: AppStyle.streakStatCaptionStyle),
        ],
      ),
    );
  }
}

class _TopSetRow extends StatelessWidget {
  const _TopSetRow({required this.exercise});

  final _LastExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5.0,
          height: 5.0,
          decoration: BoxDecoration(
            color: AppStyle.textSecondary.withAlpha(140),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppStyle.gapM),
        Expanded(
          child: Text(
            exercise.name,
            style: const TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        Text(
          '${AppStyle.formatWeightDisplay(exercise.weight)} × ${exercise.reps}',
          style: const TextStyle(
            color: AppStyle.textSecondary,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (exercise.isPR) ...[
          const SizedBox(width: AppStyle.gapS),
          const Icon(Icons.emoji_events_rounded,
              color: AppStyle.prGold, size: 16.0),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Next up card — small companion to the hero; tells the user what's
// suggested next in their split.
// ---------------------------------------------------------------------------

class _NextUpCard extends StatelessWidget {
  const _NextUpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL, vertical: AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: AppStyle.finishGreen.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                color: AppStyle.finishGreen, size: 20.0),
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UP NEXT IN YOUR SPLIT',
                  style: AppStyle.captionStyle.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'Pull Day',
                  style: TextStyle(
                    color: AppStyle.textPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '6 exercises · ~50 min',
                  style: AppStyle.captionStyle.copyWith(fontSize: 12.0),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppStyle.textSecondary, size: 22.0),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week progress — compact version; gives context for where the last
// session sits relative to the week's plan.
// ---------------------------------------------------------------------------

class _WeekProgressStrip extends StatelessWidget {
  const _WeekProgressStrip();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // Mon, Tue: done. Wed was the Push Day we're surfacing. Today (Fri) is
  // planned for Pull. Sat planned, rest otherwise.
  static const _states = [
    _DayState.done,
    _DayState.done,
    _DayState.done,
    _DayState.rest,
    _DayState.today,
    _DayState.planned,
    _DayState.rest,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'This week',
              style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '3 of 4 workouts',
              style: AppStyle.captionStyle.copyWith(
                color: AppStyle.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.gapM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final state = _states[i];
            final isToday = state == _DayState.today;
            return Column(
              children: [
                Text(
                  _days[i],
                  style: AppStyle.weekdayLabelStyle.copyWith(
                    color: isToday
                        ? AppStyle.primaryBlue
                        : AppStyle.textSecondary,
                    fontWeight:
                        isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyle.gapS),
                _DayDot(state: state),
              ],
            );
          }),
        ),
      ],
    );
  }
}

enum _DayState { done, today, planned, rest }

class _DayDot extends StatelessWidget {
  const _DayDot({required this.state});

  final _DayState state;

  @override
  Widget build(BuildContext context) {
    const double size = 36.0;

    Color fill;
    Widget? child;
    Border? border;

    switch (state) {
      case _DayState.done:
        fill = AppStyle.finishGreen;
        child = const Icon(Icons.check_rounded,
            color: Colors.white, size: 20.0);
        break;
      case _DayState.today:
        fill = AppStyle.primaryBlue;
        child = const Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: 20.0);
        border = Border.all(color: AppStyle.primaryBlue, width: 2.0);
        break;
      case _DayState.planned:
        fill = AppStyle.cardBorder;
        child = const Icon(Icons.circle_outlined,
            color: AppStyle.textSecondary, size: 14.0);
        break;
      case _DayState.rest:
        fill = AppStyle.streakInactiveDay;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
