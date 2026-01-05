-- Test data for workout tracking application
-- Push/Pull/Legs workout templates with exercises
-- Uses ULID format: app-{26 character ULID}

-- Insert exercises
INSERT INTO exercise (id, name, description, category, bodyPart) VALUES
  -- Push exercises
  ('app-01HJE0000BENCH0000000001',  'Barbell Bench Press', 'Compound chest exercise', 'Push', 'Chest'),
  ('app-01HJE0000INCLN0000000002',  'Incline Dumbbell Press', 'Upper chest focus', 'Push', 'Chest'),
  ('app-01HJE0000OVRPR0000000003',  'Overhead Press', 'Compound shoulder exercise', 'Push', 'Shoulders'),
  ('app-01HJE0000LATER0000000004',  'Lateral Raises', 'Isolation shoulder exercise', 'Push', 'Shoulders'),
  ('app-01HJE0000TRICP0000000005',  'Tricep Pushdowns', 'Isolation tricep exercise', 'Push', 'Triceps'),
  ('app-01HJE0000DIPSX0000000006',  'Dips', 'Compound chest and tricep exercise', 'Push', 'Chest'),

  -- Pull exercises
  ('app-01HJE0000DEADL0000000007',  'Deadlift', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HJE0000PLLUP0000000008',  'Pull-ups', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HJE0000BBROW0000000009',  'Barbell Rows', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HJE0000LATPD000000000A',  'Lat Pulldowns', 'Isolation back exercise', 'Pull', 'Back'),
  ('app-01HJE0000FACEP000000000B',  'Face Pulls', 'Rear delt and upper back', 'Pull', 'Back'),
  ('app-01HJE0000BBCRL000000000C',  'Barbell Curls', 'Isolation bicep exercise', 'Pull', 'Biceps'),
  ('app-01HJE0000HMCRL000000000D',  'Hammer Curls', 'Isolation bicep exercise', 'Pull', 'Biceps'),

  -- Leg exercises
  ('app-01HJE0000SQUAT000000000E',  'Barbell Squat', 'Compound leg exercise', 'Legs', 'Legs'),
  ('app-01HJE0000RMDLF000000000F',  'Romanian Deadlift', 'Hamstring focus', 'Legs', 'Legs'),
  ('app-01HJE0000LGPRS000000000G',  'Leg Press', 'Compound leg exercise', 'Legs', 'Legs'),
  ('app-01HJE0000LGCRL000000000H',  'Leg Curls', 'Isolation hamstring exercise', 'Legs', 'Legs'),
  ('app-01HJE0000LGEXT000000000J',  'Leg Extensions', 'Isolation quad exercise', 'Legs', 'Legs'),
  ('app-01HJE0000CALFS000000000K',  'Calf Raises', 'Isolation calf exercise', 'Legs', 'Calves');

-- Insert workout templates
INSERT INTO workout_template (id, name, description, notes) VALUES
  ('app-01HJT0000PUSHD0000000001', 'Push Day', 'Chest, Shoulders, and Triceps workout', 'Focus on progressive overload'),
  ('app-01HJT0000PULLD0000000002', 'Pull Day', 'Back and Biceps workout', 'Maintain strict form on all pulling movements'),
  ('app-01HJT0000LEGSD0000000003', 'Leg Day', 'Complete lower body workout', 'Don''t skip leg day!');

-- Link exercises to Push Day template
INSERT INTO exercise_for_workout_template
  (id,                            workoutTemplateId,           exerciseId,                      ordering, exerciseIndex, notes) VALUES
  ('app-01HJM0000PUSH1000000001', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000BENCH0000000001', 1,        0,             'Main compound movement'),      -- Barbell Bench Press
  ('app-01HJM0000PUSH2000000002', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000INCLN0000000002', 2,        0,             'Upper chest focus'),           -- Incline Dumbbell Press
  ('app-01HJM0000PUSH3000000003', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000OVRPR0000000003', 3,        0,             'Main shoulder movement'),      -- Overhead Press
  ('app-01HJM0000PUSH4000000004', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000LATER0000000004', 4,        0,             'Side delts'),                  -- Lateral Raises
  ('app-01HJM0000PUSH5000000005', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000TRICP0000000005', 5,        0,             'Tricep finisher'),             -- Tricep Pushdowns
  ('app-01HJM0000PUSH6000000006', 'app-01HJT0000PUSHD0000000001', 'app-01HJE0000DIPSX0000000006', 6,        0,             'Optional if energy remains');  -- Dips

-- Link exercises to Pull Day template
INSERT INTO exercise_for_workout_template
  (id,                            workoutTemplateId,           exerciseId,                      ordering, exerciseIndex, notes) VALUES
  ('app-01HJM0000PULL1000000007', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000DEADL0000000007', 1,        0,             'Main compound movement'),  -- Deadlift
  ('app-01HJM0000PULL2000000008', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000PLLUP0000000008', 2,        0,             'Bodyweight or weighted'),  -- Pull-ups
  ('app-01HJM0000PULL3000000009', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000BBROW0000000009', 3,        0,             'Heavy rows'),              -- Barbell Rows
  ('app-01HJM0000PULL400000000A', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000LATPD000000000A', 4,        0,             'Back width'),              -- Lat Pulldowns
  ('app-01HJM0000PULL500000000B', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000FACEP000000000B', 5,        0,             'Rear delt health'),        -- Face Pulls
  ('app-01HJM0000PULL600000000C', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000BBCRL000000000C', 6,        0,             'Bicep volume'),            -- Barbell Curls
  ('app-01HJM0000PULL700000000D', 'app-01HJT0000PULLD0000000002', 'app-01HJE0000HMCRL000000000D', 7,        0,             'Brachialis focus');        -- Hammer Curls

-- Link exercises to Leg Day template
INSERT INTO exercise_for_workout_template
  (id,                            workoutTemplateId,           exerciseId,                      ordering, exerciseIndex, notes) VALUES
  ('app-01HJM0000LEGS100000000E', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000SQUAT000000000E', 1,        0,             'Main compound movement'),  -- Barbell Squat
  ('app-01HJM0000LEGS200000000F', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000RMDLF000000000F', 2,        0,             'Hamstring focus'),         -- Romanian Deadlift
  ('app-01HJM0000LEGS300000000G', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000LGPRS000000000G', 3,        0,             'Quad volume'),             -- Leg Press
  ('app-01HJM0000LEGS400000000H', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000LGCRL000000000H', 4,        0,             'Hamstring isolation'),     -- Leg Curls
  ('app-01HJM0000LEGS500000000J', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000LGEXT000000000J', 5,        0,             'Quad isolation'),          -- Leg Extensions
  ('app-01HJM0000LEGS600000000K', 'app-01HJT0000LEGSD0000000003', 'app-01HJE0000CALFS000000000K', 6,        0,             'Don''t forget calves');    -- Calf Raises

-- Add set templates for Push Day exercises
-- Barbell Bench Press
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET01000000001', 'app-01HJE0000BENCH0000000001', 'app-01HJM0000PUSH1000000001', 8,        135,    'lbs', 1,        'warmup',     120),
  ('app-01HJS0000SET01000000002', 'app-01HJE0000BENCH0000000001', 'app-01HJM0000PUSH1000000001', 12,       185,    'lbs', 2,        'regularSet', 180),
  ('app-01HJS0000SET01000000003', 'app-01HJE0000BENCH0000000001', 'app-01HJM0000PUSH1000000001', 10,       205,    'lbs', 3,        'regularSet', 180),
  ('app-01HJS0000SET01000000004', 'app-01HJE0000BENCH0000000001', 'app-01HJM0000PUSH1000000001', 8,        225,    'lbs', 4,        'regularSet', 180);

-- Incline Dumbbell Press
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET02000000005', 'app-01HJE0000INCLN0000000002', 'app-01HJM0000PUSH2000000002', 12,       60,     'lbs', 1,        'regularSet', 120),
  ('app-01HJS0000SET02000000006', 'app-01HJE0000INCLN0000000002', 'app-01HJM0000PUSH2000000002', 10,       70,     'lbs', 2,        'regularSet', 120),
  ('app-01HJS0000SET02000000007', 'app-01HJE0000INCLN0000000002', 'app-01HJM0000PUSH2000000002', 8,        75,     'lbs', 3,        'regularSet', 120);

-- Overhead Press
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET03000000008', 'app-01HJE0000OVRPR0000000003', 'app-01HJM0000PUSH3000000003', 10,       95,     'lbs', 1,        'regularSet', 150),
  ('app-01HJS0000SET03000000009', 'app-01HJE0000OVRPR0000000003', 'app-01HJM0000PUSH3000000003', 8,        115,    'lbs', 2,        'regularSet', 150),
  ('app-01HJS0000SET0300000000A', 'app-01HJE0000OVRPR0000000003', 'app-01HJM0000PUSH3000000003', 6,        125,    'lbs', 3,        'regularSet', 150);

-- Lateral Raises
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0400000000B', 'app-01HJE0000LATER0000000004', 'app-01HJM0000PUSH4000000004', 15,       20,     'lbs', 1,        'regularSet', 90),
  ('app-01HJS0000SET0400000000C', 'app-01HJE0000LATER0000000004', 'app-01HJM0000PUSH4000000004', 15,       20,     'lbs', 2,        'regularSet', 90),
  ('app-01HJS0000SET0400000000D', 'app-01HJE0000LATER0000000004', 'app-01HJM0000PUSH4000000004', 15,       20,     'lbs', 3,        'regularSet', 90);

-- Tricep Pushdowns
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0500000000E', 'app-01HJE0000TRICP0000000005', 'app-01HJM0000PUSH5000000005', 12,       70,     'lbs', 1,        'regularSet', 90),
  ('app-01HJS0000SET0500000000F', 'app-01HJE0000TRICP0000000005', 'app-01HJM0000PUSH5000000005', 12,       80,     'lbs', 2,        'regularSet', 90),
  ('app-01HJS0000SET0500000000G', 'app-01HJE0000TRICP0000000005', 'app-01HJM0000PUSH5000000005', 10,       90,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Pull Day exercises
-- Deadlift
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0600000000H', 'app-01HJE0000DEADL0000000007', 'app-01HJM0000PULL1000000007', 8,        135,    'lbs', 1,        'warmup',     180),
  ('app-01HJS0000SET0600000000J', 'app-01HJE0000DEADL0000000007', 'app-01HJM0000PULL1000000007', 5,        225,    'lbs', 2,        'regularSet', 240),
  ('app-01HJS0000SET0600000000K', 'app-01HJE0000DEADL0000000007', 'app-01HJM0000PULL1000000007', 5,        275,    'lbs', 3,        'regularSet', 240),
  ('app-01HJS0000SET0600000000M', 'app-01HJE0000DEADL0000000007', 'app-01HJM0000PULL1000000007', 5,        315,    'lbs', 4,        'regularSet', 240);

-- Pull-ups
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0700000000N', 'app-01HJE0000PLLUP0000000008', 'app-01HJM0000PULL2000000008', 10,       0,      'lbs', 1,        'regularSet', 120),
  ('app-01HJS0000SET0700000000P', 'app-01HJE0000PLLUP0000000008', 'app-01HJM0000PULL2000000008', 8,        0,      'lbs', 2,        'regularSet', 120),
  ('app-01HJS0000SET0700000000Q', 'app-01HJE0000PLLUP0000000008', 'app-01HJM0000PULL2000000008', 6,        0,      'lbs', 3,        'regularSet', 120);

-- Barbell Rows
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0800000000R', 'app-01HJE0000BBROW0000000009', 'app-01HJM0000PULL3000000009', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01HJS0000SET0800000000S', 'app-01HJE0000BBROW0000000009', 'app-01HJM0000PULL3000000009', 8,        155,    'lbs', 2,        'regularSet', 150),
  ('app-01HJS0000SET0800000000T', 'app-01HJE0000BBROW0000000009', 'app-01HJM0000PULL3000000009', 8,        165,    'lbs', 3,        'regularSet', 150);

-- Barbell Curls
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET0900000000V', 'app-01HJE0000BBCRL000000000C', 'app-01HJM0000PULL600000000C', 12,       65,     'lbs', 1,        'regularSet', 90),
  ('app-01HJS0000SET0900000000W', 'app-01HJE0000BBCRL000000000C', 'app-01HJM0000PULL600000000C', 10,       75,     'lbs', 2,        'regularSet', 90),
  ('app-01HJS0000SET0900000000X', 'app-01HJE0000BBCRL000000000C', 'app-01HJM0000PULL600000000C', 8,        85,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Leg Day exercises
-- Barbell Squat
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET1000000000Y', 'app-01HJE0000SQUAT000000000E', 'app-01HJM0000LEGS100000000E', 10,       135,    'lbs', 1,        'warmup',     180),
  ('app-01HJS0000SET1000000000Z', 'app-01HJE0000SQUAT000000000E', 'app-01HJM0000LEGS100000000E', 8,        185,    'lbs', 2,        'regularSet', 240),
  ('app-01HJS0000SET10000000010', 'app-01HJE0000SQUAT000000000E', 'app-01HJM0000LEGS100000000E', 8,        225,    'lbs', 3,        'regularSet', 240),
  ('app-01HJS0000SET10000000011', 'app-01HJE0000SQUAT000000000E', 'app-01HJM0000LEGS100000000E', 6,        245,    'lbs', 4,        'regularSet', 240);

-- Romanian Deadlift
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET11000000012', 'app-01HJE0000RMDLF000000000F', 'app-01HJM0000LEGS200000000F', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01HJS0000SET11000000013', 'app-01HJE0000RMDLF000000000F', 'app-01HJM0000LEGS200000000F', 10,       155,    'lbs', 2,        'regularSet', 150),
  ('app-01HJS0000SET11000000014', 'app-01HJE0000RMDLF000000000F', 'app-01HJM0000LEGS200000000F', 8,        175,    'lbs', 3,        'regularSet', 150);

-- Leg Press
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET12000000015', 'app-01HJE0000LGPRS000000000G', 'app-01HJM0000LEGS300000000G', 12,       270,    'lbs', 1,        'regularSet', 120),
  ('app-01HJS0000SET12000000016', 'app-01HJE0000LGPRS000000000G', 'app-01HJM0000LEGS300000000G', 12,       315,    'lbs', 2,        'regularSet', 120),
  ('app-01HJS0000SET12000000017', 'app-01HJE0000LGPRS000000000G', 'app-01HJM0000LEGS300000000G', 10,       360,    'lbs', 3,        'regularSet', 120);

-- Calf Raises
INSERT INTO exercise_set_template
  (id,                            exerciseId,                      exerciseForWorkoutTemplateId, repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01HJS0000SET13000000018', 'app-01HJE0000CALFS000000000K', 'app-01HJM0000LEGS600000000K', 15,       135,    'lbs', 1,        'regularSet', 60),
  ('app-01HJS0000SET13000000019', 'app-01HJE0000CALFS000000000K', 'app-01HJM0000LEGS600000000K', 15,       135,    'lbs', 2,        'regularSet', 60),
  ('app-01HJS0000SET1300000001A', 'app-01HJE0000CALFS000000000K', 'app-01HJM0000LEGS600000000K', 15,       135,    'lbs', 3,        'regularSet', 60);
