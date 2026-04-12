import 'package:flutter/material.dart';

import '../../data/dao/template_dao.dart';
import '../../data/dao/training_program_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_program_slot.dart';
import '../../data/models/db_training_program.dart';
import '../../data/models/db_workout_template.dart';
import '../../data/models/schedule_type.dart';
import '../../style/app_style.dart';

/// Shows the schedule (weekly grid, rotation list, or freeform bag) for a
/// single training program.
class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({
    super.key,
    required this.database,
    required this.programId,
  });

  final AppDatabase database;
  final String programId;

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  late final TrainingProgramDao _programDao;
  late final TemplateDao _templateDao;

  DbTrainingProgram? _program;
  List<DbProgramSlot>? _slots;
  Map<String, DbWorkoutTemplate> _templates = {};

  @override
  void initState() {
    super.initState();
    _programDao = TrainingProgramDao(widget.database.raw);
    _templateDao = TemplateDao(widget.database.raw);
    _load();
  }

  Future<void> _load() async {
    final program = await _programDao.findById(widget.programId);
    if (program == null) return;

    final slots = await _programDao.slotsForProgram(widget.programId);

    // Resolve template names in one batch.
    final templateIds = slots
        .where((s) => s.workoutTemplateId != null)
        .map((s) => s.workoutTemplateId!)
        .toSet()
        .toList();

    final templates = <String, DbWorkoutTemplate>{};
    for (final id in templateIds) {
      final t = await _templateDao.findById(id);
      if (t != null) templates[id] = t;
    }

    if (mounted) {
      setState(() {
        _program = program;
        _slots = slots;
        _templates = templates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null || _slots == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_program!.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_program!.description != null) ...[
            Text(_program!.description!, style: AppStyle.sectionBody),
            const SizedBox(height: 16),
          ],
          _buildScheduleHeader(),
          const SizedBox(height: 12),
          ..._buildScheduleBody(),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader() {
    final p = _program!;
    return Row(
      children: [
        _InfoChip(
          icon: Icons.calendar_today,
          label: p.scheduleType.label,
        ),
        if (p.daysPerWeek != null) ...[
          const SizedBox(width: 8),
          _InfoChip(
            icon: Icons.fitness_center,
            label: '${p.daysPerWeek}x / week',
          ),
        ],
        if (p.cycleLengthWeeks != null && p.cycleLengthWeeks! > 1) ...[
          const SizedBox(width: 8),
          _InfoChip(
            icon: Icons.loop,
            label: '${p.cycleLengthWeeks}-week cycle',
          ),
        ],
      ],
    );
  }

  List<Widget> _buildScheduleBody() {
    return switch (_program!.scheduleType) {
      ScheduleType.weeklyFixed => _buildWeeklyView(),
      ScheduleType.rotation => _buildRotationView(),
      ScheduleType.multiWeekCycle => _buildMultiWeekView(),
      ScheduleType.freeform => _buildFreeformView(),
    };
  }

  /// Weekly: a card per day of the week, showing workout or "Rest".
  List<Widget> _buildWeeklyView() {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final slotsByDay = <int, DbProgramSlot>{};
    for (final s in _slots!) {
      if (s.dayOfWeek != null) slotsByDay[s.dayOfWeek!] = s;
    }

    return [
      for (var d = 0; d < 7; d++)
        _DayRow(
          dayName: days[d],
          slot: slotsByDay[d],
          templateName: slotsByDay[d]?.workoutTemplateId != null
              ? _templates[slotsByDay[d]!.workoutTemplateId]?.name
              : null,
        ),
    ];
  }

  /// Rotation: numbered list of workouts in cycle order.
  List<Widget> _buildRotationView() {
    return [
      for (final slot in _slots!)
        _DayRow(
          dayName: 'Workout ${slot.slotOrder}',
          slot: slot,
          templateName: slot.workoutTemplateId != null
              ? _templates[slot.workoutTemplateId]?.name
              : null,
        ),
    ];
  }

  /// Multi-week: grouped by week number.
  List<Widget> _buildMultiWeekView() {
    final byWeek = <int, List<DbProgramSlot>>{};
    for (final s in _slots!) {
      (byWeek[s.weekNumber ?? 1] ??= []).add(s);
    }
    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];

    return [
      for (final entry in byWeek.entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            'Week ${entry.key}',
            style: AppStyle.cardTitle,
          ),
        ),
        for (final slot in entry.value)
          _DayRow(
            dayName: slot.dayOfWeek != null ? days[slot.dayOfWeek!] : '?',
            slot: slot,
            templateName: slot.workoutTemplateId != null
                ? _templates[slot.workoutTemplateId]?.name
                : null,
          ),
      ],
    ];
  }

  /// Freeform: simple list of available templates.
  List<Widget> _buildFreeformView() {
    return [
      for (final slot in _slots!)
        _DayRow(
          dayName: null,
          slot: slot,
          templateName: slot.workoutTemplateId != null
              ? _templates[slot.workoutTemplateId]?.name
              : null,
        ),
    ];
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({this.dayName, this.slot, this.templateName});

  final String? dayName;
  final DbProgramSlot? slot;
  final String? templateName;

  @override
  Widget build(BuildContext context) {
    final isRest = slot == null || slot!.isRestDay;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (dayName != null)
            SizedBox(
              width: 100,
              child: Text(
                dayName!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isRest ? Colors.grey : null,
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isRest
                    ? Colors.grey.shade100
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isRest ? 'Rest' : (templateName ?? 'Workout'),
                style: TextStyle(
                  color: isRest ? Colors.grey : null,
                  fontWeight: isRest ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyle.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppStyle.chipText),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppStyle.chipText)),
        ],
      ),
    );
  }
}
