import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'bottom_nav.dart';

/// Home variant — "multi-select start" layout.
///
/// The plan dictates the *category* for today (e.g. Push Day). The user
/// still picks which *version* of that workout to run — Heavy, Volume,
/// Express — without leaving the home screen. Once a variant is selected,
/// the Start button unlocks.
///
/// All data is hardcoded dummy data — layout exploration only.
class HomeVariantMultiselect extends StatefulWidget {
  const HomeVariantMultiselect({super.key});

  @override
  State<HomeVariantMultiselect> createState() => _HomeVariantMultiselectState();
}

class _HomeVariantMultiselectState extends State<HomeVariantMultiselect> {
  /// Index into [_PlannedSessionPicker._variants]. `null` = nothing picked yet.
  int? _selectedVariant = 1; // default to the "recommended" one

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Variant — Multi-select'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: ListView(
        padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapM, bottom: 40.0),
        children: [
          const _CompactHeader(),
          const SizedBox(height: AppStyle.gapL),
          _PlannedSessionPicker(
            selectedIndex: _selectedVariant,
            onSelect: (i) => setState(() => _selectedVariant = i),
          ),
          const SizedBox(height: AppStyle.gapXL),
          const _WeekStrip(),
          const SizedBox(height: AppStyle.gapXL),
          const _UpcomingSection(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact header — greeting + avatar left, streak flame badge right
// ---------------------------------------------------------------------------

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
// Planned session picker — the main event. Plan pins today to "Push Day";
// the user picks between three matching sessions before starting.
// ---------------------------------------------------------------------------

class _SessionVariant {
  const _SessionVariant({
    required this.name,
    required this.tagline,
    required this.durationMin,
    required this.exercises,
    this.recommended = false,
  });

  final String name;
  final String tagline;
  final int durationMin;
  final List<String> exercises;
  final bool recommended;
}

class _PlannedSessionPicker extends StatelessWidget {
  const _PlannedSessionPicker({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  static const _variants = [
    _SessionVariant(
      name: 'Heavy Push',
      tagline: 'Low reps, big compounds',
      durationMin: 50,
      exercises: ['Bench Press', 'OHP', 'Weighted Dips', 'Close-Grip Bench'],
    ),
    _SessionVariant(
      name: 'Volume Push',
      tagline: 'Hypertrophy focus',
      durationMin: 65,
      exercises: [
        'Bench Press',
        'OHP',
        'Incline DB',
        'Cable Fly',
        'Lateral Raises',
        'Tricep Pushdown',
      ],
      recommended: true,
    ),
    _SessionVariant(
      name: 'Express Push',
      tagline: 'Short on time',
      durationMin: 30,
      exercises: ['Bench Press', 'OHP', 'Tricep Pushdown'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == null ? null : _variants[selectedIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plan ribbon — the immovable part.
        Row(
          children: [
            const Icon(Icons.event_available_rounded,
                color: AppStyle.primaryBlue, size: AppStyle.smallIconSize),
            const SizedBox(width: AppStyle.gapXS),
            Text(
              'TODAY\'S PLAN  ·  PUSH DAY',
              style: AppStyle.captionStyle.copyWith(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppStyle.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.gapXS),
        Text(
          'Pick the session that fits your energy today.',
          style: AppStyle.captionStyle.copyWith(fontSize: 13.0),
        ),
        const SizedBox(height: AppStyle.gapM),

        // Variant cards.
        for (var i = 0; i < _variants.length; i++) ...[
          _VariantCard(
            variant: _variants[i],
            selected: selectedIndex == i,
            onTap: () => onSelect(i),
          ),
          if (i < _variants.length - 1) const SizedBox(height: AppStyle.gapS),
        ],

        const SizedBox(height: AppStyle.gapL),

        // Start button — label reflects the current pick.
        _StartButton(selected: selected),
      ],
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final _SessionVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppStyle.primaryBlue : AppStyle.cardBorder;
    final background = selected ? AppStyle.accentBlueTint : AppStyle.cardBackground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyle.cardRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(AppStyle.gapL),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppStyle.cardRadius,
            border: Border.all(
              color: borderColor,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio dot
                  Container(
                    width: 22.0,
                    height: 22.0,
                    margin: const EdgeInsets.only(top: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppStyle.primaryBlue
                            : AppStyle.cardBorder,
                        width: 2.0,
                      ),
                      color: selected ? AppStyle.primaryBlue : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14.0)
                        : null,
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
                                variant.name,
                                style: const TextStyle(
                                  color: AppStyle.textPrimary,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (variant.recommended) ...[
                              const SizedBox(width: AppStyle.gapS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppStyle.finishGreen.withAlpha(30),
                                  borderRadius: AppStyle.pillRadius,
                                ),
                                child: const Text(
                                  'RECOMMENDED',
                                  style: TextStyle(
                                    color: AppStyle.finishGreen,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          variant.tagline,
                          style: AppStyle.captionStyle.copyWith(fontSize: 13.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyle.gapS),
                  // Duration pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppStyle.inputPillBackground,
                      borderRadius: AppStyle.pillRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppStyle.textSecondary,
                            size: AppStyle.metaIconSize),
                        const SizedBox(width: AppStyle.gapXS),
                        Text(
                          '${variant.durationMin}m',
                          style: const TextStyle(
                            color: AppStyle.textPrimary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyle.gapM),
              Text(
                '${variant.exercises.length} exercises  ·  ${_exercisePreview(variant.exercises)}',
                style: AppStyle.captionStyle.copyWith(fontSize: 12.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _exercisePreview(List<String> ex) {
    if (ex.length <= 3) return ex.join(', ');
    return '${ex.take(3).join(', ')} +${ex.length - 3}';
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.selected});

  final _SessionVariant? selected;

  @override
  Widget build(BuildContext context) {
    final enabled = selected != null;
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: enabled
              ? AppStyle.primaryBlue
              : AppStyle.primaryBlue.withAlpha(80),
          borderRadius: AppStyle.pillRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20.0),
            const SizedBox(width: AppStyle.gapS),
            Text(
              enabled ? 'Start ${selected!.name}' : 'Pick a session',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week strip — lightweight reminder that plan is being respected
// ---------------------------------------------------------------------------

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _labels = [
    'Push', 'Pull', 'Rest', 'Legs', 'Upper', 'Push', 'Rest'
  ];
  static const _done = [true, true, false, false, false, false, false];
  static const int _todayIndex = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('This week · PPL split',
                style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('2 of 5 done',
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
            final isToday = i == _todayIndex;
            final isRest = _labels[i] == 'Rest';
            return Column(
              children: [
                Text(_days[i],
                    style: TextStyle(
                      color: isToday ? AppStyle.primaryBlue : AppStyle.textSecondary,
                      fontSize: 12.0,
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
                            : isRest
                                ? AppStyle.streakInactiveDay
                                : AppStyle.cardBorder,
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
                          : null,
                ),
                const SizedBox(height: AppStyle.gapXS),
                Text(
                  _labels[i],
                  style: TextStyle(
                    color: isRest ? AppStyle.textSecondary : AppStyle.textPrimary,
                    fontSize: 11.0,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
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
// Upcoming — next couple of days per the plan
// ---------------------------------------------------------------------------

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  static const _upcoming = [
    (day: 'Tomorrow', label: 'Rest', variants: 0),
    (day: 'Monday', label: 'Legs', variants: 3),
    (day: 'Tuesday', label: 'Upper', variants: 2),
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
                  variants: _upcoming[i].variants,
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
    required this.variants,
  });

  final String day;
  final String label;
  final int variants;

  @override
  Widget build(BuildContext context) {
    final isRest = variants == 0;
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
              color: isRest
                  ? AppStyle.streakInactiveDay
                  : AppStyle.primaryBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRest ? Icons.self_improvement : Icons.fitness_center,
              color: isRest ? AppStyle.textSecondary : AppStyle.primaryBlue,
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
                    color: isRest ? AppStyle.textSecondary : AppStyle.textPrimary,
                    fontSize: 15.0,
                    fontWeight: isRest ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (variants > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppStyle.inputPillBackground,
                borderRadius: AppStyle.pillRadius,
              ),
              child: Text(
                '$variants options',
                style: const TextStyle(
                  color: AppStyle.textSecondary,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
