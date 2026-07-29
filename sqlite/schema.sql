-- Database schema for workout tracking application
-- Tables are ordered to respect foreign key dependencies
-- Uses ULID (Universally Unique Lexicographically Sortable Identifier) for all IDs
-- Format: app-01HJGT8MNTV3X9P0A6Y7Z8C9D (26 chars ULID + 4 char prefix = 30 total)
-- Prefixes: app- (system/app generated), usr- (user created)

-- 1. body_part_category - No dependencies
-- Predefined body part categories for exercises
CREATE TABLE body_part_category (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 2. equipment_category - No dependencies
-- Predefined equipment categories for exercises
CREATE TABLE equipment_category (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 3. workout_template - No dependencies
-- Represents a workout plan (e.g., "Push Day", "Pull Day", "Leg Day")
-- This is the top-level container for a structured workout
CREATE TABLE workout_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  notes TEXT,
  -- archived_at: soft-delete marker. NULL = active. Non-NULL hides the plan
  -- from pickers. Cosmetic only — history lives entirely on the record side
  -- (workout / workout_exercise / exercise_set), so archiving carries no
  -- historical weight and a template can even be hard-deleted with no effect
  -- on past workouts.
  archived_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 4. exercise - No dependencies
-- Individual exercises (e.g., "Barbell Bench Press", "Dumbbell Curl", "Squat")
-- These are the building blocks used in workout templates
CREATE TABLE exercise (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 5. exercise_body_part - Depends on: exercise, body_part_category
-- Junction table linking exercises to their body parts (many-to-many)
CREATE TABLE exercise_body_part (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  exercise_id TEXT NOT NULL,
  body_part_category_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE CASCADE,
  FOREIGN KEY(body_part_category_id) REFERENCES body_part_category(id) ON DELETE RESTRICT
);

-- 6. exercise_equipment - Depends on: exercise, equipment_category
-- Junction table linking exercises to their equipment types (many-to-many)
CREATE TABLE exercise_equipment (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  exercise_id TEXT NOT NULL,
  equipment_category_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE CASCADE,
  FOREIGN KEY(equipment_category_id) REFERENCES equipment_category(id) ON DELETE RESTRICT
);

-- 7. workout - Depends on: workout_template
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

-- 8. exercise_for_workout_template - Depends on: workout_template, exercise
-- Links exercises to workout templates with two-level ordering and swappable variants.
-- This is the PLAN side — a mutable suggestion that only matters at the moment
-- the user presses Start. History never depends on it (see workout_exercise).
--
-- Three orthogonal ordering axes:
--   block_ordering:        which block (superset / circuit) in the plan. A straight
--                          exercise is just a block of one.
--   within_block_ordering: which leg inside the block (1 for a straight exercise;
--                          1,2,3… for the members of a superset that you alternate).
--   exercise_index:        swap-variant number within a single (block, within) slot
--                          (0=default, 1=alternate 1, 2=alternate 2, …).
--
-- IMPORTANT: exercise_index is scoped to a (block, within) slot, not global. You
--            can swap one leg of a superset without disturbing its partner.
--
-- Example: A "Leg Day" template might have:
--   - Block 1 = a superset:
--     - (block=1, within=1, index=0): Leg Extension (default)
--     - (block=1, within=1, index=1): Sissy Squat (swap alternate)
--     - (block=1, within=2, index=0): Lying Leg Curl (superset partner)
--     - (block=1, within=2, index=1): Seated Leg Curl (swap alternate)
--   - Block 2 = a straight exercise:
--     - (block=2, within=1, index=0): Back Squat
--     - (block=2, within=1, index=1): Hack Squat (swap alternate)
--
-- When starting a workout, the user selects one exercise_index per (block, within)
-- slot. The composite (workout_template_id, block_ordering, within_block_ordering,
-- exercise_index) must be unique. A second axis of uniqueness — one row per
-- exercise per slot — makes "swap back to a removed exercise" reactivate the
-- existing (possibly archived) row rather than forking its history.
--
-- archived_at: soft-delete marker. NULL = active. Non-NULL hides the variant from
-- pickers only; it is cosmetic and carries no historical weight.
CREATE TABLE exercise_for_workout_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  workout_template_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  notes TEXT,
  block_ordering INTEGER NOT NULL,
  within_block_ordering INTEGER NOT NULL,
  exercise_index INTEGER DEFAULT 0 NOT NULL,
  archived_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workout_template_id) REFERENCES workout_template(id) ON DELETE CASCADE,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT
);

-- 9. exercise_set_template - Depends on: exercise, exercise_for_workout_template
-- Defines the planned sets for each exercise variant in a template
-- Example: "Barbell Bench Press should have 3 sets of 8-10 reps at 80kg"
--
-- Fields:
--   rir: Reps In Reserve (how many more reps could be done)
--   rpe: Rate of Perceived Exertion (1-10 scale)
--   set_type: warmup, regularSet, dropSet, failure (nullable — NULL = unspecified)
--   rest_time: Recommended rest between sets (in seconds)
--   duration: Duration in seconds for timed exercises (cardio, planks, etc.)
CREATE TABLE exercise_set_template (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  rep_count INTEGER,
  -- weight: DECIMAL(5,2). Sign convention:
  --   > 0  → external load added (e.g. barbell, dumbbell).
  --   = 0  → bodyweight (e.g. push-up, unassisted pull-up).
  --   < 0  → assistance: the machine/band removes this many units from
  --          the lifter's bodyweight (e.g. Assisted Pull-Up at -20 kg).
  -- Queries that sum or average weight across mixed exercises must be
  -- sign-aware; compare against exercise name/tags if you need to
  -- disambiguate intent.
  weight DECIMAL(5,2),
  duration INTEGER,
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER NOT NULL,
  set_type TEXT CHECK (set_type IN ('warmup','regularSet','dropSet','failure')),
  rest_time INTEGER DEFAULT 0 NOT NULL,
  exercise_id TEXT NOT NULL,
  exercise_for_workout_template_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT,
  FOREIGN KEY(exercise_for_workout_template_id) REFERENCES exercise_for_workout_template(id) ON DELETE CASCADE
);

-- 10. workout_exercise - Depends on: workout, exercise, exercise_for_workout_template
-- The session's OWN list of what you did and in what order — the record side.
-- This is the table that makes a logged workout self-contained: order and
-- exercise identity live here, not in the template, so a workout renders
-- entirely from record tables (workout -> workout_exercise -> exercise_set)
-- with no dependency on the plan.
--
-- Fields:
--   exercise_id:           the exercise you actually performed. Single source of
--                          truth for this leg — sets no longer copy it.
--   block_ordering:        which block (superset / circuit) in THIS session.
--   within_block_ordering: which leg inside the block (1 for a straight exercise;
--                          1,2,3… for the members of a superset).
--   source_variant_id:     nullable provenance pointer back to the plan slot the
--                          user picked. ON DELETE SET NULL — the only link from
--                          plan to record, and it can be severed (template renamed,
--                          reordered, archived, or hard-deleted) with zero effect
--                          on the record.
CREATE TABLE workout_exercise (
  id TEXT PRIMARY KEY NOT NULL
    CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  workout_id            TEXT NOT NULL,
  exercise_id           TEXT NOT NULL,      -- what you actually did (single source of truth)
  block_ordering        INTEGER NOT NULL,   -- which block in THIS session
  within_block_ordering INTEGER NOT NULL,   -- leg inside the block (supersets/circuits)
  notes                 TEXT,
  source_variant_id     TEXT,               -- nullable provenance -> exercise_for_workout_template
  created_at            INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at            INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  FOREIGN KEY(workout_id)        REFERENCES workout(id)                       ON DELETE CASCADE,
  FOREIGN KEY(exercise_id)       REFERENCES exercise(id)                      ON DELETE RESTRICT,
  FOREIGN KEY(source_variant_id) REFERENCES exercise_for_workout_template(id) ON DELETE SET NULL
);

-- 11. exercise_set - Depends on: workout_exercise
-- Records the actual sets performed during a workout session.
-- A set's identity is its parent: exercise, session, and block/leg order all
-- come from workout_exercise — the set stores no redundant copy to drift out of
-- sync. Deleting the parent workout_exercise (or its workout) cascades here.
--
-- Example: "User did 10 reps at 100kg for Set 1 of Barbell Bench Press"
--          "User cycled for 20 minutes (1200 seconds)"
--
-- Progression tracking now queries all sets for an exercise by joining through
-- workout_exercise (workout_exercise.exercise_id), across every workout.
--
-- Fields:
--   ordering: The set number within the exercise (1st set, 2nd set, …). For a
--             superset, this doubles as the round number. Nullable.
--             Can have gaps (user skips sets) or duplicates (multiple attempts)
--             Not enforced to be sequential - user has full flexibility
--   attempt_number: Tracks multiple attempts at the same set slot
--             Examples:
--             - Muscle-ups: failed 5 times before succeeding (6 rows, same ordering, attempt 1-6)
--             - Heavy deadlift: missed lockout twice, succeeded third try (3 rows)
--             - Rest-pause sets: 7 reps, rest 30s, 3 more reps (2 rows, same ordering)
--             Default is 1 for single-attempt sets
--   set_type: warmup, regularSet, dropSet, failure
--             Defaults to 'regularSet' so ad-hoc "+ Add Set" rows don't have to
--             specify it. Duplicated here (also on exercise_set_template) so the
--             tracking UI can express warmup status for ad-hoc sets that have no
--             template row, and so the "Previous" column query doesn't need a
--             template join just to read the set type.
CREATE TABLE exercise_set (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  workout_exercise_id TEXT NOT NULL,
  rep_count INTEGER,
  -- weight: DECIMAL(5,2). Sign convention:
  --   > 0  → external load added (e.g. barbell, dumbbell).
  --   = 0  → bodyweight (e.g. push-up, unassisted pull-up).
  --   < 0  → assistance: the machine/band removes this many units from
  --          the lifter's bodyweight (e.g. Assisted Pull-Up at -20 kg).
  -- Queries that sum or average weight across mixed exercises must be
  -- sign-aware; compare against exercise name/tags if you need to
  -- disambiguate intent.
  weight DECIMAL(5,2),
  duration INTEGER,
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER,
  attempt_number INTEGER DEFAULT 1 NOT NULL,
  set_type TEXT NOT NULL DEFAULT 'regularSet'
    CHECK (set_type IN ('warmup','regularSet','dropSet','failure')),
  notes TEXT,
  rest_time INTEGER DEFAULT 0 NOT NULL,
  is_completed INTEGER DEFAULT 0 NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(workout_exercise_id) REFERENCES workout_exercise(id) ON DELETE CASCADE
);

-- Indexes for foreign keys to improve query performance
CREATE INDEX idx_exercise_body_part_exercise_id ON exercise_body_part(exercise_id);
CREATE INDEX idx_exercise_body_part_category_id ON exercise_body_part(body_part_category_id);
CREATE INDEX idx_exercise_equipment_exercise_id ON exercise_equipment(exercise_id);
CREATE INDEX idx_exercise_equipment_category_id ON exercise_equipment(equipment_category_id);
CREATE INDEX idx_workout_template_id ON workout(template_id);
CREATE INDEX idx_exercise_for_workout_template_workout_template_id ON exercise_for_workout_template(workout_template_id);
CREATE INDEX idx_exercise_for_workout_template_exercise_id ON exercise_for_workout_template(exercise_id);
CREATE INDEX idx_exercise_set_template_exercise_id ON exercise_set_template(exercise_id);
CREATE INDEX idx_exercise_set_template_exercise_for_workout_template_id ON exercise_set_template(exercise_for_workout_template_id);
CREATE INDEX idx_workout_exercise_workout_id        ON workout_exercise(workout_id);
CREATE INDEX idx_workout_exercise_exercise_id       ON workout_exercise(exercise_id);
CREATE INDEX idx_workout_exercise_source_variant_id ON workout_exercise(source_variant_id);
CREATE INDEX idx_exercise_set_workout_exercise_id ON exercise_set(workout_exercise_id);

-- Unique constraints to prevent duplicates
CREATE UNIQUE INDEX idx_exercise_body_part_unique ON exercise_body_part(exercise_id, body_part_category_id);
CREATE UNIQUE INDEX idx_exercise_equipment_unique ON exercise_equipment(exercise_id, equipment_category_id);

-- One leg per slot in a session: (workout, block, within) is unique. Same block /
-- different within = a superset; different block / same within is fine.
CREATE UNIQUE INDEX idx_workout_exercise_order
  ON workout_exercise(workout_id, block_ordering, within_block_ordering);

-- Slot / variant uniqueness across the three plan axes.
-- Ensures each (template, block, within, index) combination is unique — prevents
-- duplicate variants and enforces proper exercise slot structure.
CREATE UNIQUE INDEX idx_variant
  ON exercise_for_workout_template(workout_template_id, block_ordering, within_block_ordering, exercise_index);

-- Swap dedup: one row per exercise per (template, block, within) slot, so
-- swapping back to a removed exercise reactivates the existing (possibly archived)
-- row rather than duplicating and forking its history. Full index — archived rows
-- count too.
CREATE UNIQUE INDEX idx_variant_exercise
  ON exercise_for_workout_template(workout_template_id, block_ordering, within_block_ordering, exercise_id);

-- Unique constraint to prevent accidental duplicate attempts.
-- Ensures each (workout_exercise, set number, attempt) combination is unique.
-- Allows multiple attempts at the same set (rest-pause, missed lifts) but prevents
-- logging the same attempt twice.
CREATE UNIQUE INDEX idx_exercise_set_attempt
  ON exercise_set(workout_exercise_id, ordering, attempt_number);

-- ============================================================================
-- Social Feed Tables
-- ============================================================================

-- 11. user_profile - No dependencies
-- Represents users in the system (the local user + friends whose feed items sync down)
CREATE TABLE user_profile (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  display_name TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  is_current_user INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 12. feed_item - Depends on: user_profile, workout (optional), exercise (optional)
-- Social feed entries — workout completions, personal records, streak milestones.
-- Stores denormalized title/description for fast feed rendering without joins.
CREATE TABLE feed_item (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  user_id TEXT NOT NULL,
  item_type TEXT NOT NULL CHECK (item_type IN ('workout_completed', 'personal_record', 'streak_milestone')),
  title TEXT NOT NULL,
  description TEXT,
  workout_id TEXT,
  exercise_id TEXT,
  metric_value DECIMAL(10,2),
  metric_unit TEXT,
  like_count INTEGER NOT NULL DEFAULT 0,
  comment_count INTEGER NOT NULL DEFAULT 0,
  occurred_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE,
  FOREIGN KEY(workout_id) REFERENCES workout(id) ON DELETE SET NULL,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE SET NULL
);

-- 13. feed_like - Depends on: feed_item, user_profile
-- Tracks who liked which feed item
CREATE TABLE feed_like (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  feed_item_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(feed_item_id) REFERENCES feed_item(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

-- 14. feed_comment - Depends on: feed_item, user_profile
-- Comments on feed items
CREATE TABLE feed_comment (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  feed_item_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(feed_item_id) REFERENCES feed_item(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

-- Social feed indexes
CREATE INDEX idx_feed_item_user_id ON feed_item(user_id);
CREATE INDEX idx_feed_item_workout_id ON feed_item(workout_id);
CREATE INDEX idx_feed_item_exercise_id ON feed_item(exercise_id);
CREATE INDEX idx_feed_like_feed_item_id ON feed_like(feed_item_id);
CREATE INDEX idx_feed_like_user_id ON feed_like(user_id);
CREATE INDEX idx_feed_comment_feed_item_id ON feed_comment(feed_item_id);
CREATE INDEX idx_feed_comment_user_id ON feed_comment(user_id);
CREATE INDEX idx_feed_item_occurred_at ON feed_item(occurred_at DESC);
CREATE INDEX idx_feed_item_type ON feed_item(item_type);
CREATE UNIQUE INDEX idx_feed_like_unique ON feed_like(feed_item_id, user_id);

-- ============================================================================
-- Competition Tables
-- ============================================================================

-- 15. competition - Depends on: user_profile
-- A competition between users (e.g., "Most bench press volume in January")
-- Tracks a specific metric across one or more exercises over a date range.
CREATE TABLE competition (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  competition_type TEXT NOT NULL CHECK (competition_type IN ('total_volume', 'max_weight', 'streak', 'total_reps')),
  start_date INTEGER NOT NULL,
  end_date INTEGER NOT NULL,
  created_by TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'completed')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(created_by) REFERENCES user_profile(id) ON DELETE CASCADE
);

-- 16. competition_exercise - Depends on: competition, exercise
-- Which exercises count toward a competition's scoring
CREATE TABLE competition_exercise (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT
);

-- 17. competition_participant - Depends on: competition, user_profile
-- Users who have joined a competition
CREATE TABLE competition_participant (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  joined_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

-- 18. competition_leaderboard_entry - Depends on: competition, user_profile
-- Tracks each participant's current score and rank in a competition
CREATE TABLE competition_leaderboard_entry (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  score DECIMAL(10,2) NOT NULL DEFAULT 0,
  rank INTEGER,
  last_activity_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

-- Competition indexes
CREATE INDEX idx_competition_created_by ON competition(created_by);
CREATE INDEX idx_competition_status ON competition(status);
CREATE INDEX idx_competition_exercise_competition_id ON competition_exercise(competition_id);
CREATE INDEX idx_competition_exercise_exercise_id ON competition_exercise(exercise_id);
CREATE INDEX idx_competition_participant_competition_id ON competition_participant(competition_id);
CREATE INDEX idx_competition_participant_user_id ON competition_participant(user_id);
CREATE INDEX idx_competition_leaderboard_entry_competition_id ON competition_leaderboard_entry(competition_id);
CREATE INDEX idx_competition_leaderboard_entry_user_id ON competition_leaderboard_entry(user_id);
CREATE UNIQUE INDEX idx_competition_exercise_unique ON competition_exercise(competition_id, exercise_id);
CREATE UNIQUE INDEX idx_competition_participant_unique ON competition_participant(competition_id, user_id);
CREATE UNIQUE INDEX idx_competition_leaderboard_entry_unique ON competition_leaderboard_entry(competition_id, user_id);

-- ============================================================================
-- Body Measurement Tables
-- ============================================================================

-- 19. body_measurement - No dependencies
-- Tracks body measurements over time (weight, body fat, circumferences, etc.)
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

-- ============================================================================
-- Planned Workout Tables
-- ============================================================================

-- 20. planned_workout - Depends on: user_profile, workout_template
-- Tracks which users have planned which workouts for which dates.
-- Powers the "who's working out today" Stories row in the social feed.
CREATE TABLE planned_workout (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  user_id TEXT NOT NULL,
  workout_template_id TEXT NOT NULL,
  planned_date INTEGER NOT NULL,
  planned_time INTEGER,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE,
  FOREIGN KEY(workout_template_id) REFERENCES workout_template(id) ON DELETE CASCADE
);

CREATE INDEX idx_planned_workout_user_id ON planned_workout(user_id);
CREATE INDEX idx_planned_workout_template_id ON planned_workout(workout_template_id);
CREATE INDEX idx_planned_workout_date ON planned_workout(planned_date);

-- ============================================================================
-- Training Program Tables
-- ============================================================================

-- 20. training_program - No dependencies
-- Top-level container for a workout program / split.
-- schedule_type determines how program_slots are interpreted:
--   weekly_fixed     — same pattern every week (PPL 6-day, PHUL, Bro Split)
--   rotation         — cycle through workouts regardless of calendar day (SL 5×5, PPL 3-day)
--   multi_week_cycle — repeating block > 1 week where parameters change (5/3/1 = 4 weeks)
--   freeform         — no schedule, user picks from a collection of templates
CREATE TABLE training_program (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  schedule_type TEXT NOT NULL CHECK (schedule_type IN ('weekly_fixed', 'rotation', 'multi_week_cycle', 'freeform')),
  cycle_length_weeks INTEGER,
  days_per_week INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- 21. program_slot - Depends on: training_program, workout_template
-- Maps workout_templates into the program schedule.
-- Interpretation varies by schedule_type:
--   weekly_fixed     — week_number=1, day_of_week=0..6
--   rotation         — week_number=NULL, day_of_week=NULL, slot_order gives cycle position
--   multi_week_cycle — week_number=1..N, day_of_week=0..6
--   freeform         — week_number=NULL, day_of_week=NULL (just a bag of templates)
CREATE TABLE program_slot (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  training_program_id TEXT NOT NULL,
  workout_template_id TEXT,
  week_number INTEGER,
  day_of_week INTEGER CHECK (day_of_week IS NULL OR (day_of_week >= 0 AND day_of_week <= 6)),
  slot_order INTEGER NOT NULL,
  is_rest_day INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(training_program_id) REFERENCES training_program(id) ON DELETE CASCADE,
  FOREIGN KEY(workout_template_id) REFERENCES workout_template(id) ON DELETE SET NULL
);

-- 22. program_enrollment - Depends on: user_profile, training_program
-- Tracks a user's active program and current position within it.
CREATE TABLE program_enrollment (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  user_id TEXT NOT NULL,
  training_program_id TEXT NOT NULL,
  current_week INTEGER NOT NULL DEFAULT 1,
  current_slot_order INTEGER NOT NULL DEFAULT 1,
  started_at INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  cycle_count INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE,
  FOREIGN KEY(training_program_id) REFERENCES training_program(id) ON DELETE CASCADE
);

-- Training program indexes
CREATE INDEX idx_program_slot_training_program_id ON program_slot(training_program_id);
CREATE INDEX idx_program_slot_workout_template_id ON program_slot(workout_template_id);
CREATE INDEX idx_program_enrollment_user_id ON program_enrollment(user_id);
CREATE INDEX idx_program_enrollment_training_program_id ON program_enrollment(training_program_id);
CREATE INDEX idx_program_enrollment_is_active ON program_enrollment(is_active);

-- Unique constraints
CREATE UNIQUE INDEX idx_program_slot_order ON program_slot(training_program_id, slot_order);
CREATE UNIQUE INDEX idx_program_slot_day ON program_slot(training_program_id, week_number, day_of_week)
  WHERE day_of_week IS NOT NULL;
CREATE UNIQUE INDEX idx_program_enrollment_unique ON program_enrollment(user_id, training_program_id);
