import 'competition_status.dart';
import 'competition_type.dart';

/// Row from the `competition` table.
///
/// Matches `sqlite/schema.sql` table #15. Dates are unix epoch seconds.
class DbCompetition {
  final String id;
  final String name;
  final String? description;
  final CompetitionType competitionType;
  final int startDate;
  final int endDate;
  final String createdBy;
  final CompetitionStatus status;

  const DbCompetition({
    required this.id,
    required this.name,
    this.description,
    required this.competitionType,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.status,
  });

  factory DbCompetition.fromRow(Map<String, Object?> row) {
    return DbCompetition(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      competitionType:
          CompetitionType.fromWire(row['competition_type'] as String?),
      startDate: row['start_date']! as int,
      endDate: row['end_date']! as int,
      createdBy: row['created_by']! as String,
      status: CompetitionStatus.fromWire(row['status'] as String?),
    );
  }
}
