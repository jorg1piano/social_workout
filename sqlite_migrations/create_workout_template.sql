-- Workout table contains workouts: ie "Chest day", "Pull", etc...
-- This does not connect to anything else
CREATE TABLE workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT
);
