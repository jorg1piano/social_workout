-- Database schema for workout tracking application
-- Tables are ordered to respect foreign key dependencies
-- Uses ULID (Universally Unique Lexicographically Sortable Identifier) for all IDs
-- Format: app-01HJGT8MNTV3X9P0A6Y7Z8C9D (26 chars ULID + 4 char prefix = 30 total)
-- Prefixes: app- (system/app generated), usr- (user created)

-- 1. workout_template - No dependencies
-- Represents a workout plan (e.g., "Push Day", "Pull Day", "Leg Day")
-- This is the top-level container for a structured workout
CREATE TABLE workout_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 2. exercise - No dependencies
-- Individual exercises (e.g., "Barbell Bench Press", "Dumbbell Curl", "Squat")
-- These are the building blocks used in workout templates
CREATE TABLE exercise (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  notes TEXT,
  category TEXT,
  body_part TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 3. workout - Depends on: workout_template
-- Represents an actual workout session executed by the user
-- Created when user starts a workout from a template
-- Records start/stop times for the session
CREATE TABLE workout (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  template_id TEXT,
  start_time INTEGER,
  stop_time INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(template_id) REFERENCES workout_template(id) ON DELETE SET NULL
);

-- 4. exercise_for_workout_template - Depends on: workout_template, exercise
-- Links exercises to workout templates with ordering and swappable variants
--
-- Key concepts:
--   ordering: The sequence of exercise slots in the workout (1st exercise, 2nd exercise, etc.)
--   exercise_index: Variant number within the same slot (0=default, 1=alternate 1, 2=alternate 2, etc.)
--
-- IMPORTANT: Multiple exercises can share the same exercise_index as long as they have different ordering values
--            The exercise_index is scoped to each ordering slot, not globally
--
-- Example: A "Push Day" template might have:
--   - Slot 1 (ordering=1): Bench Press variants
--     - exercise_index=0: Barbell Bench Press (default)
--     - exercise_index=1: Dumbbell Bench Press (equipment substitution)
--     - exercise_index=2: Machine Chest Press (injury modification)
--   - Slot 2 (ordering=2): Overhead Press variants
--     - exercise_index=0: Standing Barbell OHP (same index as Barbell Bench, different slot)
--     - exercise_index=1: Seated Dumbbell OHP (same index as Dumbbell Bench, different slot)
--
-- When starting a workout, the user selects one exercise_index per ordering slot
-- The composite (workout_template_id, ordering, exercise_index) must be unique
CREATE TABLE exercise_for_workout_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  workout_template_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  notes TEXT,
  ordering INTEGER NOT NULL,
  exercise_index INTEGER DEFAULT 0 NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workout_template_id) REFERENCES workout_template(id) ON DELETE CASCADE,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT
);

-- 5. exercise_set_template - Depends on: exercise, exercise_for_workout_template
-- Defines the planned sets for each exercise variant in a template
-- Example: "Barbell Bench Press should have 3 sets of 8-10 reps at 80kg"
--
-- Fields:
--   rir: Reps In Reserve (how many more reps could be done)
--   rpe: Rate of Perceived Exertion (1-10 scale)
--   set_type: warmup, regularSet, dropSet, failure, etc.
--   rest_time: Recommended rest between sets (in seconds)
CREATE TABLE exercise_set_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  rep_count INTEGER,
  weight DECIMAL(5,2),
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER NOT NULL,
  set_type TEXT,
  rest_time INTEGER DEFAULT 0 NOT NULL,
  exercise_id TEXT NOT NULL,
  exercise_for_workout_template_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT,
  FOREIGN KEY(exercise_for_workout_template_id) REFERENCES exercise_for_workout_template(id) ON DELETE CASCADE
);

-- 6. exercise_set - Depends on: workout, exercise, exercise_for_workout_template
-- Records the actual sets performed during a workout session
-- Links to exercise_for_workout_template_id to track which variant was used
--
-- Example: "User did 10 reps at 100kg for Set 1 of Barbell Bench Press"
--
-- This allows progression tracking by querying all sets for the same
-- exercise_for_workout_template_id across multiple workout sessions
CREATE TABLE exercise_set (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  rep_count INTEGER,
  weight DECIMAL(5,2),
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER,
  notes TEXT,
  rest_time INTEGER DEFAULT 0 NOT NULL,
  workout_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  exercise_for_workout_template_id TEXT NOT NULL,
  is_completed INTEGER DEFAULT 0 NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workout_id) REFERENCES workout(id) ON DELETE CASCADE,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT,
  FOREIGN KEY(exercise_for_workout_template_id) REFERENCES exercise_for_workout_template(id) ON DELETE RESTRICT
);

-- Indexes for foreign keys to improve query performance
CREATE INDEX idx_workout_template_id ON workout(template_id);
CREATE INDEX idx_exercise_for_workout_template_workout_template_id ON exercise_for_workout_template(workout_template_id);
CREATE INDEX idx_exercise_for_workout_template_exercise_id ON exercise_for_workout_template(exercise_id);
CREATE INDEX idx_exercise_set_template_exercise_id ON exercise_set_template(exercise_id);
CREATE INDEX idx_exercise_set_template_exercise_for_workout_template_id ON exercise_set_template(exercise_for_workout_template_id);
CREATE INDEX idx_exercise_set_workout_id ON exercise_set(workout_id);
CREATE INDEX idx_exercise_set_exercise_id ON exercise_set(exercise_id);
CREATE INDEX idx_exercise_set_exercise_for_workout_template_id ON exercise_set(exercise_for_workout_template_id);

-- Unique constraint to enforce the exercise variant pattern
-- Ensures each (template, ordering, index) combination is unique
-- This prevents duplicate variants and enforces proper exercise slot structure
CREATE UNIQUE INDEX idx_exercise_variant ON exercise_for_workout_template(workout_template_id, ordering, exercise_index);
