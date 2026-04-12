import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// Hardcoded data for the concept workout summary screen.
class _SummaryData {
  _SummaryData._();

  static const String workoutName = 'Push Day';
  static const String date = '12 Apr 2026';
  static const String duration = '47:32';
  static const int totalVolumeKg = 8450;
  static const int setsCompleted = 16;
  static const int exercisesDone = 4;
  static const int personalRecords = 2;

  static const List<_ExerciseResult> exercises = [
    _ExerciseResult(
      name: 'Bench Press',
      sets: [
        _SetResult(label: 'W', weight: 40, reps: 12),
        _SetResult(label: '1', weight: 80, reps: 10),
        _SetResult(label: '2', weight: 85, reps: 8),
        _SetResult(label: '3', weight: 90, reps: 6, isPR: true),
      ],
    ),
    _ExerciseResult(
      name: 'Incline Dumbbell Press',
      sets: [
        _SetResult(label: '1', weight: 30, reps: 12),
        _SetResult(label: '2', weight: 32, reps: 10),
        _SetResult(label: '3', weight: 32, reps: 9),
      ],
    ),
    _ExerciseResult(
      name: 'Cable Fly',
      sets: [
        _SetResult(label: '1', weight: 15, reps: 15),
        _SetResult(label: '2', weight: 15, reps: 14),
        _SetResult(label: '3', weight: 17.5, reps: 12, isPR: true),
      ],
    ),
    _ExerciseResult(
      name: 'Tricep Pushdown',
      sets: [
        _SetResult(label: '1', weight: 25, reps: 15),
        _SetResult(label: '2', weight: 27.5, reps: 12),
        _SetResult(label: '3', weight: 30, reps: 10),
      ],
    ),
  ];
}

class _ExerciseResult {
  const _ExerciseResult({required this.name, required this.sets});
  final String name;
  final List<_SetResult> sets;
}

class _SetResult {
  const _SetResult({
    required this.label,
    required this.weight,
    required this.reps,
    this.isPR = false,
  });
  final String label;
  final double weight;
  final int reps;
  final bool isPR;
}

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      body: ListView(
        padding: AppStyle.screenPadding.copyWith(top: AppStyle.gapL, bottom: 40.0),
        children: [
          const _HeroCard(),
          const SizedBox(height: AppStyle.gapL),
          const _StatsRow(),
          const SizedBox(height: AppStyle.gapXL),
          if (_SummaryData.personalRecords > 0) ...[
            const _PRBanner(),
            const SizedBox(height: AppStyle.gapXL),
          ],
          const _ExerciseBreakdown(),
          const SizedBox(height: AppStyle.gapXL),
          const _ActionButtons(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card — congratulatory header
// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: AppStyle.gapL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.finishGreen.withAlpha(51)),
      ),
      child: Column(
        children: [
          // Checkmark icon
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: AppStyle.finishGreen.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppStyle.finishGreen, size: 32.0),
          ),
          const SizedBox(height: AppStyle.gapM),
          const Text('Workout Complete!', style: AppStyle.summaryHeadlineStyle),
          const SizedBox(height: AppStyle.gapS),
          const Text(_SummaryData.workoutName, style: AppStyle.summaryWorkoutNameStyle),
          const SizedBox(height: AppStyle.gapL),
          // Meta row: date + duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppStyle.textSecondary, size: AppStyle.metaIconSize),
              const SizedBox(width: AppStyle.gapXS),
              const Text(_SummaryData.date, style: AppStyle.headerMetaStyle),
              const SizedBox(width: AppStyle.gapL),
              const Icon(Icons.timer_outlined,
                  color: AppStyle.textSecondary, size: AppStyle.metaIconSize),
              const SizedBox(width: AppStyle.gapXS),
              const Text(_SummaryData.duration, style: AppStyle.headerMetaStyle),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row — volume / sets / exercises
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${_SummaryData.totalVolumeKg}',
            unit: 'kg',
            label: 'Volume',
          ),
        ),
        const SizedBox(width: AppStyle.gapS),
        Expanded(
          child: _StatTile(
            value: '${_SummaryData.setsCompleted}',
            label: 'Sets',
          ),
        ),
        const SizedBox(width: AppStyle.gapS),
        Expanded(
          child: _StatTile(
            value: '${_SummaryData.exercisesDone}',
            label: 'Exercises',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, this.unit});

  final String value;
  final String label;
  final String? unit;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppStyle.streakStatValueStyle),
              if (unit != null) ...[
                const SizedBox(width: 2.0),
                Text(unit!, style: AppStyle.streakStatCaptionStyle),
              ],
            ],
          ),
          const SizedBox(height: AppStyle.gapXS),
          Text(label, style: AppStyle.streakStatCaptionStyle),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Personal records banner
// ---------------------------------------------------------------------------

class _PRBanner extends StatelessWidget {
  const _PRBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL, vertical: AppStyle.gapM),
      decoration: BoxDecoration(
        color: AppStyle.prGoldTint,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.prGold.withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppStyle.prGold, size: 22.0),
          const SizedBox(width: AppStyle.gapM),
          Text(
            '${_SummaryData.personalRecords} Personal Records',
            style: AppStyle.summaryPRBannerStyle,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise breakdown
// ---------------------------------------------------------------------------

class _ExerciseBreakdown extends StatelessWidget {
  const _ExerciseBreakdown();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercises',
            style: AppStyle.captionStyle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppStyle.gapM),
        ...List.generate(_SummaryData.exercises.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < _SummaryData.exercises.length - 1
                    ? AppStyle.gapS
                    : 0),
            child: _ExerciseCard(exercise: _SummaryData.exercises[i]),
          );
        }),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final _ExerciseResult exercise;

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
          Text(exercise.name, style: AppStyle.exerciseNameStyle),
          const SizedBox(height: AppStyle.gapM),
          // Header row
          Row(
            children: const [
              SizedBox(width: 32.0, child: Text('Set', style: AppStyle.setTableHeaderStyle)),
              SizedBox(width: AppStyle.setRowHGap),
              Expanded(child: Text('kg', style: AppStyle.setTableHeaderStyle)),
              SizedBox(width: 60.0, child: Text('Reps', style: AppStyle.setTableHeaderStyle)),
            ],
          ),
          const SizedBox(height: AppStyle.gapS),
          // Set rows
          ...exercise.sets.map((set) => _SetRow(set: set)),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set});

  final _SetResult set;

  @override
  Widget build(BuildContext context) {
    final isWarmup = set.label == 'W';
    final labelStyle = isWarmup ? AppStyle.warmupBadgeStyle : AppStyle.setNumberStyle;

    return Container(
      padding: AppStyle.setRowPadding,
      decoration: set.isPR
          ? BoxDecoration(
              color: AppStyle.prGoldTint,
              borderRadius: AppStyle.pillRadius,
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 32.0,
            child: isWarmup
                ? Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      color: AppStyle.warmupOrangeTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(set.label, style: labelStyle),
                  )
                : Text(set.label, style: labelStyle),
          ),
          const SizedBox(width: AppStyle.setRowHGap),
          Expanded(
            child: Text(
              AppStyle.formatWeightDisplay(set.weight),
              style: AppStyle.summarySetValueStyle,
            ),
          ),
          SizedBox(
            width: 60.0,
            child: Row(
              children: [
                Text('${set.reps}', style: AppStyle.summarySetValueStyle),
                if (set.isPR) ...[
                  const SizedBox(width: AppStyle.gapS),
                  const Icon(Icons.emoji_events_rounded,
                      color: AppStyle.prGold, size: 14.0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Share button (outline)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18.0),
            label: const Text('Share Workout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyle.primaryBlue,
              side: const BorderSide(color: AppStyle.primaryBlue),
              padding: AppStyle.finishButtonPadding,
              shape: RoundedRectangleBorder(borderRadius: AppStyle.cardRadius),
            ),
          ),
        ),
        const SizedBox(height: AppStyle.gapM),
        // Done button (filled green)
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppStyle.finishGreen,
              foregroundColor: Colors.white,
              padding: AppStyle.finishButtonPadding,
              shape: RoundedRectangleBorder(borderRadius: AppStyle.cardRadius),
            ),
            child: const Text('Done', style: AppStyle.finishButtonStyle),
          ),
        ),
      ],
    );
  }
}
