/// Row from the `workout_template` table.
///
/// Matches `sqlite/schema.sql` table #3.
class DbWorkoutTemplate {
  final String id;
  final String name;
  final String? description;
  final String? notes;

  const DbWorkoutTemplate({
    required this.id,
    required this.name,
    this.description,
    this.notes,
  });

  factory DbWorkoutTemplate.fromRow(Map<String, Object?> row) {
    return DbWorkoutTemplate(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      notes: row['notes'] as String?,
    );
  }
}
