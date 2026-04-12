-- Body measurement tracking table
CREATE TABLE body_measurement (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  measurement_type TEXT NOT NULL CHECK (measurement_type IN ('weight','body_fat_pct','chest','waist','hips','bicep_left','bicep_right','thigh_left','thigh_right','calf_left','calf_right','neck','shoulder','forearm_left','forearm_right')),
  value DECIMAL(7,2) NOT NULL,
  unit TEXT NOT NULL,
  measured_at INTEGER NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX idx_body_measurement_type ON body_measurement(measurement_type);
CREATE INDEX idx_body_measurement_measured_at ON body_measurement(measured_at DESC);
