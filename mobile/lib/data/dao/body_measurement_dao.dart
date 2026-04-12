import 'package:sqflite/sqflite.dart';

import '../db/ulid.dart';
import '../models/db_body_measurement.dart';

/// DAO for the `body_measurement` table.
///
/// Every INSERT generates a client-side `app-`-prefixed ULID via
/// [Ulid.generate] — IDs are never allocated by the server, in line with
/// the offline-first rule.
class BodyMeasurementDao {
  BodyMeasurementDao(this._db);

  final Database _db;

  /// Inserts a new measurement row. The [measurement] must already have its
  /// `id` set (caller generates via [Ulid.generate]).
  Future<void> insertMeasurement(DbBodyMeasurement measurement) async {
    await _db.insert('body_measurement', measurement.toMap());
  }

  /// Returns all measurements for a given [type], most recent first.
  Future<List<DbBodyMeasurement>> getMeasurementsByType(String type) async {
    final rows = await _db.query(
      'body_measurement',
      where: 'measurement_type = ?',
      whereArgs: [type],
      orderBy: 'measured_at DESC',
    );
    return rows.map(DbBodyMeasurement.fromMap).toList();
  }

  /// Returns all measurements across all types, most recent first.
  Future<List<DbBodyMeasurement>> getAllMeasurements() async {
    final rows = await _db.query(
      'body_measurement',
      orderBy: 'measured_at DESC',
    );
    return rows.map(DbBodyMeasurement.fromMap).toList();
  }

  /// Returns the most recent measurement for each type. Used by the overview
  /// screen to show the latest value per category.
  Future<Map<String, DbBodyMeasurement>> getLatestByType() async {
    final rows = await _db.rawQuery('''
      SELECT bm.*
      FROM body_measurement bm
      INNER JOIN (
        SELECT measurement_type, MAX(measured_at) AS max_at
        FROM body_measurement
        GROUP BY measurement_type
      ) latest ON bm.measurement_type = latest.measurement_type
                AND bm.measured_at = latest.max_at
    ''');
    final map = <String, DbBodyMeasurement>{};
    for (final row in rows) {
      final m = DbBodyMeasurement.fromMap(row);
      map[m.measurementType] = m;
    }
    return map;
  }

  /// Deletes a measurement by its [id].
  Future<void> deleteMeasurement(String id) async {
    await _db.delete(
      'body_measurement',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
