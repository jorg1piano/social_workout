/// Row from the `body_measurement` table — a single measurement entry.
///
/// Matches the schema created by the backend agent. `measurement_type` is one
/// of the CHECK-constrained values (weight, body_fat_pct, chest, etc.).
/// `measured_at` is a Unix epoch second, same as the rest of the schema.
class DbBodyMeasurement {
  final String id;
  final String measurementType;
  final double value;
  final String unit;
  final int measuredAt;
  final String? notes;
  final int createdAt;
  final int updatedAt;

  const DbBodyMeasurement({
    required this.id,
    required this.measurementType,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DbBodyMeasurement.fromMap(Map<String, dynamic> map) {
    return DbBodyMeasurement(
      id: map['id'] as String,
      measurementType: map['measurement_type'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String,
      measuredAt: map['measured_at'] as int,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'measurement_type': measurementType,
      'value': value,
      'unit': unit,
      'measured_at': measuredAt,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
