/// Metadata for each measurement type: human-friendly label, icon semantics,
/// and the default units the add-form offers.
///
/// The `wireValue` strings match the CHECK constraint on
/// `body_measurement.measurement_type` exactly.
enum MeasurementType {
  weight('weight', 'Weight', ['kg', 'lbs']),
  bodyFatPct('body_fat_pct', 'Body Fat %', ['%']),
  chest('chest', 'Chest', ['cm', 'in']),
  waist('waist', 'Waist', ['cm', 'in']),
  hips('hips', 'Hips', ['cm', 'in']),
  bicepLeft('bicep_left', 'Bicep (Left)', ['cm', 'in']),
  bicepRight('bicep_right', 'Bicep (Right)', ['cm', 'in']),
  thighLeft('thigh_left', 'Thigh (Left)', ['cm', 'in']),
  thighRight('thigh_right', 'Thigh (Right)', ['cm', 'in']),
  calfLeft('calf_left', 'Calf (Left)', ['cm', 'in']),
  calfRight('calf_right', 'Calf (Right)', ['cm', 'in']),
  neck('neck', 'Neck', ['cm', 'in']),
  shoulder('shoulder', 'Shoulder', ['cm', 'in']),
  forearmLeft('forearm_left', 'Forearm (Left)', ['cm', 'in']),
  forearmRight('forearm_right', 'Forearm (Right)', ['cm', 'in']);

  const MeasurementType(this.wireValue, this.label, this.units);

  /// The value stored in the `measurement_type` column.
  final String wireValue;

  /// Human-friendly label shown in the UI.
  final String label;

  /// Allowed units for this type.
  final List<String> units;

  /// Looks up a [MeasurementType] by its wire value. Returns null if unknown.
  static MeasurementType? fromWire(String wire) {
    for (final t in values) {
      if (t.wireValue == wire) return t;
    }
    return null;
  }
}
