import 'package:flutter/material.dart';

import '../../data/dao/training_program_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_training_program.dart';
import '../../style/app_style.dart';
import 'program_detail_screen.dart';

/// Lists all available training programs and lets the user tap into one
/// to see its weekly schedule or rotation.
class ProgramListScreen extends StatefulWidget {
  const ProgramListScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<ProgramListScreen> {
  late final TrainingProgramDao _dao;
  List<DbTrainingProgram>? _programs;

  @override
  void initState() {
    super.initState();
    _dao = TrainingProgramDao(widget.database.raw);
    _load();
  }

  Future<void> _load() async {
    final programs = await _dao.allPrograms();
    if (mounted) setState(() => _programs = programs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Programs')),
      body: _programs == null
          ? const Center(child: CircularProgressIndicator())
          : _programs!.isEmpty
              ? const Center(child: Text('No programs yet'))
              : ListView.builder(
                  itemCount: _programs!.length,
                  itemBuilder: (context, index) {
                    final program = _programs![index];
                    return _ProgramCard(
                      program: program,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProgramDetailScreen(
                            database: widget.database,
                            programId: program.id,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.onTap});

  final DbTrainingProgram program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(program.name, style: AppStyle.cardTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (program.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  program.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                _Chip(label: program.scheduleType.label),
                if (program.daysPerWeek != null) ...[
                  const SizedBox(width: 8),
                  _Chip(label: '${program.daysPerWeek}x/week'),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppStyle.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppStyle.chipText),
      ),
    );
  }
}
