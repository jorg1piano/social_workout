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
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
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
  bodyPart TEXT,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 3. workout - Depends on: workout_template
-- Represents an actual workout session executed by the user
-- Created when user starts a workout from a template
-- Records start/stop times for the session
CREATE TABLE workout (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  templateId TEXT,
  startTime INTEGER,
  stopTime INTEGER,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(templateId) REFERENCES workout_template(id) ON DELETE SET NULL
);

-- 4. exercise_for_workout_template - Depends on: workout_template, exercise
-- Links exercises to workout templates with ordering and swappable variants
--
-- Key concepts:
--   ordering: The sequence of exercise slots in the workout (1st exercise, 2nd exercise, etc.)
--   exerciseIndex: Variant number within the same slot (0=default, 1=alternate 1, 2=alternate 2, etc.)
--
-- IMPORTANT: Multiple exercises can share the same exerciseIndex as long as they have different ordering values
--            The exerciseIndex is scoped to each ordering slot, not globally
--
-- Example: A "Push Day" template might have:
--   - Slot 1 (ordering=1): Bench Press variants
--     - exerciseIndex=0: Barbell Bench Press (default)
--     - exerciseIndex=1: Dumbbell Bench Press (equipment substitution)
--     - exerciseIndex=2: Machine Chest Press (injury modification)
--   - Slot 2 (ordering=2): Overhead Press variants
--     - exerciseIndex=0: Standing Barbell OHP (same index as Barbell Bench, different slot)
--     - exerciseIndex=1: Seated Dumbbell OHP (same index as Dumbbell Bench, different slot)
--
-- When starting a workout, the user selects one exerciseIndex per ordering slot
-- The composite (workoutTemplateId, ordering, exerciseIndex) must be unique
CREATE TABLE exercise_for_workout_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  workoutTemplateId TEXT NOT NULL,
  exerciseId TEXT NOT NULL,
  notes TEXT,
  ordering INTEGER NOT NULL,
  exerciseIndex INTEGER DEFAULT 0 NOT NULL,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workoutTemplateId) REFERENCES workout_template(id) ON DELETE CASCADE,
  FOREIGN KEY(exerciseId) REFERENCES exercise(id) ON DELETE RESTRICT
);

-- 5. exercise_set_template - Depends on: exercise, exercise_for_workout_template
-- Defines the planned sets for each exercise variant in a template
-- Example: "Barbell Bench Press should have 3 sets of 8-10 reps at 80kg"
--
-- Fields:
--   RIR: Reps In Reserve (how many more reps could be done)
--   RPE: Rate of Perceived Exertion (1-10 scale)
--   setType: warmup, regularSet, dropSet, failure, etc.
--   restTime: Recommended rest between sets (in seconds)
CREATE TABLE exercise_set_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER NOT NULL,
  setType TEXT,
  restTime INTEGER DEFAULT 0 NOT NULL,
  exerciseId TEXT NOT NULL,
  exerciseForWorkoutTemplateId TEXT NOT NULL,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exerciseId) REFERENCES exercise(id) ON DELETE RESTRICT,
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id) ON DELETE CASCADE
);

-- 6. exercise_set - Depends on: workout, exercise, exercise_for_workout_template
-- Records the actual sets performed during a workout session
-- Links to exerciseForWorkoutTemplateId to track which variant was used
--
-- Example: "User did 10 reps at 100kg for Set 1 of Barbell Bench Press"
--
-- This allows progression tracking by querying all sets for the same
-- exerciseForWorkoutTemplateId across multiple workout sessions
CREATE TABLE exercise_set (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER,
  notes TEXT,
  restTime INTEGER DEFAULT 0 NOT NULL,
  workoutId TEXT NOT NULL,
  exerciseId TEXT NOT NULL,
  exerciseForWorkoutTemplateId TEXT NOT NULL,
  isCompleted INTEGER DEFAULT 0 NOT NULL,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workoutId) REFERENCES workout(id) ON DELETE CASCADE,
  FOREIGN KEY(exerciseId) REFERENCES exercise(id) ON DELETE RESTRICT,
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id) ON DELETE RESTRICT
);

-- Indexes for foreign keys to improve query performance
CREATE INDEX idx_workout_templateId ON workout(templateId);
CREATE INDEX idx_exercise_for_workout_template_workoutTemplateId ON exercise_for_workout_template(workoutTemplateId);
CREATE INDEX idx_exercise_for_workout_template_exerciseId ON exercise_for_workout_template(exerciseId);
CREATE INDEX idx_exercise_set_template_exerciseId ON exercise_set_template(exerciseId);
CREATE INDEX idx_exercise_set_template_exerciseForWorkoutTemplateId ON exercise_set_template(exerciseForWorkoutTemplateId);
CREATE INDEX idx_exercise_set_workoutId ON exercise_set(workoutId);
CREATE INDEX idx_exercise_set_exerciseId ON exercise_set(exerciseId);
CREATE INDEX idx_exercise_set_exerciseForWorkoutTemplateId ON exercise_set(exerciseForWorkoutTemplateId);

-- Unique constraint to enforce the exercise variant pattern
-- Ensures each (template, ordering, index) combination is unique
-- This prevents duplicate variants and enforces proper exercise slot structure
CREATE UNIQUE INDEX idx_exercise_variant ON exercise_for_workout_template(workoutTemplateId, ordering, exerciseIndex);
