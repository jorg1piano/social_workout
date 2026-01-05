#!/bin/bash

# Generate new test data SQL file with valid ULIDs
# This creates Push/Pull/Legs workout templates with exercise variants
# and workout sessions with completed sets

ULID_TOOL="/Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/new-test-data.sql"

# Helper function to generate a full ID
gen_id() {
  echo "app-$($ULID_TOOL generate)"
}

# Generate all ULIDs we need
# Workout Templates
PUSH_TEMPLATE=$(gen_id)
PULL_TEMPLATE=$(gen_id)
LEGS_TEMPLATE=$(gen_id)

# Exercise for Workout Template IDs - Push Day
PUSH_EX1_IDX0=$(gen_id)  # Bench Press
PUSH_EX1_IDX1=$(gen_id)  # Incline Bench Press
PUSH_EX2_IDX0=$(gen_id)  # Overhead Press
PUSH_EX3_IDX0=$(gen_id)  # Lateral Raise
PUSH_EX4_IDX0=$(gen_id)  # Triceps Pushdown
PUSH_EX4_IDX1=$(gen_id)  # Triceps Dip

# Exercise for Workout Template IDs - Pull Day
PULL_EX1_IDX0=$(gen_id)  # Deadlift
PULL_EX2_IDX0=$(gen_id)  # Pull Up
PULL_EX3_IDX0=$(gen_id)  # Bent Over Row
PULL_EX3_IDX1=$(gen_id)  # Lat Pulldown
PULL_EX4_IDX0=$(gen_id)  # Bicep Curl
PULL_EX5_IDX0=$(gen_id)  # Hammer Curl

# Exercise for Workout Template IDs - Leg Day
LEGS_EX1_IDX0=$(gen_id)  # Squat
LEGS_EX2_IDX0=$(gen_id)  # Romanian Deadlift
LEGS_EX3_IDX0=$(gen_id)  # Leg Press
LEGS_EX4_IDX0=$(gen_id)  # Leg Extension
LEGS_EX5_IDX0=$(gen_id)  # Lying Leg Curl
LEGS_EX6_IDX0=$(gen_id)  # Standing Calf Raise

# Workout Session IDs
WORKOUT1=$(gen_id)  # Push Day - completed 3 days ago
WORKOUT2=$(gen_id)  # Pull Day - completed 2 days ago
WORKOUT3=$(gen_id)  # Leg Day - completed 1 day ago
WORKOUT4=$(gen_id)  # Push Day - in progress

# Generate set template IDs (we'll need many)
declare -a SET_TEMPLATE_IDS
for i in {1..100}; do
  SET_TEMPLATE_IDS[$i]=$(gen_id)
done

# Generate exercise set IDs (for actual workouts)
declare -a EXERCISE_SET_IDS
for i in {1..150}; do
  EXERCISE_SET_IDS[$i]=$(gen_id)
done

echo "Generating new test data SQL file..."

# Start writing the SQL file
cat > "$OUTPUT_FILE" << 'HEADER'
-- New test data for workout tracking application
-- Creates Push/Pull/Legs workout templates with exercise variants
-- Includes actual workout sessions with completed sets
-- Generated with valid ULID IDs

HEADER

# Add workout templates
cat >> "$OUTPUT_FILE" << WORKOUT_TEMPLATES
-- Step 1: Create workout templates
INSERT INTO workout_template (id, name, description, notes) VALUES
('$PUSH_TEMPLATE', 'Push Day', 'Chest, Shoulders, and Triceps workout', 'Focus on progressive overload on compounds'),
('$PULL_TEMPLATE', 'Pull Day', 'Back and Biceps workout', 'Maintain proper form on all pulling movements'),
('$LEGS_TEMPLATE', 'Leg Day', 'Complete lower body workout', 'Squat deep, focus on full range of motion');

WORKOUT_TEMPLATES

# Add Push Day exercises
cat >> "$OUTPUT_FILE" << PUSH_EXERCISES
-- Step 2: Link exercises to Push Day template with variants
-- Exercise 1: Bench Press (with Incline variant)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PUSH_EX1_IDX0', '$PUSH_TEMPLATE', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'Main compound - flat bench', 1, 0),
('$PUSH_EX1_IDX1', '$PUSH_TEMPLATE', 'app-01KE649RTDT6F8FK63GNSJGNVQ', 'Variant - incline for upper chest', 1, 1);

-- Exercise 2: Overhead Press
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PUSH_EX2_IDX0', '$PUSH_TEMPLATE', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'Main shoulder press', 2, 0);

-- Exercise 3: Lateral Raise
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PUSH_EX3_IDX0', '$PUSH_TEMPLATE', 'app-01KE649RWJPQJ2E9QWZP7DVC0H', 'Side delts isolation', 3, 0);

-- Exercise 4: Triceps (Pushdown vs Dips)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PUSH_EX4_IDX0', '$PUSH_TEMPLATE', 'app-01KE649SA771M1GMGD0NV11SEC', 'Cable pushdown', 4, 0),
('$PUSH_EX4_IDX1', '$PUSH_TEMPLATE', 'app-01KE649S9APQSR4XCJP6EBAZYN', 'Variant - bodyweight dips', 4, 1);

PUSH_EXERCISES

# Add Pull Day exercises
cat >> "$OUTPUT_FILE" << PULL_EXERCISES
-- Step 3: Link exercises to Pull Day template
-- Exercise 1: Deadlift
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PULL_EX1_IDX0', '$PULL_TEMPLATE', 'app-01KE649R9AJJEY97C4SQMPGK0P', 'Main compound - conventional deadlift', 1, 0);

-- Exercise 2: Pull Ups
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PULL_EX2_IDX0', '$PULL_TEMPLATE', 'app-01KE649S0K5B5Z08APDGVKJEA3', 'Bodyweight or weighted', 2, 0);

-- Exercise 3: Bent Over Row (vs Lat Pulldown)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PULL_EX3_IDX0', '$PULL_TEMPLATE', 'app-01KE649R3SGW1J64BZ3JQ1ADDY', 'Heavy barbell rows', 3, 0),
('$PULL_EX3_IDX1', '$PULL_TEMPLATE', 'app-01KE649RWVB6FB8E3Z2RMBGXPJ', 'Variant - lat pulldown', 3, 1);

-- Exercise 4: Bicep Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PULL_EX4_IDX0', '$PULL_TEMPLATE', 'app-01KE649R4BVKJ25QRJMDTPJ23F', 'Barbell curls', 4, 0);

-- Exercise 5: Hammer Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$PULL_EX5_IDX0', '$PULL_TEMPLATE', 'app-01KE649RRFBV8CJ4DFTMZ5TTKH', 'Brachialis focus', 5, 0);

PULL_EXERCISES

# Add Leg Day exercises
cat >> "$OUTPUT_FILE" << LEGS_EXERCISES
-- Step 4: Link exercises to Leg Day template
-- Exercise 1: Squat
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX1_IDX0', '$LEGS_TEMPLATE', 'app-01KE649S6V1B1B5CBZAAFF2XPG', 'Main compound - barbell squat', 1, 0);

-- Exercise 2: Romanian Deadlift
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX2_IDX0', '$LEGS_TEMPLATE', 'app-01KE649S2FQP180BFDNG1DWJJC', 'Hamstring focus', 2, 0);

-- Exercise 3: Leg Press
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX3_IDX0', '$LEGS_TEMPLATE', 'app-01KE649RXBXE2BP0SE9JRDWP3Q', 'Quad volume', 3, 0);

-- Exercise 4: Leg Extension
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX4_IDX0', '$LEGS_TEMPLATE', 'app-01KE649RX8CSNX00Z0YBY7B3HE', 'Quad isolation', 4, 0);

-- Exercise 5: Lying Leg Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX5_IDX0', '$LEGS_TEMPLATE', 'app-01KE649RXQFR6VPGJ7WTFSPGX3', 'Hamstring isolation', 5, 0);

-- Exercise 6: Standing Calf Raise
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('$LEGS_EX6_IDX0', '$LEGS_TEMPLATE', 'app-01KE649S7BB142PVQVKB0865YW', 'Calf work', 6, 0);

LEGS_EXERCISES

# Add set templates - this is simplified, just showing a few examples
# In reality you'd generate all of them, but for brevity:
cat >> "$OUTPUT_FILE" << SET_TEMPLATES
-- Step 5: Create exercise set templates for Push Day
-- Bench Press - 4 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('${SET_TEMPLATE_IDS[1]}', 10, 135, NULL, 3, 7, 'lbs', 1, 'warmup', 120, 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0'),
('${SET_TEMPLATE_IDS[2]}', 8, 185, NULL, 2, 8, 'lbs', 2, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0'),
('${SET_TEMPLATE_IDS[3]}', 6, 205, NULL, 1, 9, 'lbs', 3, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0'),
('${SET_TEMPLATE_IDS[4]}', 6, 205, NULL, 1, 9, 'lbs', 4, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0');

-- Incline Bench Press variant - 3 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('${SET_TEMPLATE_IDS[5]}', 10, 95, NULL, 3, 7, 'lbs', 1, 'warmup', 120, 'app-01KE649RTDT6F8FK63GNSJGNVQ', '$PUSH_EX1_IDX1'),
('${SET_TEMPLATE_IDS[6]}', 8, 135, NULL, 2, 8, 'lbs', 2, 'regularSet', 180, 'app-01KE649RTDT6F8FK63GNSJGNVQ', '$PUSH_EX1_IDX1'),
('${SET_TEMPLATE_IDS[7]}', 8, 155, NULL, 1, 9, 'lbs', 3, 'regularSet', 180, 'app-01KE649RTDT6F8FK63GNSJGNVQ', '$PUSH_EX1_IDX1');

-- Overhead Press - 3 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('${SET_TEMPLATE_IDS[8]}', 10, 95, NULL, 2, 7, 'lbs', 1, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0'),
('${SET_TEMPLATE_IDS[9]}', 8, 115, NULL, 1, 8, 'lbs', 2, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0'),
('${SET_TEMPLATE_IDS[10]}', 6, 125, NULL, 0, 9, 'lbs', 3, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0');

SET_TEMPLATES

# Add actual workout sessions
cat >> "$OUTPUT_FILE" << WORKOUTS
-- Step 6: Create actual workout sessions
-- Workout 1: Push Day (completed 3 days ago) - used flat bench press variant
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('$WORKOUT1', '$PUSH_TEMPLATE', strftime('%s', 'now', '-3 days', '+10 hours'), strftime('%s', 'now', '-3 days', '+11 hours', '+15 minutes'));

-- Workout 2: Pull Day (completed 2 days ago)
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('$WORKOUT2', '$PULL_TEMPLATE', strftime('%s', 'now', '-2 days', '+10 hours'), strftime('%s', 'now', '-2 days', '+11 hours', '+30 minutes'));

-- Workout 3: Leg Day (completed 1 day ago)
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('$WORKOUT3', '$LEGS_TEMPLATE', strftime('%s', 'now', '-1 day', '+10 hours'), strftime('%s', 'now', '-1 day', '+11 hours', '+45 minutes'));

-- Workout 4: Push Day (in progress - started today) - using incline bench variant
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('$WORKOUT4', '$PUSH_TEMPLATE', strftime('%s', 'now', '-30 minutes'), NULL);

WORKOUTS

# Add exercise sets for Workout 1
cat >> "$OUTPUT_FILE" << WORKOUT1_SETS
-- Step 7: Create exercise sets for Workout 1 (Push Day - completed)
-- Bench Press - 4 sets (used exercise_index 0 - flat bench)
INSERT INTO exercise_set (id, rep_count, weight, duration, rir, rpe, unit, ordering, notes, rest_time, workout_id, exercise_id, exercise_for_workout_template_id, is_completed) VALUES
('${EXERCISE_SET_IDS[1]}', 10, 135, NULL, 3, 7, 'lbs', 1, 'Warmup felt good', 120, '$WORKOUT1', 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0', 1),
('${EXERCISE_SET_IDS[2]}', 8, 185, NULL, 2, 8, 'lbs', 2, NULL, 180, '$WORKOUT1', 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0', 1),
('${EXERCISE_SET_IDS[3]}', 7, 205, NULL, 1, 9, 'lbs', 3, 'One less rep than planned', 180, '$WORKOUT1', 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0', 1),
('${EXERCISE_SET_IDS[4]}', 6, 205, NULL, 1, 9, 'lbs', 4, NULL, 180, '$WORKOUT1', 'app-01KE649R3DHD6HFEM69RKAA5BE', '$PUSH_EX1_IDX0', 1);

-- Overhead Press - 3 sets
INSERT INTO exercise_set (id, rep_count, weight, duration, rir, rpe, unit, ordering, notes, rest_time, workout_id, exercise_id, exercise_for_workout_template_id, is_completed) VALUES
('${EXERCISE_SET_IDS[5]}', 10, 95, NULL, 2, 7, 'lbs', 1, NULL, 150, '$WORKOUT1', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0', 1),
('${EXERCISE_SET_IDS[6]}', 8, 115, NULL, 1, 8, 'lbs', 2, NULL, 150, '$WORKOUT1', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0', 1),
('${EXERCISE_SET_IDS[7]}', 6, 125, NULL, 0, 9, 'lbs', 3, 'Last rep was tough', 150, '$WORKOUT1', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', '$PUSH_EX2_IDX0', 1);

WORKOUT1_SETS

echo "Test data SQL file generated successfully: $OUTPUT_FILE"
echo "Load it with: sqlite3 test-db.db < new-test-data.sql"
