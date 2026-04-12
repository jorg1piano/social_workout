import 'package:flutter/material.dart';

import '../../data/dao/competition_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/competition_status.dart';
import '../../data/models/competition_type.dart';
import '../../data/models/db_competition.dart';
import '../../style/app_style.dart';
import 'competition_detail_screen.dart';

/// Lists all competitions with status badges, participant counts, and type
/// icons. Tapping a row navigates to [CompetitionDetailScreen].
class CompetitionListScreen extends StatefulWidget {
  const CompetitionListScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  late final CompetitionDao _dao;
  List<DbCompetition> _competitions = const [];
  Map<String, int> _participantCounts = const {};
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
      final competitions = await _dao.allCompetitions();
      final counts = <String, int>{};
      for (final c in competitions) {
        counts[c.id] = await _dao.participantCount(c.id);
      }
      if (!mounted) return;
      setState(() {
        _competitions = competitions;
        _participantCounts = counts;
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
      appBar: AppBar(title: const Text('Competitions')),
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
          child: Text(_error!, style: AppStyle.captionStyle, textAlign: TextAlign.center),
        ),
      );
    }
    if (_competitions.isEmpty) {
      return const Center(
        child: Text('No competitions yet', style: AppStyle.captionStyle),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapM,
      ),
      itemCount: _competitions.length,
      itemBuilder: (context, index) {
        final comp = _competitions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppStyle.gapM),
          child: _CompetitionCard(
            competition: comp,
            participantCount: _participantCounts[comp.id] ?? 0,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionDetailScreen(
                  database: widget.database,
                  competitionId: comp.id,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.competition,
    required this.participantCount,
    required this.onTap,
  });

  final DbCompetition competition;
  final int participantCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                Icon(
                  _iconForType(competition.competitionType),
                  color: AppStyle.primaryBlue,
                  size: 20.0,
                ),
                const SizedBox(width: AppStyle.gapS),
                Expanded(
                  child: Text(
                    competition.name,
                    style: AppStyle.exerciseNameStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: competition.status),
              ],
            ),
            if (competition.description != null) ...[
              const SizedBox(height: AppStyle.gapS),
              Text(
                competition.description!,
                style: AppStyle.captionStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppStyle.gapM),
            Row(
              children: [
                Icon(Icons.people_outline, size: AppStyle.metaIconSize, color: AppStyle.textSecondary),
                const SizedBox(width: AppStyle.gapXS),
                Text(
                  '$participantCount participant${participantCount == 1 ? '' : 's'}',
                  style: AppStyle.headerMetaStyle,
                ),
                const SizedBox(width: AppStyle.gapL),
                Icon(Icons.category_outlined, size: AppStyle.metaIconSize, color: AppStyle.textSecondary),
                const SizedBox(width: AppStyle.gapXS),
                Text(
                  competition.competitionType.displayLabel,
                  style: AppStyle.headerMetaStyle,
                ),
              ],
            ),
            const SizedBox(height: AppStyle.gapXS),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: AppStyle.metaIconSize, color: AppStyle.textSecondary),
                const SizedBox(width: AppStyle.gapXS),
                Text(
                  '${_formatDate(competition.startDate)} – ${_formatDate(competition.endDate)}',
                  style: AppStyle.headerMetaStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForType(CompetitionType type) {
    switch (type) {
      case CompetitionType.totalVolume:
        return Icons.fitness_center;
      case CompetitionType.maxWeight:
        return Icons.emoji_events;
      case CompetitionType.streak:
        return Icons.local_fire_department;
      case CompetitionType.totalReps:
        return Icons.repeat;
    }
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CompetitionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppStyle.pillRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Text(
        status.displayLabel,
        style: TextStyle(
          color: _textColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case CompetitionStatus.active:
        return AppStyle.completedRowTint;
      case CompetitionStatus.upcoming:
        return AppStyle.accentBlueTint;
      case CompetitionStatus.completed:
        return AppStyle.inputPillBackground;
    }
  }

  Color get _textColor {
    switch (status) {
      case CompetitionStatus.active:
        return AppStyle.finishGreen;
      case CompetitionStatus.upcoming:
        return AppStyle.primaryBlue;
      case CompetitionStatus.completed:
        return AppStyle.textSecondary;
    }
  }
}
