import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home variant C — "action-first" layout.
///
/// Design philosophy: get to working out FAST. Big hero card with today's
/// workout at the top, recent templates for quick switching, ultra-compact
/// week strip, PR nudge, and a minimal social footer. Everything else is
/// secondary to the START button.
class HomeVariantC extends StatelessWidget {
  const HomeVariantC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Variant C — Action'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: ListView(
        padding: EdgeInsets.zero,
          children: const [
            _HeroWorkoutCard(),
            SizedBox(height: AppStyle.gapXL),
            _RecentTemplatesRow(),
            SizedBox(height: AppStyle.gapXL),
            _WeekAtAGlance(),
            SizedBox(height: AppStyle.gapXL),
            _PersonalBestCallout(),
            SizedBox(height: AppStyle.gapXL),
            _MinimalFooter(),
            SizedBox(height: 40.0),
          ],
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero workout card — dominates the top ~40% of the screen
// ---------------------------------------------------------------------------

class _HeroWorkoutCard extends StatelessWidget {
  const _HeroWorkoutCard();

  static const _exercises = [
    'Bench Press  ·  4 x 8',
    'Overhead Press  ·  3 x 10',
    'Incline Dumbbell Press  ·  3 x 12',
    'Tricep Pushdown  ·  3 x 15',
    'Lateral Raises  ·  3 x 15',
    'Cable Flyes  ·  3 x 12',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapL),
      child: Container(
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
            // Header row: label + exercise count
            Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: AppStyle.primaryBlue.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: AppStyle.primaryBlue, size: 18.0),
                ),
                const SizedBox(width: AppStyle.gapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S PLAN",
                        style: AppStyle.captionStyle.copyWith(
                          color: AppStyle.primaryBlue,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      const Text(
                        'Push Day',
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
                Text(
                  '6 exercises',
                  style: AppStyle.captionStyle.copyWith(fontSize: 12.0),
                ),
              ],
            ),
            const SizedBox(height: AppStyle.gapL),
            // Exercise list
            for (final exercise in _exercises) ...[
              _HeroExerciseRow(exercise),
              const SizedBox(height: AppStyle.gapS),
            ],
            const SizedBox(height: AppStyle.gapL),
            // Start button
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: AppStyle.primaryBlue,
                  borderRadius: AppStyle.pillRadius,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 26.0),
                    SizedBox(width: AppStyle.gapS),
                    Text(
                      'Start Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroExerciseRow extends StatelessWidget {
  const _HeroExerciseRow(this.label);

  final String label;

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
        Text(
          label,
          style: const TextStyle(
            color: AppStyle.textPrimary,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recent templates — horizontal scrollable row
// ---------------------------------------------------------------------------

class _RecentTemplatesRow extends StatelessWidget {
  const _RecentTemplatesRow();

  static const _templates = [
    (name: 'Pull Day', exercises: 6, icon: Icons.fitness_center),
    (name: 'Legs', exercises: 5, icon: Icons.directions_run),
    (name: 'Full Body', exercises: 8, icon: Icons.accessibility_new),
    (name: 'Upper Body', exercises: 7, icon: Icons.sports_gymnastics),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppStyle.screenPadding,
          child: Text(
            'Other templates',
            style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: AppStyle.gapM),
        SizedBox(
          height: 96.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppStyle.screenPadding,
            itemCount: _templates.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppStyle.gapM),
            itemBuilder: (_, i) {
              final t = _templates[i];
              return _TemplateCard(
                name: t.name,
                exerciseCount: t.exercises,
                icon: t.icon,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.name,
    required this.exerciseCount,
    required this.icon,
  });

  final String name;
  final int exerciseCount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148.0,
      padding: const EdgeInsets.all(AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppStyle.primaryBlue, size: AppStyle.topBarIconSize),
              const SizedBox(width: AppStyle.gapS),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppStyle.textPrimary,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '$exerciseCount exercises',
            style: AppStyle.captionStyle,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week at a glance — 7 dots, ultra compact
// ---------------------------------------------------------------------------

class _WeekAtAGlance extends StatelessWidget {
  const _WeekAtAGlance();

  // Mon-Sun: done, done, done, planned (today), rest, planned, rest
  static const _states = [
    _DayState.done,
    _DayState.done,
    _DayState.done,
    _DayState.today,
    _DayState.rest,
    _DayState.planned,
    _DayState.rest,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _states.length; i++) ...[
            if (i > 0) const SizedBox(width: AppStyle.gapL),
            _DayDot(state: _states[i]),
          ],
        ],
      ),
    );
  }
}

enum _DayState { done, today, planned, rest }

class _DayDot extends StatelessWidget {
  const _DayDot({required this.state});

  final _DayState state;

  @override
  Widget build(BuildContext context) {
    const double size = 28.0;

    Color fill;
    Widget? child;
    Border? border;

    switch (state) {
      case _DayState.done:
        fill = AppStyle.finishGreen;
        child = const Icon(Icons.check_rounded, color: Colors.white, size: 16.0);
        break;
      case _DayState.today:
        fill = AppStyle.primaryBlue;
        child = const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16.0);
        border = Border.all(color: AppStyle.primaryBlue, width: 2.5);
        break;
      case _DayState.planned:
        fill = AppStyle.cardBorder;
        child = Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: AppStyle.textSecondary.withAlpha(120),
            shape: BoxShape.circle,
          ),
        );
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

// ---------------------------------------------------------------------------
// Personal bests callout — PR nudge or celebration
// ---------------------------------------------------------------------------

class _PersonalBestCallout extends StatelessWidget {
  const _PersonalBestCallout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding,
      child: Container(
        padding: const EdgeInsets.all(AppStyle.gapL),
        decoration: BoxDecoration(
          color: AppStyle.warmupOrange.withAlpha(18),
          borderRadius: AppStyle.cardRadius,
          border: Border.all(color: AppStyle.warmupOrange.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppStyle.warmupOrange, size: 22.0),
                const SizedBox(width: AppStyle.gapS),
                Text(
                  'Almost there',
                  style: AppStyle.captionStyle.copyWith(
                    color: AppStyle.warmupOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyle.gapM),
            const Text(
              'Bench Press: 2.5 kg from your PR!',
              style: TextStyle(
                color: AppStyle.textPrimary,
                fontSize: 17.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppStyle.gapXS),
            Text(
              'Current PR: 87.5 kg  -  Last attempt: 85 kg',
              style: AppStyle.captionStyle.copyWith(fontSize: 13.0),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal footer — streak + social link
// ---------------------------------------------------------------------------

class _MinimalFooter extends StatelessWidget {
  const _MinimalFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding,
      child: Row(
        children: [
          // Streak count
          const Icon(Icons.local_fire_department_rounded,
              color: AppStyle.streakOrange, size: 22.0),
          const SizedBox(width: AppStyle.gapS),
          const Text(
            '12 day streak',
            style: TextStyle(
              color: AppStyle.streakOrange,
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // See friends link
          Container(
            padding: AppStyle.pillPadding,
            decoration: BoxDecoration(
              color: AppStyle.accentBlueTint,
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_rounded,
                    color: AppStyle.primaryBlue, size: AppStyle.topBarIconSize),
                const SizedBox(width: AppStyle.gapS),
                Text(
                  'See friends',
                  style: AppStyle.captionStyle.copyWith(
                    color: AppStyle.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
