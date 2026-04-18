import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import '../home/bottom_nav.dart';
import 'persistent_sheet.dart';

/// Demonstrates [PersistentSheet] wrapping a mock "Start Workout" page.
/// The sheet is seeded collapsed — the workout title + timer + Finish button
/// sit above the bottom nav and can be swiped up to reveal the full workout.
class PersistentSheetDemo extends StatelessWidget {
  const PersistentSheetDemo({super.key});

  static const double _bottomNavContentHeight = 72.0;
  static const double _collapsedHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final navBottomInset =
        _bottomNavContentHeight + MediaQuery.of(context).padding.bottom;

    final sheet = PersistentSheet(
      collapsedHeight: _collapsedHeight,
      collapsedBottomInset: navBottomInset,
      headerBuilder: _buildHeader,
      pageBuilder: _buildPage,
      body: _Background(bottomInset: navBottomInset + _collapsedHeight + 24.0),
    );

    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      body: Stack(
        children: [
          Positioned.fill(child: sheet),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  static Widget _buildHeader(BuildContext context) {
    return const _CollapsedHeader();
  }

  static Widget _buildPage(BuildContext context) {
    return const _WorkoutPage();
  }
}

// --------------------------------------------------------------------------
// Body: mock "Start Workout" list that sits behind the sheet.
// --------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 8.0,
          bottom: bottomInset,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New in 6.0',
                  style: TextStyle(
                      color: AppStyle.primaryBlue,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600)),
              const Text('Start Workout',
                  style: TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700)),
              const Icon(Icons.search_rounded, color: AppStyle.primaryBlue),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          const Text('Quick Start',
              style: TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: AppStyle.gapM),
          Container(
            height: 56.0,
            decoration: const BoxDecoration(
              color: AppStyle.primaryBlue,
              borderRadius: AppStyle.pillRadius,
            ),
            child: const Center(
              child: Text('Start an Empty Workout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: AppStyle.gapXL),
          const Text('Templates',
              style: TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: AppStyle.gapM),
          for (final t in const [
            _TemplateMock('Full Body', 'Walking, Squat, Leg Extension & 3 more'),
            _TemplateMock('Push Alternative',
                'Walking, Chest Press, Overhead Press, Chest Dip'),
            _TemplateMock('pull',
                'Lat Pulldown, Seated Row, Bicep Curl (Barbell)'),
            _TemplateMock('Hotell', 'Bench Press, Chest Dip, Push Up'),
            _TemplateMock('Legs Copy', 'Walking, Squat, Lunge, Leg Extension'),
            _TemplateMock('push',
                'Bench Press, Chest Dip (Assisted), Incline Bench Press'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.gapM),
              child: t,
            ),
        ],
      ),
    );
  }
}

class _TemplateMock extends StatelessWidget {
  const _TemplateMock(this.title, this.body);

  final String title;
  final String body;

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
          Text(title,
              style: const TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: AppStyle.gapXS),
          Text(body, style: AppStyle.captionStyle),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Collapsed header — the "mini-player" row.
// --------------------------------------------------------------------------

class _CollapsedHeader extends StatelessWidget {
  const _CollapsedHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyle.gapL),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('pull', style: AppStyle.sheetTitleStyle),
            SizedBox(height: 2.0),
            Text(
              '0:00',
              style: TextStyle(
                color: AppStyle.textSecondary,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Full sheet page — mock of the expanded workout view.
// --------------------------------------------------------------------------

class _WorkoutPage extends StatelessWidget {
  const _WorkoutPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppStyle.gapL, AppStyle.gapS, AppStyle.gapL, AppStyle.gapS),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppStyle.inputPillBackground,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.timer_outlined,
                    color: AppStyle.textPrimary, size: 20.0),
              ),
              const Spacer(),
              Container(
                padding: AppStyle.finishButtonPadding,
                decoration: const BoxDecoration(
                  color: AppStyle.finishGreen,
                  borderRadius: AppStyle.pillRadius,
                ),
                child: const Text('Finish', style: AppStyle.finishButtonStyle),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppStyle.gapL, AppStyle.gapL, AppStyle.gapL, 40.0),
            children: [
              const Text('pull', style: AppStyle.workoutTitleStyle),
              const SizedBox(height: AppStyle.gapS),
              Row(
                children: const [
                  Icon(Icons.calendar_month_outlined,
                      size: AppStyle.metaIconSize,
                      color: AppStyle.textSecondary),
                  SizedBox(width: AppStyle.gapXS),
                  Text('18 Apr 2026', style: AppStyle.headerMetaStyle),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.access_time,
                      size: AppStyle.metaIconSize,
                      color: AppStyle.textSecondary),
                  SizedBox(width: AppStyle.gapXS),
                  Text('0:03', style: AppStyle.headerMetaStyle),
                ],
              ),
              const SizedBox(height: AppStyle.gapXL),
              const _ExerciseMock(
                name: 'Lat Pulldown (Cable)',
                sets: [
                  ['1', '45 kg × 16', '45', '16'],
                  ['2', '55 kg × 13', '55', '13'],
                  ['3', '55 kg × 11', '55', '11'],
                  ['4', '55 kg × 8', '55', '8'],
                ],
              ),
              const SizedBox(height: AppStyle.gapXL),
              const _ExerciseMock(
                name: 'Seated Row (Cable)',
                sets: [
                  ['1', '45 kg × 14', '45', '14'],
                  ['2', '45 kg × 13', '45', '13'],
                  ['3', '45 kg × 14', '45', '14'],
                ],
              ),
              const SizedBox(height: AppStyle.gapXL),
              const _ExerciseMock(
                name: 'Bicep Curl (Barbell)',
                sets: [
                  ['1', '20 kg × 12', '20', '12'],
                  ['2', '20 kg × 10', '20', '10'],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseMock extends StatelessWidget {
  const _ExerciseMock({required this.name, required this.sets});

  final String name;
  final List<List<String>> sets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(name, style: AppStyle.exerciseNameStyle),
        const SizedBox(height: AppStyle.gapM),
        Row(
          children: const [
            SizedBox(width: 32.0, child: Text('Set', style: AppStyle.setTableHeaderStyle)),
            SizedBox(width: AppStyle.gapM),
            Expanded(child: Text('Previous', style: AppStyle.setTableHeaderStyle)),
            SizedBox(width: 56.0, child: Text('kg', style: AppStyle.setTableHeaderStyle, textAlign: TextAlign.center)),
            SizedBox(width: AppStyle.gapM),
            SizedBox(width: 56.0, child: Text('Reps', style: AppStyle.setTableHeaderStyle, textAlign: TextAlign.center)),
            SizedBox(width: AppStyle.gapM),
            Icon(Icons.check, size: AppStyle.checkIconSize, color: AppStyle.textSecondary),
          ],
        ),
        const SizedBox(height: AppStyle.gapS),
        for (final s in sets)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(width: 32.0, child: Text(s[0], style: AppStyle.setNumberStyle)),
                const SizedBox(width: AppStyle.gapM),
                Expanded(child: Text(s[1], style: AppStyle.captionStyle)),
                _pill(s[2]),
                const SizedBox(width: AppStyle.gapM),
                _pill(s[3]),
                const SizedBox(width: AppStyle.gapM),
                Container(
                  width: AppStyle.checkCircleSize,
                  height: AppStyle.checkCircleSize,
                  decoration: BoxDecoration(
                    color: AppStyle.inputPillBackground,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.check,
                      size: AppStyle.checkIconSize,
                      color: AppStyle.textPrimary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      width: 56.0,
      height: 32.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppStyle.inputPillBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(text, style: AppStyle.setNumberStyle),
    );
  }
}
