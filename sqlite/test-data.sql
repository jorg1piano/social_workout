-- Test data for workout tracking application
-- Push/Pull/Legs workout templates with exercises
-- Uses ULID format: app-{26 character ULID}

-- Insert exercises
INSERT INTO exercise (id, name, description, category, bodyPart) VALUES
  -- Push exercises
  ('app-01HQER8K3MBENCHA9X7TY2GQ4W',  'Barbell Bench Press', 'Compound chest exercise', 'Push', 'Chest'),
  ('app-01HQER8K3MINCLNBH6VPW5RN8X',  'Incline Dumbbell Press', 'Upper chest focus', 'Push', 'Chest'),
  ('app-01HQER8K3MOVRPRCJ8ZSXM4KTY',  'Overhead Press', 'Compound shoulder exercise', 'Push', 'Shoulders'),
  ('app-01HQER8K3MLATERD9WN2FQ7HPZ',  'Lateral Raises', 'Isolation shoulder exercise', 'Push', 'Shoulders'),
  ('app-01HQER8K3MTRICPEY3BG8VK5J0',  'Tricep Pushdowns', 'Isolation tricep exercise', 'Push', 'Triceps'),
  ('app-01HQER8K3MDIPSXF4PC9HR6WN1',  'Dips', 'Compound chest and tricep exercise', 'Push', 'Chest'),

  -- Pull exercises
  ('app-01HQER8K3NDEADLG5QD0AS7XP2',  'Deadlift', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HQER8K3NPLLUPHR8E1BT8YR3',  'Pull-ups', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HQER8K3NBBROWJ9FZ2CV9ZS4',  'Barbell Rows', 'Compound back exercise', 'Pull', 'Back'),
  ('app-01HQER8K3NLATPDK0G13DWA0T5',  'Lat Pulldowns', 'Isolation back exercise', 'Pull', 'Back'),
  ('app-01HQER8K3NFACEPM1HX4EXBAV6',  'Face Pulls', 'Rear delt and upper back', 'Pull', 'Back'),
  ('app-01HQER8K3NBBCRLN2JY5FYCBW7',  'Barbell Curls', 'Isolation bicep exercise', 'Pull', 'Biceps'),
  ('app-01HQER8K3NHMCRLP3KZ6GZDCX8',  'Hammer Curls', 'Isolation bicep exercise', 'Pull', 'Biceps'),

  -- Leg exercises
  ('app-01HQER8K3PSQUATQ4M07H0EDY9',  'Barbell Squat', 'Compound leg exercise', 'Legs', 'Legs'),
  ('app-01HQER8K3PRMDLFR5N18J1FEZA',  'Romanian Deadlift', 'Hamstring focus', 'Legs', 'Legs'),
  ('app-01HQER8K3PLGPRSS6P29K2GF0B',  'Leg Press', 'Compound leg exercise', 'Legs', 'Legs'),
  ('app-01HQER8K3PLGCRLT7Q3AM3HG1C',  'Leg Curls', 'Isolation hamstring exercise', 'Legs', 'Legs'),
  ('app-01HQER8K3PLGEXTV8R4BN4JH2D',  'Leg Extensions', 'Isolation quad exercise', 'Legs', 'Legs'),
  ('app-01HQER8K3PCALFSW9S5CP5KJ3E',  'Calf Raises', 'Isolation calf exercise', 'Legs', 'Calves');

-- Insert workout templates
INSERT INTO workout_template (id, name, description, notes) VALUES
  ('app-01HQER8K3QPUSHDA0T6DQ6KM4F',  'Push Day', 'Chest, Shoulders, and Triceps workout', 'Focus on progressive overload'),
  ('app-01HQER8K3QPULLDB1V7ER7MN5G',  'Pull Day', 'Back and Biceps workout', 'Maintain strict form on all pulling movements'),
  ('app-01HQER8K3QLEGSDC2W8FS8NP6H',  'Leg Day', 'Complete lower body workout', 'Don''t skip leg day!');

-- Link exercises to Push Day template
INSERT INTO exercise_for_workout_template
  (id,                              workoutTemplateId,              exerciseId,                       ordering, exerciseIndex, notes) VALUES
  ('app-01HQER8K3RPUSH1D3X9GT9PQ7J', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3RPUSH2E4Y0HV0QR8K', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 2,        0,             'Upper chest focus'),
  ('app-01HQER8K3RPUSH3F5Z1JW1RS9M', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 3,        0,             'Main shoulder movement'),
  ('app-01HQER8K3RPUSH4G602KX2STAN', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 4,        0,             'Side delts'),
  ('app-01HQER8K3RPUSH5H713MY3TVBP', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 5,        0,             'Tricep finisher'),
  ('app-01HQER8K3RPUSH6J824NZ4VWCQ', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 6,        0,             'Optional if energy remains');

-- Link exercises to Pull Day template
INSERT INTO exercise_for_workout_template
  (id,                              workoutTemplateId,              exerciseId,                       ordering, exerciseIndex, notes) VALUES
  ('app-01HQER8K3SPULL1K935P05XWDR', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3SPULL2MA46Q16YXES', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 2,        0,             'Bodyweight or weighted'),
  ('app-01HQER8K3SPULL3NB57R27ZYFT', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 3,        0,             'Heavy rows'),
  ('app-01HQER8K3SPULL4PC68S380ZGV', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NLATPDK0G13DWA0T5', 4,        0,             'Back width'),
  ('app-01HQER8K3SPULL5QD79T491AHW', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 5,        0,             'Rear delt health'),
  ('app-01HQER8K3SPULL6RE80V5A2BJX', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 6,        0,             'Bicep volume'),
  ('app-01HQER8K3SPULL7SF91W6B3CKY', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NHMCRLP3KZ6GZDCX8', 7,        0,             'Brachialis focus');

-- Link exercises to Leg Day template
INSERT INTO exercise_for_workout_template
  (id,                              workoutTemplateId,              exerciseId,                       ordering, exerciseIndex, notes) VALUES
  ('app-01HQER8K3TLEGS1TGA0X7C4DMZ', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3TLEGS2VHB1Y8D5EN0', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 2,        0,             'Hamstring focus'),
  ('app-01HQER8K3TLEGS3WJC2Z9E6FP1', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 3,        0,             'Quad volume'),
  ('app-01HQER8K3TLEGS4XKD30AF7GQ2', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGCRLT7Q3AM3HG1C', 4,        0,             'Hamstring isolation'),
  ('app-01HQER8K3TLEGS5YME41BG8HR3', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGEXTV8R4BN4JH2D', 5,        0,             'Quad isolation'),
  ('app-01HQER8K3TLEGS6ZNF52CH9JS4', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 6,        0,             'Don''t forget calves');

-- Add set templates for Push Day exercises
-- Barbell Bench Press
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PA', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 8,        135,    'lbs', 1,        'warmup',     120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PB', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 12,       185,    'lbs', 2,        'regularSet', 180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PC', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 10,       205,    'lbs', 3,        'regularSet', 180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PD', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 8,        225,    'lbs', 4,        'regularSet', 180);

-- Incline Dumbbell Press
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PE', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 12,       60,     'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PF', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 10,       70,     'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PG', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 8,        75,     'lbs', 3,        'regularSet', 120);

-- Overhead Press
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PH', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 10,       95,     'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PJ', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 8,        115,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PK', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 6,        125,    'lbs', 3,        'regularSet', 150);

-- Lateral Raises
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PM', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PN', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PP', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 3,        'regularSet', 90);

-- Tricep Pushdowns
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PQ', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 12,       70,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PR', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 12,       80,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PS', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 10,       90,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Pull Day exercises
-- Deadlift
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PT', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 8,        135,    'lbs', 1,        'warmup',     180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PV', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        225,    'lbs', 2,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PW', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        275,    'lbs', 3,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PX', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        315,    'lbs', 4,        'regularSet', 240);

-- Pull-ups
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PY', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 10,       0,      'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PZ', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 8,        0,      'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q0', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 6,        0,      'lbs', 3,        'regularSet', 120);

-- Barbell Rows
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q1', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q2', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 8,        155,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q3', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 8,        165,    'lbs', 3,        'regularSet', 150);

-- Barbell Curls
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q4', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 12,       65,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q5', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 10,       75,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q6', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 8,        85,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Leg Day exercises
-- Barbell Squat
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q7', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 10,       135,    'lbs', 1,        'warmup',     180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q8', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 8,        185,    'lbs', 2,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q9', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 8,        225,    'lbs', 3,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QA', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 6,        245,    'lbs', 4,        'regularSet', 240);

-- Romanian Deadlift
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QB', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QC', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 10,       155,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QD', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 8,        175,    'lbs', 3,        'regularSet', 150);

-- Leg Press
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QE', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 12,       270,    'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QF', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 12,       315,    'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QG', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 10,       360,    'lbs', 3,        'regularSet', 120);

-- Calf Raises
INSERT INTO exercise_set_template
  (id,                               exerciseId,                       exerciseForWorkoutTemplateId,  repCount, weight, unit,  ordering, setType,      restTime) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QH', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 1,        'regularSet', 60),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QJ', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 2,        'regularSet', 60),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QK', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 3,        'regularSet', 60);
