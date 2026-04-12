import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home variant B — "social-first" layout.
///
/// Design philosophy: social motivation drives engagement. The feed of friend
/// activity is the star; seeing friends work out makes you want to work out.
/// The workout button is always accessible but the feed dominates.
///
/// All data is hardcoded dummy data for layout exploration.
class HomeVariantB extends StatelessWidget {
  const HomeVariantB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Variant B — Social'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Column(
        children: [
          const _MinimalHeader(),
          Expanded(
            child: ListView(
              padding: AppStyle.screenPadding.copyWith(
                top: AppStyle.gapS,
                bottom: 40.0,
              ),
                children: const [
                  _WorkoutBanner(),
                  SizedBox(height: AppStyle.gapXL),
                  _SectionLabel(label: 'Activity'),
                  SizedBox(height: AppStyle.gapM),
                  _FeedCardCompleted(
                    name: 'Erik',
                    workout: 'Pull Day',
                    duration: '45 min',
                    exerciseCount: 6,
                    prCount: 2,
                    timeAgo: '2h ago',
                  ),
                  SizedBox(height: AppStyle.gapM),
                  _FeedCardStreak(
                    name: 'Marte',
                    streakDays: 30,
                  ),
                  SizedBox(height: AppStyle.gapM),
                  _FeedCardLive(
                    name: 'Kristian',
                    workout: 'Full Body',
                    minutesAgo: 15,
                  ),
                  SizedBox(height: AppStyle.gapM),
                  _FeedCardSelf(
                    workout: 'Push Day',
                    timeLabel: 'yesterday',
                  ),
                  SizedBox(height: AppStyle.gapXL),
                  _CompetitionCallout(),
                  SizedBox(height: AppStyle.gapXL),
                  _SectionLabel(label: 'Top streaks'),
                  SizedBox(height: AppStyle.gapM),
                  _StreakLeaderboardMini(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label — reusable small heading
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal header — title + notification bell
// ---------------------------------------------------------------------------

class _MinimalHeader extends StatelessWidget {
  const _MinimalHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding.copyWith(
        top: AppStyle.gapM,
        bottom: AppStyle.gapM,
      ),
      child: Row(
        children: [
          const Text(
            'Social Workout',
            style: TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: AppStyle.inputPillBackground,
              borderRadius: AppStyle.circleRadius,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppStyle.textPrimary,
              size: AppStyle.topBarIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout banner — persistent, visually prominent call to action
// ---------------------------------------------------------------------------

class _WorkoutBanner extends StatelessWidget {
  const _WorkoutBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: AppStyle.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppStyle.primaryBlue.withAlpha(60),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 22.0,
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Start Today's Workout",
                  style: AppStyle.finishButtonStyle.copyWith(fontSize: 14.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Push Day — 6 exercises',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.gapM,
              vertical: AppStyle.gapS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: AppStyle.pillRadius,
            ),
            child: const Text(
              'Go',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed card — friend completed a workout
// ---------------------------------------------------------------------------

class _FeedCardCompleted extends StatelessWidget {
  const _FeedCardCompleted({
    required this.name,
    required this.workout,
    required this.duration,
    required this.exerciseCount,
    required this.prCount,
    required this.timeAgo,
  });

  final String name;
  final String workout;
  final String duration;
  final int exerciseCount;
  final int prCount;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, time
          Row(
            children: [
              _Avatar(initial: name[0], color: AppStyle.primaryBlue),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(timeAgo, style: AppStyle.captionStyle),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: AppStyle.finishGreen,
                size: 20.0,
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapM),
          // Activity text
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppStyle.textPrimary,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Finished '),
                TextSpan(
                  text: workout,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' — $duration, $exerciseCount exercises'),
                if (prCount > 0)
                  TextSpan(
                    text: ', $prCount PRs',
                    style: const TextStyle(
                      color: AppStyle.streakOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          // PR badges
          if (prCount > 0) ...[
            const SizedBox(height: AppStyle.gapM),
            Wrap(
              spacing: AppStyle.gapS,
              children: [
                _PrBadge(label: 'Barbell Row 95 kg'),
                if (prCount > 1) _PrBadge(label: 'Lat Pulldown 72 kg'),
              ],
            ),
          ],
          const SizedBox(height: AppStyle.gapM),
          // Action row
          const _FeedActionRow(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed card — streak celebration
// ---------------------------------------------------------------------------

class _FeedCardStreak extends StatelessWidget {
  const _FeedCardStreak({
    required this.name,
    required this.streakDays,
  });

  final String name;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.streakOrange.withAlpha(60)),
        gradient: LinearGradient(
          colors: [
            AppStyle.streakOrangeTint,
            AppStyle.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: name[0], color: AppStyle.streakOrange),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppStyle.textPrimary,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppStyle.streakOrange,
                size: 22.0,
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapM),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppStyle.textPrimary,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Is on a '),
                TextSpan(
                  text: '$streakDays-day streak!',
                  style: const TextStyle(
                    color: AppStyle.streakOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(text: ' Keep it up!'),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.gapM),
          const _FeedActionRow(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed card — someone is working out right now
// ---------------------------------------------------------------------------

class _FeedCardLive extends StatelessWidget {
  const _FeedCardLive({
    required this.name,
    required this.workout,
    required this.minutesAgo,
  });

  final String name;
  final String workout;
  final int minutesAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.finishGreen.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: name[0], color: AppStyle.finishGreen),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: AppStyle.finishGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppStyle.gapXS),
                        Text(
                          'Working out now',
                          style: AppStyle.captionStyle.copyWith(
                            color: AppStyle.finishGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapM),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppStyle.textPrimary,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Started '),
                TextSpan(
                  text: workout,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' $minutesAgo min ago'),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.gapM),
          // Encourage button instead of the usual action row
          Container(
            padding: AppStyle.pillPadding,
            decoration: BoxDecoration(
              color: AppStyle.finishGreen.withAlpha(20),
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppStyle.finishGreen,
                  size: AppStyle.smallIconSize,
                ),
                const SizedBox(width: AppStyle.gapXS),
                Text(
                  'Send encouragement',
                  style: AppStyle.captionStyle.copyWith(
                    color: AppStyle.finishGreen,
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

// ---------------------------------------------------------------------------
// Feed card — your own recent activity (self-card)
// ---------------------------------------------------------------------------

class _FeedCardSelf extends StatelessWidget {
  const _FeedCardSelf({
    required this.workout,
    required this.timeLabel,
  });

  final String workout;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.primaryBlue.withAlpha(40)),
        gradient: LinearGradient(
          colors: [
            AppStyle.accentBlueTint,
            AppStyle.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const _Avatar(initial: 'J', color: AppStyle.primaryBlue),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'You completed '),
                  TextSpan(
                    text: workout,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' $timeLabel — great job!'),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppStyle.gapS),
          const Icon(
            Icons.emoji_events_rounded,
            color: AppStyle.primaryBlue,
            size: 20.0,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Competition callout card
// ---------------------------------------------------------------------------

class _CompetitionCallout extends StatelessWidget {
  const _CompetitionCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.dropSetPurple.withAlpha(50)),
        gradient: LinearGradient(
          colors: [
            AppStyle.dropSetPurple.withAlpha(15),
            AppStyle.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppStyle.dropSetPurple.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppStyle.dropSetPurple,
              size: 22.0,
            ),
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPRING CHALLENGE',
                  style: AppStyle.captionStyle.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppStyle.dropSetPurple,
                  ),
                ),
                const SizedBox(height: AppStyle.gapXS),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: "You're "),
                      TextSpan(
                        text: '#2',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: ', 3 points behind '),
                      TextSpan(
                        text: 'Erik',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppStyle.textSecondary,
            size: 22.0,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak leaderboard mini — horizontal avatar strip
// ---------------------------------------------------------------------------

class _StreakLeaderboardMini extends StatelessWidget {
  const _StreakLeaderboardMini();

  static const _leaders = [
    (name: 'Marte', streak: 30, rank: 1),
    (name: 'Erik', streak: 18, rank: 2),
    (name: 'You', streak: 12, rank: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapM,
      ),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final leader in _leaders)
            _StreakLeaderEntry(
              name: leader.name,
              streak: leader.streak,
              rank: leader.rank,
            ),
        ],
      ),
    );
  }
}

class _StreakLeaderEntry extends StatelessWidget {
  const _StreakLeaderEntry({
    required this.name,
    required this.streak,
    required this.rank,
  });

  final String name;
  final int streak;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isYou = name == 'You';
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: isYou
                    ? AppStyle.primaryBlue.withAlpha(25)
                    : AppStyle.streakOrangeTint,
                shape: BoxShape.circle,
                border: rank == 1
                    ? Border.all(color: AppStyle.streakOrange, width: 2.0)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                name[0],
                style: TextStyle(
                  color: isYou ? AppStyle.primaryBlue : AppStyle.streakOrange,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Rank badge
            Positioned(
              top: -4.0,
              right: -4.0,
              child: Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? AppStyle.streakOrange
                      : AppStyle.textSecondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.gapS),
        Text(
          name,
          style: const TextStyle(
            color: AppStyle.textPrimary,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppStyle.streakOrange,
              size: AppStyle.metaIconSize,
            ),
            const SizedBox(width: 2.0),
            Text(
              '$streak',
              style: const TextStyle(
                color: AppStyle.streakOrange,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

/// Circular avatar with a single-letter initial.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// PR badge pill.
class _PrBadge extends StatelessWidget {
  const _PrBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppStyle.pillPadding,
      decoration: BoxDecoration(
        color: AppStyle.streakOrangeTint,
        borderRadius: AppStyle.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_upward_rounded,
            color: AppStyle.streakOrange,
            size: AppStyle.metaIconSize,
          ),
          const SizedBox(width: AppStyle.gapXS),
          Text(
            label,
            style: const TextStyle(
              color: AppStyle.streakOrange,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Like / congrats action row at the bottom of feed cards.
class _FeedActionRow extends StatelessWidget {
  const _FeedActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionPill(
          icon: Icons.favorite_border_rounded,
          label: 'Like',
          color: AppStyle.failureRed,
        ),
        const SizedBox(width: AppStyle.gapS),
        _ActionPill(
          icon: Icons.celebration_rounded,
          label: 'Congrats',
          color: AppStyle.primaryBlue,
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
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
      padding: AppStyle.pillPadding,
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppStyle.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppStyle.smallIconSize),
          const SizedBox(width: AppStyle.gapXS),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
