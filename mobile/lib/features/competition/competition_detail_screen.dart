import 'package:flutter/material.dart';

import '../../data/dao/competition_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/competition_status.dart';
import '../../data/models/competition_type.dart';
import '../../data/models/db_competition.dart';
import '../../style/app_style.dart';

/// Detail screen for a single competition. Shows:
/// - Competition info (name, description, type, dates, status)
/// - Tracked exercises
/// - Participant list with leaderboard scores and ranks
class CompetitionDetailScreen extends StatefulWidget {
  const CompetitionDetailScreen({
    super.key,
    required this.database,
    required this.competitionId,
  });

  final AppDatabase database;
  final String competitionId;

  @override
  State<CompetitionDetailScreen> createState() =>
      _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  late final CompetitionDao _dao;
  DbCompetition? _competition;
  List<Map<String, Object?>> _exercises = const [];
  List<Map<String, Object?>> _leaderboard = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dao = CompetitionDao(widget.database.raw);
    _load();
  }

  Future<void> _load() async {
    try {
      final competition = await _dao.getCompetition(widget.competitionId);
      if (competition == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Competition not found';
          _loading = false;
        });
        return;
      }
      final exercises =
          await _dao.exercisesForCompetition(widget.competitionId);
      final leaderboard =
          await _dao.leaderboardForCompetition(widget.competitionId);
      if (!mounted) return;
      setState(() {
        _competition = competition;
        _exercises = exercises;
        _leaderboard = leaderboard;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text(_competition?.name ?? 'Competition'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppStyle.screenPadding,
          child: Text(_error!, style: AppStyle.captionStyle,
              textAlign: TextAlign.center),
        ),
      );
    }
    final comp = _competition!;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppStyle.gapXL),
      children: [
        _InfoSection(competition: comp),
        const SizedBox(height: AppStyle.gapL),
        if (_exercises.isNotEmpty) ...[
          _SectionHeader(title: 'Tracked Exercises'),
          ..._exercises.map((row) => _ExerciseTile(
                exerciseName: row['exercise_name'] as String? ?? 'Unknown',
              )),
          const SizedBox(height: AppStyle.gapL),
        ],
        _SectionHeader(title: 'Leaderboard'),
        if (_leaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyle.gapL),
            child: Text('No scores yet', style: AppStyle.captionStyle),
          )
        else
          ..._leaderboard.asMap().entries.map((entry) => _LeaderboardRow(
                position: entry.key + 1,
                displayName: entry.value['display_name'] as String? ?? 'Unknown',
                username: entry.value['username'] as String? ?? '',
                score: (entry.value['score'] as num?)?.toDouble() ?? 0,
                rank: entry.value['rank'] as int?,
                competitionType: comp.competitionType,
              )),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.competition});

  final DbCompetition competition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyle.gapL,
        AppStyle.gapM,
        AppStyle.gapL,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyle.cardBackground,
          borderRadius: AppStyle.cardRadius,
          border: Border.all(color: AppStyle.cardBorder),
        ),
        padding: AppStyle.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    competition.name,
                    style: AppStyle.workoutTitleStyle.copyWith(fontSize: 22.0),
                  ),
                ),
                _StatusBadge(status: competition.status),
              ],
            ),
            if (competition.description != null) ...[
              const SizedBox(height: AppStyle.gapS),
              Text(competition.description!, style: AppStyle.captionStyle),
            ],
            const SizedBox(height: AppStyle.gapM),
            _MetaRow(
              icon: Icons.category_outlined,
              label: competition.competitionType.displayLabel,
            ),
            const SizedBox(height: AppStyle.gapXS),
            _MetaRow(
              icon: Icons.calendar_today_outlined,
              label:
                  '${_formatDate(competition.startDate)} – ${_formatDate(competition.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppStyle.metaIconSize, color: AppStyle.textSecondary),
        const SizedBox(width: AppStyle.gapS),
        Text(label, style: AppStyle.headerMetaStyle),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CompetitionStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case CompetitionStatus.active:
        bg = AppStyle.completedRowTint;
        fg = AppStyle.finishGreen;
      case CompetitionStatus.upcoming:
        bg = AppStyle.accentBlueTint;
        fg = AppStyle.primaryBlue;
      case CompetitionStatus.completed:
        bg = AppStyle.inputPillBackground;
        fg = AppStyle.textSecondary;
    }
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: AppStyle.pillRadius),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Text(
        status.displayLabel,
        style: TextStyle(color: fg, fontSize: 12.0, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyle.gapL,
        0,
        AppStyle.gapL,
        AppStyle.gapS,
      ),
      child: Text(
        title,
        style: AppStyle.sheetTitleStyle,
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exerciseName});

  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapXS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppStyle.cardBackground,
          borderRadius: AppStyle.pillRadius,
          border: Border.all(color: AppStyle.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapM,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.fitness_center,
              size: AppStyle.smallIconSize,
              color: AppStyle.primaryBlue,
            ),
            const SizedBox(width: AppStyle.gapM),
            Expanded(
              child: Text(exerciseName, style: AppStyle.sheetVariantNameStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.position,
    required this.displayName,
    required this.username,
    required this.score,
    required this.rank,
    required this.competitionType,
  });

  final int position;
  final String displayName;
  final String username;
  final double score;
  final int? rank;
  final CompetitionType competitionType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapXS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: position == 1
              ? const Color(0x14FFD700) // subtle gold tint for 1st place
              : AppStyle.cardBackground,
          borderRadius: AppStyle.pillRadius,
          border: Border.all(color: AppStyle.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapM,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28.0,
              child: Text(
                rank?.toString() ?? '–',
                style: AppStyle.setNumberStyle.copyWith(
                  color: position <= 3
                      ? AppStyle.primaryBlue
                      : AppStyle.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppStyle.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: AppStyle.sheetVariantNameStyle),
                  Text('@$username', style: AppStyle.captionStyle),
                ],
              ),
            ),
            Text(
              _formatScore(score, competitionType),
              style: AppStyle.exerciseNameStyle.copyWith(fontSize: 15.0),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatScore(double score, CompetitionType type) {
    if (score == 0) return '–';
    final intScore = score == score.truncateToDouble();
    final valueText = intScore
        ? score.toInt().toString()
        : score.toString().replaceAll('.', ',');
    switch (type) {
      case CompetitionType.totalVolume:
        return '$valueText kg';
      case CompetitionType.maxWeight:
        return '$valueText kg';
      case CompetitionType.streak:
        return '$valueText days';
      case CompetitionType.totalReps:
        return '$valueText reps';
    }
  }
}
