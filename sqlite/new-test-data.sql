-- New test data for workout tracking application
-- Creates Push/Pull/Legs workout templates with exercise variants
-- Includes actual workout sessions with completed sets
-- Generated with valid ULID IDs

-- Step 1: Create workout templates
INSERT INTO workout_template (id, name, description, notes) VALUES
('app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'Push Day', 'Chest, Shoulders, and Triceps workout', 'Focus on progressive overload on compounds'),
('app-01KE6BHGJFXP86HZR1XJBZHQS4', 'Pull Day', 'Back and Biceps workout', 'Maintain proper form on all pulling movements'),
('app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'Leg Day', 'Complete lower body workout', 'Squat deep, focus on full range of motion');

-- Step 2: Link exercises to Push Day template with variants
-- Exercise 1: Bench Press (with Incline variant)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGJQWAR3VA76ZZF5CSJG', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'Main compound - flat bench', 1, 0),
('app-01KE6BHGJWGFJFPW17WMVRVWE5', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649RTDT6F8FK63GNSJGNVQ', 'Variant - incline for upper chest', 1, 1);

-- Exercise 2: Overhead Press
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGK0KF9CCWHXDNQDCEPN', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'Main shoulder press', 2, 0);

-- Exercise 3: Lateral Raise
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGK45F06MDBZ7RV9F9DT', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649RWJPQJ2E9QWZP7DVC0H', 'Side delts isolation', 3, 0);

-- Exercise 4: Triceps (Pushdown vs Dips)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGK8PHYAEMQAS05PNKJA', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649SA771M1GMGD0NV11SEC', 'Cable pushdown', 4, 0),
('app-01KE6BHGKCYBNCM046HSHJR9JA', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 'app-01KE649S9APQSR4XCJP6EBAZYN', 'Variant - bodyweight dips', 4, 1);

-- Step 3: Link exercises to Pull Day template
-- Exercise 1: Deadlift
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGKG285PXVJB83VV8MDR', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649R9AJJEY97C4SQMPGK0P', 'Main compound - conventional deadlift', 1, 0);

-- Exercise 2: Pull Ups
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGKMBJVPEFP8Q7Y8RKFC', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649S0K5B5Z08APDGVKJEA3', 'Bodyweight or weighted', 2, 0);

-- Exercise 3: Bent Over Row (vs Lat Pulldown)
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGKQPHGCDYBESW4D0JWZ', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649R3SGW1J64BZ3JQ1ADDY', 'Heavy barbell rows', 3, 0),
('app-01KE6BHGKVRNSYXA6A5X4W8XGQ', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649RWVB6FB8E3Z2RMBGXPJ', 'Variant - lat pulldown', 3, 1);

-- Exercise 4: Bicep Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGKZQZWXFT383AWPW061', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649R4BVKJ25QRJMDTPJ23F', 'Barbell curls', 4, 0);

-- Exercise 5: Hammer Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGM35H2N66ETNS7GEXBS', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 'app-01KE649RRFBV8CJ4DFTMZ5TTKH', 'Brachialis focus', 5, 0);

-- Step 4: Link exercises to Leg Day template
-- Exercise 1: Squat
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGM74EZENC8XT1JEG60X', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649S6V1B1B5CBZAAFF2XPG', 'Main compound - barbell squat', 1, 0);

-- Exercise 2: Romanian Deadlift
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGMB9QA6B9GSNKVPNXM2', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649S2FQP180BFDNG1DWJJC', 'Hamstring focus', 2, 0);

-- Exercise 3: Leg Press
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGMF984MN7WVGN7JS9H5', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649RXBXE2BP0SE9JRDWP3Q', 'Quad volume', 3, 0);

-- Exercise 4: Leg Extension
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGMKY14NQQ0WXK4JA70H', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649RX8CSNX00Z0YBY7B3HE', 'Quad isolation', 4, 0);

-- Exercise 5: Lying Leg Curl
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGMPHH8MCXRA29JW2KH2', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649RXQFR6VPGJ7WTFSPGX3', 'Hamstring isolation', 5, 0);

-- Exercise 6: Standing Calf Raise
INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, notes, ordering, exercise_index) VALUES
('app-01KE6BHGMT5F11T4X73NYMZHSY', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 'app-01KE649S7BB142PVQVKB0865YW', 'Calf work', 6, 0);

-- Step 5: Create exercise set templates for Push Day
-- Bench Press - 4 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KE6BHGNBK29RCXMMX8997YNX', 10, 135, NULL, 3, 7, 'lbs', 1, 'warmup', 120, 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG'),
('app-01KE6BHGNFFJ14NHW2SNH2AFWS', 8, 185, NULL, 2, 8, 'lbs', 2, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG'),
('app-01KE6BHGNKMF89QJVWB3XR8DZX', 6, 205, NULL, 1, 9, 'lbs', 3, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG'),
('app-01KE6BHGNQ1J1SS5C7CR6X9VMQ', 6, 205, NULL, 1, 9, 'lbs', 4, 'regularSet', 180, 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG');

-- Incline Bench Press variant - 3 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KE6BHGNVG45TS3KRDW5D39GZ', 10, 95, NULL, 3, 7, 'lbs', 1, 'warmup', 120, 'app-01KE649RTDT6F8FK63GNSJGNVQ', 'app-01KE6BHGJWGFJFPW17WMVRVWE5'),
('app-01KE6BHGNZHSJG7XEMS4V1VCJW', 8, 135, NULL, 2, 8, 'lbs', 2, 'regularSet', 180, 'app-01KE649RTDT6F8FK63GNSJGNVQ', 'app-01KE6BHGJWGFJFPW17WMVRVWE5'),
('app-01KE6BHGP3GDTY5QEMZR5Y0GR7', 8, 155, NULL, 1, 9, 'lbs', 3, 'regularSet', 180, 'app-01KE649RTDT6F8FK63GNSJGNVQ', 'app-01KE6BHGJWGFJFPW17WMVRVWE5');

-- Overhead Press - 3 sets
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KE6BHGP76FTCHQ0R7KVBPYZ0', 10, 95, NULL, 2, 7, 'lbs', 1, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN'),
('app-01KE6BHGPB7PW1KHKJ85SMDEXG', 8, 115, NULL, 1, 8, 'lbs', 2, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN'),
('app-01KE6BHGPEZ9J754M893MXZM7V', 6, 125, NULL, 0, 9, 'lbs', 3, 'regularSet', 150, 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN');

-- Lateral Raise - 3 sets (isolation, light weight, high reps)
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KNXWCBYC9NPF5KF5Y2CC7DJ3', 12, 8, NULL, 2, 8, 'kg', 1, 'regularSet', 90, 'app-01KE649RWJPQJ2E9QWZP7DVC0H', 'app-01KE6BHGK45F06MDBZ7RV9F9DT'),
('app-01KNXWCBYG5DFACE08HQS8S6KH', 12, 8, NULL, 1, 8, 'kg', 2, 'regularSet', 90, 'app-01KE649RWJPQJ2E9QWZP7DVC0H', 'app-01KE6BHGK45F06MDBZ7RV9F9DT'),
('app-01KNXWCBYK49RE1RXMWDCJW00Z', 12, 8, NULL, 1, 9, 'kg', 3, 'regularSet', 90, 'app-01KE649RWJPQJ2E9QWZP7DVC0H', 'app-01KE6BHGK45F06MDBZ7RV9F9DT');

-- Triceps Pushdown - 4 sets (1 warmup + 3 working)
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KNXWCBYN6B9VXX0VGS45P3PY', 12, 15, NULL, 3, 7, 'kg', 1, 'warmup', 60, 'app-01KE649SA771M1GMGD0NV11SEC', 'app-01KE6BHGK8PHYAEMQAS05PNKJA'),
('app-01KNXWCBYR1T7RDTJ9643YM1QB', 10, 25, NULL, 2, 8, 'kg', 2, 'regularSet', 90, 'app-01KE649SA771M1GMGD0NV11SEC', 'app-01KE6BHGK8PHYAEMQAS05PNKJA'),
('app-01KNXWCBYTP2M5KN0WXAKNECS2', 10, 25, NULL, 1, 8, 'kg', 3, 'regularSet', 90, 'app-01KE649SA771M1GMGD0NV11SEC', 'app-01KE6BHGK8PHYAEMQAS05PNKJA'),
('app-01KNXWCBYXKHGYE419S840WCSP', 10, 25, NULL, 1, 9, 'kg', 4, 'regularSet', 90, 'app-01KE649SA771M1GMGD0NV11SEC', 'app-01KE6BHGK8PHYAEMQAS05PNKJA');

-- Triceps Dip variant - 4 sets (1 warmup + 3 working, bodyweight)
INSERT INTO exercise_set_template (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id) VALUES
('app-01KNXWCBYZEVVV3Q96N4CZN49M', 8, 0, NULL, 3, 7, 'kg', 1, 'warmup', 60, 'app-01KE649S9APQSR4XCJP6EBAZYN', 'app-01KE6BHGKCYBNCM046HSHJR9JA'),
('app-01KNXWCBZ12A9S6NJJ22EC0ARJ', 8, 0, NULL, 2, 8, 'kg', 2, 'regularSet', 90, 'app-01KE649S9APQSR4XCJP6EBAZYN', 'app-01KE6BHGKCYBNCM046HSHJR9JA'),
('app-01KNXWCBZ4WY4M9SJJSFR5DS6S', 8, 0, NULL, 1, 8, 'kg', 3, 'regularSet', 90, 'app-01KE649S9APQSR4XCJP6EBAZYN', 'app-01KE6BHGKCYBNCM046HSHJR9JA'),
('app-01KNXWCBZ674YMHFAQGJS5CEMM', 8, 0, NULL, 1, 9, 'kg', 4, 'regularSet', 90, 'app-01KE649S9APQSR4XCJP6EBAZYN', 'app-01KE6BHGKCYBNCM046HSHJR9JA');

-- Step 6: Create actual workout sessions
-- Workout 1: Push Day (completed 3 days ago) - used flat bench press variant
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', strftime('%s', 'now', '-3 days', '+10 hours'), strftime('%s', 'now', '-3 days', '+11 hours', '+15 minutes'));

-- Workout 2: Pull Day (completed 2 days ago)
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('app-01KE6BHGN1G3AS2HXRNC3FTF5K', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', strftime('%s', 'now', '-2 days', '+10 hours'), strftime('%s', 'now', '-2 days', '+11 hours', '+30 minutes'));

-- Workout 3: Leg Day (completed 1 day ago)
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('app-01KE6BHGN4YT8HXPS69FARA9Z2', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', strftime('%s', 'now', '-1 day', '+10 hours'), strftime('%s', 'now', '-1 day', '+11 hours', '+45 minutes'));

-- Workout 4: Push Day (in progress - started today) - using incline bench variant
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('app-01KE6BHGN8KZT7FNXFQM9ZAQJY', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', strftime('%s', 'now', '-30 minutes'), NULL);

-- Step 7: Create exercise sets for Workout 1 (Push Day - completed)
-- Bench Press - 4 sets (used exercise_index 0 - flat bench)
-- Set 1 is explicitly set_type='warmup' to match the template's warmup row;
-- the rest fall through to the 'regularSet' default.
INSERT INTO exercise_set (id, rep_count, weight, duration, rir, rpe, unit, ordering, set_type, notes, rest_time, workout_id, exercise_id, exercise_for_workout_template_id, is_completed) VALUES
('app-01KE6BHH1NT682RRXXBGBFSCYK', 10, 135, NULL, 3, 7, 'lbs', 1, 'warmup',     'Warmup felt good', 120, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG', 1),
('app-01KE6BHH1S0AGSSC46M25YKRH9',  8, 185, NULL, 2, 8, 'lbs', 2, 'regularSet', NULL,                180, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG', 1),
('app-01KE6BHH1WNV37CJ432PJPXHCS',  7, 205, NULL, 1, 9, 'lbs', 3, 'regularSet', 'One less rep than planned', 180, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG', 1),
('app-01KE6BHH20ZGW9GQ88VGEX3P3J',  6, 205, NULL, 1, 9, 'lbs', 4, 'regularSet', NULL,                180, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649R3DHD6HFEM69RKAA5BE', 'app-01KE6BHGJQWAR3VA76ZZF5CSJG', 1);

-- Overhead Press - 3 sets
INSERT INTO exercise_set (id, rep_count, weight, duration, rir, rpe, unit, ordering, notes, rest_time, workout_id, exercise_id, exercise_for_workout_template_id, is_completed) VALUES
('app-01KE6BHH24YY28KAVJQHG5GX8G', 10, 95, NULL, 2, 7, 'lbs', 1, NULL, 150, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN', 1),
('app-01KE6BHH27WB0RQ4BRN014ZH7B', 8, 115, NULL, 1, 8, 'lbs', 2, NULL, 150, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN', 1),
('app-01KE6BHH2BCRBT3SA26JMYGS7R', 6, 125, NULL, 0, 9, 'lbs', 3, 'Last rep was tough', 150, 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', 'app-01KE649RYS8PJ2SP1BEPEEE4T9', 'app-01KE6BHGK0KF9CCWHXDNQDCEPN', 1);

-- Step 8: Body measurements — 30 daily weight entries trending 85.2 → 81.8 kg
-- over 90 days, plus circumference snapshots every ~30 days.
INSERT INTO body_measurement (id, measurement_type, value, unit, measured_at, notes) VALUES
('app-01KP0RQR0DT69BH7TPH4Q8PC4S', 'weight', 85.2, 'kg', strftime('%s', 'now', '-90 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR0KBYKBRWQM7CSJA4MR', 'weight', 85.0, 'kg', strftime('%s', 'now', '-87 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR0R0P9B7V1MRH11ARBF', 'weight', 84.8, 'kg', strftime('%s', 'now', '-84 days', '+7 hours'), NULL),
('app-01KP0RQR0V3SJDHT9SJQWG7F0T', 'weight', 85.1, 'kg', strftime('%s', 'now', '-81 days', '+7 hours'), 'Post cheat day'),
('app-01KP0RQR11G4P7CBJGRE6RWP1P', 'weight', 84.6, 'kg', strftime('%s', 'now', '-78 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR17G15JE2BY37202BHK', 'weight', 84.3, 'kg', strftime('%s', 'now', '-75 days', '+7 hours'), NULL),
('app-01KP0RQR1QD4TXS2N3AD3VXWH7', 'weight', 84.5, 'kg', strftime('%s', 'now', '-72 days', '+7 hours'), NULL),
('app-01KP0RQR1YK7T2JDFJR5MSQD9G', 'weight', 84.1, 'kg', strftime('%s', 'now', '-69 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR2A7Q66BBG1JQC9SEXP', 'weight', 83.9, 'kg', strftime('%s', 'now', '-66 days', '+7 hours'), NULL),
('app-01KP0RQR2EWDW2VXCDAZ7K74D9', 'weight', 84.2, 'kg', strftime('%s', 'now', '-63 days', '+7 hours'), 'Birthday weekend'),
('app-01KP0RQR2H176W31EWG0RZBYG1', 'weight', 83.8, 'kg', strftime('%s', 'now', '-60 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR2MJEVR7CD0B9B0XG89', 'weight', 83.5, 'kg', strftime('%s', 'now', '-57 days', '+7 hours'), NULL),
('app-01KP0RQR2RMHWADC09ZMBNE769', 'weight', 83.7, 'kg', strftime('%s', 'now', '-54 days', '+7 hours'), NULL),
('app-01KP0RQR2V5Y1EKF1G60PTNAMS', 'weight', 83.3, 'kg', strftime('%s', 'now', '-51 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR2YW2S0NS2JSNMWKTTA', 'weight', 83.1, 'kg', strftime('%s', 'now', '-48 days', '+7 hours'), NULL),
('app-01KP0RQR337D1GKQWXDMENF4AD', 'weight', 83.4, 'kg', strftime('%s', 'now', '-45 days', '+7 hours'), 'Water retention'),
('app-01KP0RQR37GB9MWEK0PGXJHWWP', 'weight', 83.0, 'kg', strftime('%s', 'now', '-42 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR3AG72WG5MYPZ8ZYZ4J', 'weight', 82.8, 'kg', strftime('%s', 'now', '-39 days', '+7 hours'), NULL),
('app-01KP0RQR3EGJA39W6K5FPCY447', 'weight', 83.0, 'kg', strftime('%s', 'now', '-36 days', '+7 hours'), NULL),
('app-01KP0RQR3GCVHV369HFY4XTR99', 'weight', 82.6, 'kg', strftime('%s', 'now', '-33 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR3KGB45Q1MR2C580Q66', 'weight', 82.4, 'kg', strftime('%s', 'now', '-30 days', '+7 hours'), NULL),
('app-01KP0RQR3PGM82PZDD042FHBWE', 'weight', 82.7, 'kg', strftime('%s', 'now', '-27 days', '+7 hours'), 'Creatine loading'),
('app-01KP0RQR3RZ2KC8R091096JXGC', 'weight', 82.3, 'kg', strftime('%s', 'now', '-24 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR3T9HVJ8N7M29G6E7V3', 'weight', 82.1, 'kg', strftime('%s', 'now', '-21 days', '+7 hours'), NULL),
('app-01KP0RQR3XJY2W20NAVGKD3Z51', 'weight', 82.5, 'kg', strftime('%s', 'now', '-18 days', '+7 hours'), 'Post vacation'),
('app-01KP0RQR3ZB038SJCWG3TR75WN', 'weight', 82.2, 'kg', strftime('%s', 'now', '-15 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR41JX0GK5K54VQRADE9', 'weight', 81.9, 'kg', strftime('%s', 'now', '-12 days', '+7 hours'), NULL),
('app-01KP0RQR44ARHGZ9K9FHGK2K3J', 'weight', 82.1, 'kg', strftime('%s', 'now', '-9 days', '+7 hours'), NULL),
('app-01KP0RQR473HXZBJ9M51R4EFMN', 'weight', 81.7, 'kg', strftime('%s', 'now', '-6 days', '+7 hours'), 'Morning fasted'),
('app-01KP0RQR49J5KZVJPK7TJA99ZN', 'weight', 81.8, 'kg', strftime('%s', 'now', '-3 days', '+7 hours'), NULL),
('app-01KP0RQR4B7WCPSZ7MT2ZA2X68', 'weight', 81.5, 'kg', strftime('%s', 'now', '+7 hours'), 'Morning fasted');

-- Circumference snapshots every ~30 days
INSERT INTO body_measurement (id, measurement_type, value, unit, measured_at, notes) VALUES
('app-01KP0Q4RKD8T2X6A8PXGWJP1F9', 'body_fat_pct', 16.1, '%', strftime('%s', 'now', '-90 days', '+7 hours'), 'Caliper measurement'),
('app-01KP0Q4RKGNMAGQ6B1KCWT71AG', 'chest', 101.0, 'cm', strftime('%s', 'now', '-90 days', '+7 hours'), NULL),
('app-01KP0Q4RKMY1BNCX6MDGF6NAT0', 'waist', 86.0, 'cm', strftime('%s', 'now', '-90 days', '+7 hours'), NULL),
('app-01KP0Q4RKT570V65H5M5RJGX93', 'bicep_left', 35.5, 'cm', strftime('%s', 'now', '-90 days', '+7 hours'), 'Flexed'),
('app-01KP0Q4RKX1545ZP7K3HPMQAZV', 'bicep_right', 36.0, 'cm', strftime('%s', 'now', '-90 days', '+7 hours'), 'Flexed'),
('app-01KP0Q4RKQ7DBBFEEZQDCTBX4P', 'thigh_left', 57.0, 'cm', strftime('%s', 'now', '-90 days', '+7 hours'), NULL);

INSERT INTO body_measurement (id, measurement_type, value, unit, measured_at, notes) VALUES
('app-01KP0RQR4EFFA4Q4H2WJHEMVWN', 'body_fat_pct', 15.5, '%', strftime('%s', 'now', '-60 days', '+7 hours'), 'Caliper measurement'),
('app-01KP0RQR4GHGDRYZH7C9GPD47F', 'chest', 101.5, 'cm', strftime('%s', 'now', '-60 days', '+7 hours'), NULL),
('app-01KP0RQR4J1RNXKBC3MHACDESM', 'waist', 85.0, 'cm', strftime('%s', 'now', '-60 days', '+7 hours'), NULL),
('app-01KP0RQR4N3F1RS8NS4T3G53XF', 'bicep_left', 36.0, 'cm', strftime('%s', 'now', '-60 days', '+7 hours'), 'Flexed');

INSERT INTO body_measurement (id, measurement_type, value, unit, measured_at, notes) VALUES
('app-01KP0Q4RM026SRH6J6NMS7EMAT', 'body_fat_pct', 14.9, '%', strftime('%s', 'now', '-30 days', '+7 hours'), 'Caliper measurement'),
('app-01KP0Q4RM37AS9WTV1D7Z3ZYGG', 'chest', 102.0, 'cm', strftime('%s', 'now', '-30 days', '+7 hours'), NULL),
('app-01KP0Q4RM7NDAJTEA76RHT9ZTT', 'waist', 84.5, 'cm', strftime('%s', 'now', '-30 days', '+7 hours'), NULL),
('app-01KP0Q4RKAMZV26CVMDCNHC7QN', 'bicep_left', 36.5, 'cm', strftime('%s', 'now', '-30 days', '+7 hours'), 'Flexed'),
('app-01KP0RQSZZ7N8BT1C4WP2GXJEK', 'bicep_right', 37.0, 'cm', strftime('%s', 'now', '-30 days', '+7 hours'), 'Flexed'),
('app-01KP0RQSZWMHV5J3NMCG00QMRH', 'thigh_left', 58.0, 'cm', strftime('%s', 'now', '-30 days', '+7 hours'), NULL);

