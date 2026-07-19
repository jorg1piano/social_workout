-- Fixtures for the plan-vs-record model stress tests.
-- A minimal but complete graph exercising supersets and swapped variants.
--
-- Plan side (Leg Day template TPL1):
--   Block 1 = superset:
--     within 1: Leg Extension (idx0, V_A0) / Sissy Squat swap (idx1, V_A1)
--     within 2: Lying Leg Curl (idx0, V_B0) / Seated Leg Curl swap (idx1, V_B1)
--   Block 2 = Squat (idx0, V_C0)
--
-- Record side:
--   W1 = a logged session that PICKED the swaps (Sissy + Seated) and ran the
--        superset for 3 rounds, plus Squat for 3 straight sets.
--   W2 = a sibling session that logged Squat only (2 sets). Used to prove
--        deletes/cascades don't touch siblings, and that per-exercise stats
--        aggregate Squat across W1 and W2.

-- Exercises -----------------------------------------------------------------
INSERT INTO exercise (id, name) VALUES
('app-01KXVSX4FC4PYWAEW1W5WDE34C', 'Leg Extension'),
('app-01KXVSX4FGT864AWYABVGBDZXW', 'Lying Leg Curl'),
('app-01KXVSX4FK94F831GHT4GNC0EA', 'Squat'),
('app-01KXVSX4FPTFF9BC8R1YJP31ET', 'Sissy Squat'),
('app-01KXVSX4FS0CE8Y3X0Q4CF0C0R', 'Seated Leg Curl'),
('app-01KXVSX4FWDHY4RNBASD6Z4DJW', 'Bench Press');

-- Plan: template ------------------------------------------------------------
INSERT INTO workout_template (id, name, description) VALUES
('app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'Leg Day', 'Superset legs');

-- Plan: variants (exercise_for_workout_template) ----------------------------
INSERT INTO exercise_for_workout_template
  (id, workout_template_id, exercise_id, block_ordering, within_block_ordering, exercise_index) VALUES
('app-01KXVSX4G2SSFVMFGHS3XQV6HT', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'app-01KXVSX4FC4PYWAEW1W5WDE34C', 1, 1, 0),
('app-01KXVSX4G61WMXE8DKPF88M554', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'app-01KXVSX4FPTFF9BC8R1YJP31ET', 1, 1, 1),
('app-01KXVSX4G84N39STFCE1A904MQ', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'app-01KXVSX4FGT864AWYABVGBDZXW', 1, 2, 0),
('app-01KXVSX4GBN4T6BM1A2GMEA64C', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'app-01KXVSX4FS0CE8Y3X0Q4CF0C0R', 1, 2, 1),
('app-01KXVSX4GEAPJXTFX8YND3P83E', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 'app-01KXVSX4FK94F831GHT4GNC0EA', 2, 1, 0);

-- Record: workouts ----------------------------------------------------------
INSERT INTO workout (id, template_id, start_time, stop_time) VALUES
('app-01KXVSX4GHKB907MKT4CGTPEV2', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 1000, 4000),
('app-01KXVSX4GMBN197D2J0WS2590E', 'app-01KXVSX4FZFNQ1K5F1WEXGYGPG', 5000, 8000);

-- Record: workout_exercise --------------------------------------------------
-- W1 picked the swaps: Sissy (b1,w1) + Seated (b1,w2), plus Squat (b2,w1).
INSERT INTO workout_exercise
  (id, workout_id, exercise_id, block_ordering, within_block_ordering, source_variant_id) VALUES
('app-01KXVSX4GQEJY0NAY4JF69ZWSB', 'app-01KXVSX4GHKB907MKT4CGTPEV2', 'app-01KXVSX4FPTFF9BC8R1YJP31ET', 1, 1, 'app-01KXVSX4G61WMXE8DKPF88M554'),
('app-01KXVSX4GSNP6HMJGFZBPCN3AG', 'app-01KXVSX4GHKB907MKT4CGTPEV2', 'app-01KXVSX4FS0CE8Y3X0Q4CF0C0R', 1, 2, 'app-01KXVSX4GBN4T6BM1A2GMEA64C'),
('app-01KXVSX4GW02F6ZSQ01999A298', 'app-01KXVSX4GHKB907MKT4CGTPEV2', 'app-01KXVSX4FK94F831GHT4GNC0EA', 2, 1, 'app-01KXVSX4GEAPJXTFX8YND3P83E'),
-- W2 logged Squat only.
('app-01KXVSX4GZGR76CFGD0T15WWGQ', 'app-01KXVSX4GMBN197D2J0WS2590E', 'app-01KXVSX4FK94F831GHT4GNC0EA', 1, 1, 'app-01KXVSX4GEAPJXTFX8YND3P83E');

-- Record: exercise_set ------------------------------------------------------
-- WE1 (Sissy) 3 rounds
INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, is_completed) VALUES
('app-01KXVSX4H2RV262VBW4RQA8KXM', 'app-01KXVSX4GQEJY0NAY4JF69ZWSB', 12, 0, 'kg', 1, 1),
('app-01KXVSX4H41P0JX8V3S6GXJJ5J', 'app-01KXVSX4GQEJY0NAY4JF69ZWSB', 10, 0, 'kg', 2, 1),
('app-01KXVSX4H76M8CXHHACR19E50R', 'app-01KXVSX4GQEJY0NAY4JF69ZWSB', 10, 0, 'kg', 3, 1);
-- WE2 (Seated) 3 rounds
INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, is_completed) VALUES
('app-01KXVSX4H94SCM0JYB75ADTBEP', 'app-01KXVSX4GSNP6HMJGFZBPCN3AG', 12, 45, 'kg', 1, 1),
('app-01KXVSX4HCJW4NH7DA0KHP2Y79', 'app-01KXVSX4GSNP6HMJGFZBPCN3AG', 11, 45, 'kg', 2, 1),
('app-01KXVSX4HF3XXBQ8W9WG49G78E', 'app-01KXVSX4GSNP6HMJGFZBPCN3AG', 10, 45, 'kg', 3, 1);
-- WE3 (Squat, W1) 3 sets
INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, is_completed) VALUES
('app-01KXVSX4HH0P0NYPVXRQPNJ2R3', 'app-01KXVSX4GW02F6ZSQ01999A298', 8, 100, 'kg', 1, 1),
('app-01KXVSX4HMQQC9CTVJM7STGDM0', 'app-01KXVSX4GW02F6ZSQ01999A298', 8, 100, 'kg', 2, 1),
('app-01KXVSX4HQ91062DY3JHJQV43N', 'app-01KXVSX4GW02F6ZSQ01999A298', 6, 105, 'kg', 3, 1);
-- WE4 (Squat, W2) 2 sets
INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, is_completed) VALUES
('app-01KXVSX4HS8SVPDWCAB8HHPWG1', 'app-01KXVSX4GZGR76CFGD0T15WWGQ', 5, 110, 'kg', 1, 1),
('app-01KXVSX4HWZCA120W2ZX2TDRN7', 'app-01KXVSX4GZGR76CFGD0T15WWGQ', 5, 110, 'kg', 2, 1);
