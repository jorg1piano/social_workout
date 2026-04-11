/// Row from the `exercise` table — the library of all exercises available
/// to build a workout from.
///
/// Matches `sqlite/schema.sql` table #4.
class DbExercise {
  final String id;
  final String name;
  final String? description;
  final String? notes;

  const DbExercise({
    required this.id,
    required this.name,
    this.description,
    this.notes,
  });

  factory DbExercise.fromRow(Map<String, Object?> row) {
    return DbExercise(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      notes: row['notes'] as String?,
    );
  }
}
