-- Test data for workout tracking application
-- Push/Pull/Legs workout templates with exercises
-- Uses ULID format: app-{26 character ULID}

-- Insert body part categories
INSERT INTO body_part_category (id, name) VALUES
  ('app-01KE63Q7E6NWGZC22TDDP27WFA', 'Chest'),
  ('app-01KE63Q7EAVF5RCJQX24B225TB', 'Shoulders'),
  ('app-01KE63Q7ED485MF41ZRMFVCYFM', 'Arms'),
  ('app-01KE63Q7EGQT6ZE4E85PMW72Q3', 'Back'),
  ('app-01KE63Q7EKYD39HYER59DC0JRG', 'Legs');

-- Insert equipment categories
INSERT INTO equipment_category (id, name) VALUES
  ('app-01KE63Q7EQR14RKKKRGH6T9G3H', 'Barbell'),
  ('app-01KE63Q7ETA0EY41H0DY2M5HZP', 'Dumbbell'),
  ('app-01KE63Q7EXR7RX9TW2DJT6JVNT', 'Cable'),
  ('app-01KE63Q7F09QHJHMW3D3BNKWDA', 'Machine'),
  ('app-01KE63Q7F32A07JQGYS1ADR58T', 'Bodyweight'),
  ('app-01KE63Q7F75TSV7C0RPSR75CAT', 'Strength');

-- Insert exercises
INSERT INTO exercise (id, name, description) VALUES
  -- Push exercises
  ('app-01HQER8K3MBENCHA9X7TY2GQ4W',  'Barbell Bench Press', 'Compound chest exercise'),
  ('app-01HQER8K3MINCLNBH6VPW5RN8X',  'Incline Dumbbell Press', 'Upper chest focus'),
  ('app-01HQER8K3MOVRPRCJ8ZSXM4KTY',  'Overhead Press', 'Compound shoulder exercise'),
  ('app-01HQER8K3MLATERD9WN2FQ7HPZ',  'Lateral Raises', 'Isolation shoulder exercise'),
  ('app-01HQER8K3MTRICPEY3BG8VK5J0',  'Tricep Pushdowns', 'Isolation tricep exercise'),
  ('app-01HQER8K3MDIPSXF4PC9HR6WN1',  'Dips', 'Compound chest and tricep exercise'),

  -- Pull exercises
  ('app-01HQER8K3NDEADLG5QD0AS7XP2',  'Deadlift', 'Compound back exercise'),
  ('app-01HQER8K3NPLLUPHR8E1BT8YR3',  'Pull-ups', 'Compound back exercise'),
  ('app-01HQER8K3NBBROWJ9FZ2CV9ZS4',  'Barbell Rows', 'Compound back exercise'),
  ('app-01HQER8K3NLATPDK0G13DWA0T5',  'Lat Pulldowns', 'Isolation back exercise'),
  ('app-01HQER8K3NFACEPM1HX4EXBAV6',  'Face Pulls', 'Rear delt and upper back'),
  ('app-01HQER8K3NBBCRLN2JY5FYCBW7',  'Barbell Curls', 'Isolation bicep exercise'),
  ('app-01HQER8K3NHMCRLP3KZ6GZDCX8',  'Hammer Curls', 'Isolation bicep exercise'),

  -- Leg exercises
  ('app-01HQER8K3PSQUATQ4M07H0EDY9',  'Barbell Squat', 'Compound leg exercise'),
  ('app-01HQER8K3PRMDLFR5N18J1FEZA',  'Romanian Deadlift', 'Hamstring focus'),
  ('app-01HQER8K3PLGPRSS6P29K2GF0B',  'Leg Press', 'Compound leg exercise'),
  ('app-01HQER8K3PLGCRLT7Q3AM3HG1C',  'Leg Curls', 'Isolation hamstring exercise'),
  ('app-01HQER8K3PLGEXTV8R4BN4JH2D',  'Leg Extensions', 'Isolation quad exercise'),
  ('app-01HQER8K3PCALFSW9S5CP5KJ3E',  'Calf Raises', 'Isolation calf exercise');

-- Link exercises to body parts
INSERT INTO exercise_body_part (id, exercise_id, body_part_category_id) VALUES
  -- Push exercises
  ('app-01KE63Q7FBFH99C9X3P600YSMG', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01KE63Q7E6NWGZC22TDDP27WFA'),
  ('app-01KE63Q7FE5K2T2F95XE0A1937', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01KE63Q7E6NWGZC22TDDP27WFA'),
  ('app-01KE63Q7FJ65K5FVFR5K5CZM1T', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01KE63Q7EAVF5RCJQX24B225TB'),
  ('app-01KE63Q7FN0Y5MCK0D33RNBPKS', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01KE63Q7EAVF5RCJQX24B225TB'),
  ('app-01KE63Q7FSCY76X450DD4N76Z9', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01KE63Q7ED485MF41ZRMFVCYFM'),
  ('app-01KE63Q7FWNH7QKG4JJY57Y5E5', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 'app-01KE63Q7E6NWGZC22TDDP27WFA'),
  ('app-01KE63Q7FZZDY62Q1K2DXHQM3R', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 'app-01KE63Q7ED485MF41ZRMFVCYFM'),

  -- Pull exercises
  ('app-01KE63Q7G2GCQ74D8QJAPXGC75', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01KE63Q7EGQT6ZE4E85PMW72Q3'),
  ('app-01KE63Q7G5DV35SN2PJTCK28Q5', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7G81XJ1A7B88WB1RWVQ', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01KE63Q7EGQT6ZE4E85PMW72Q3'),
  ('app-01KE63Q7GCM6J3XZZ0QPPGEWX8', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01KE63Q7EGQT6ZE4E85PMW72Q3'),
  ('app-01KE63Q7GFWT099W3G3YZPK28Q', 'app-01HQER8K3NLATPDK0G13DWA0T5', 'app-01KE63Q7EGQT6ZE4E85PMW72Q3'),
  ('app-01KE63Q7GHTQE9K8JEYF6GGHPK', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 'app-01KE63Q7EGQT6ZE4E85PMW72Q3'),
  ('app-01KE63Q7GN9CJYG01VPPDT2MJR', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 'app-01KE63Q7EAVF5RCJQX24B225TB'),
  ('app-01KE63Q7GR49HB9SBK3RGC79JT', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01KE63Q7ED485MF41ZRMFVCYFM'),
  ('app-01KE63Q7GVZCX8ESFDEN3ZTXBB', 'app-01HQER8K3NHMCRLP3KZ6GZDCX8', 'app-01KE63Q7ED485MF41ZRMFVCYFM'),

  -- Leg exercises
  ('app-01KE63Q7GYBBV4PCAD3RE1GY6T', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7H1EY9WNH5C4S4RH8E3', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7H4X46C190NZJZ26ENT', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7H7SZF3RSVTEVXSFAX5', 'app-01HQER8K3PLGCRLT7Q3AM3HG1C', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7HAKR4ERD3D697NRS8X', 'app-01HQER8K3PLGEXTV8R4BN4JH2D', 'app-01KE63Q7EKYD39HYER59DC0JRG'),
  ('app-01KE63Q7HD24Z2BPJF6AGA6EN2', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01KE63Q7EKYD39HYER59DC0JRG');

-- Link exercises to equipment
INSERT INTO exercise_equipment (id, exercise_id, equipment_category_id) VALUES
  -- Push exercises
  ('app-01KE63Q7HH390PYJ4JENEY5MWH', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7HM9K9FDREX493T80XD', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7HQPCVXBVTB83Y8KCM4', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01KE63Q7ETA0EY41H0DY2M5HZP'),
  ('app-01KE63Q7HT03YH6SE7WWJMEH8Q', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7HYH84VPJQ6YB22BMPX', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7J183AJXEG846DKC2H3', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7J4P2VRPCE78912M6MD', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01KE63Q7ETA0EY41H0DY2M5HZP'),
  ('app-01KE63Q7J8C4ZTQCP9ZGEB3HGC', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7JB0JXVQ8EQ8KF1PDFD', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01KE63Q7EXR7RX9TW2DJT6JVNT'),
  ('app-01KE63Q7JE2VYNGAV7QRTHHYP4', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7JHA4R7CQDWPDC1CRBF', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 'app-01KE63Q7F32A07JQGYS1ADR58T'),
  ('app-01KE63Q7JMX3YCN09KQXTT0MEE', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),

  -- Pull exercises
  ('app-01KE63Q7JQ730C00XEVV5QWDRG', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7JV8319D58JQHG2YSD0', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7JYGPWBSN1MRTZ6RNHE', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01KE63Q7F32A07JQGYS1ADR58T'),
  ('app-01KE63Q7K2H20ERDFZ9N5AADSQ', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7K5FGEAQM1520DWHS9P', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7K82G29775139JBWQM7', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7KCE84BBAEV8G899DYC', 'app-01HQER8K3NLATPDK0G13DWA0T5', 'app-01KE63Q7EXR7RX9TW2DJT6JVNT'),
  ('app-01KE63Q7KFM1XHKYE4M085BVC8', 'app-01HQER8K3NLATPDK0G13DWA0T5', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7KMF55E3J996AS5CAVG', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 'app-01KE63Q7EXR7RX9TW2DJT6JVNT'),
  ('app-01KE63Q7KR2W4VTRBXYK83580T', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7KW1R6GCPYFW91ADZ57', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7KZS6ERZPVJ1D02ZWMC', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7M2X3A01WDNRCVYG5W8', 'app-01HQER8K3NHMCRLP3KZ6GZDCX8', 'app-01KE63Q7ETA0EY41H0DY2M5HZP'),
  ('app-01KE63Q7M5Z7QXX2K3PZA44WN6', 'app-01HQER8K3NHMCRLP3KZ6GZDCX8', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),

  -- Leg exercises
  ('app-01KE63Q7M9A5BQ8MHG0SJXX3A5', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7MCKP64D019W3GP2RZT', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7MG4EQVRXZJYW37D60Y', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01KE63Q7EQR14RKKKRGH6T9G3H'),
  ('app-01KE63Q7MKEE45DGKQ7EAX6F1H', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7MP5NM0RBP1B9QEPQE2', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01KE63Q7F09QHJHMW3D3BNKWDA'),
  ('app-01KE63Q7MS3TNP9QBBYP0KTQX4', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7MWGZNFZBDQW042HH34', 'app-01HQER8K3PLGCRLT7Q3AM3HG1C', 'app-01KE63Q7F09QHJHMW3D3BNKWDA'),
  ('app-01KE63Q7MZZE47ZK8A05A81G3K', 'app-01HQER8K3PLGCRLT7Q3AM3HG1C', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7N37A3X8NH2CWYA45NY', 'app-01HQER8K3PLGEXTV8R4BN4JH2D', 'app-01KE63Q7F09QHJHMW3D3BNKWDA'),
  ('app-01KE63Q7N6S08WXZ8Y6RRQTKQQ', 'app-01HQER8K3PLGEXTV8R4BN4JH2D', 'app-01KE63Q7F75TSV7C0RPSR75CAT'),
  ('app-01KE63Q7N9NVM110JQRWJ1ZNQQ', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01KE63Q7F09QHJHMW3D3BNKWDA'),
  ('app-01KE63Q7NCVX8VH56CWFPE9K1A', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01KE63Q7F75TSV7C0RPSR75CAT');

-- Insert workout templates
INSERT INTO workout_template (id, name, description, notes) VALUES
  ('app-01HQER8K3QPUSHDA0T6DQ6KM4F',  'Push Day', 'Chest, Shoulders, and Triceps workout', 'Focus on progressive overload'),
  ('app-01HQER8K3QPULLDB1V7ER7MN5G',  'Pull Day', 'Back and Biceps workout', 'Maintain strict form on all pulling movements'),
  ('app-01HQER8K3QLEGSDC2W8FS8NP6H',  'Leg Day', 'Complete lower body workout', 'Don''t skip leg day!');

-- Link exercises to Push Day template
INSERT INTO exercise_for_workout_template
  (id,                              workout_template_id,            exercise_id,                      ordering, exercise_index, notes) VALUES
  ('app-01HQER8K3RPUSH1D3X9GT9PQ7J', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3RPUSH2E4Y0HV0QR8K', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 2,        0,             'Upper chest focus'),
  ('app-01HQER8K3RPUSH3F5Z1JW1RS9M', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 3,        0,             'Main shoulder movement'),
  ('app-01HQER8K3RPUSH4G602KX2STAN', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 4,        0,             'Side delts'),
  ('app-01HQER8K3RPUSH5H713MY3TVBP', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 5,        0,             'Tricep finisher'),
  ('app-01HQER8K3RPUSH6J824NZ4VWCQ', 'app-01HQER8K3QPUSHDA0T6DQ6KM4F', 'app-01HQER8K3MDIPSXF4PC9HR6WN1', 6,        0,             'Optional if energy remains');

-- Link exercises to Pull Day template
INSERT INTO exercise_for_workout_template
  (id,                              workout_template_id,            exercise_id,                      ordering, exercise_index, notes) VALUES
  ('app-01HQER8K3SPULL1K935P05XWDR', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3SPULL2MA46Q16YXES', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 2,        0,             'Bodyweight or weighted'),
  ('app-01HQER8K3SPULL3NB57R27ZYFT', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 3,        0,             'Heavy rows'),
  ('app-01HQER8K3SPULL4PC68S380ZGV', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NLATPDK0G13DWA0T5', 4,        0,             'Back width'),
  ('app-01HQER8K3SPULL5QD79T491AHW', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NFACEPM1HX4EXBAV6', 5,        0,             'Rear delt health'),
  ('app-01HQER8K3SPULL6RE80V5A2BJX', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 6,        0,             'Bicep volume'),
  ('app-01HQER8K3SPULL7SF91W6B3CKY', 'app-01HQER8K3QPULLDB1V7ER7MN5G', 'app-01HQER8K3NHMCRLP3KZ6GZDCX8', 7,        0,             'Brachialis focus');

-- Link exercises to Leg Day template
INSERT INTO exercise_for_workout_template
  (id,                              workout_template_id,            exercise_id,                      ordering, exercise_index, notes) VALUES
  ('app-01HQER8K3TLEGS1TGA0X7C4DMZ', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 1,        0,             'Main compound movement'),
  ('app-01HQER8K3TLEGS2VHB1Y8D5EN0', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 2,        0,             'Hamstring focus'),
  ('app-01HQER8K3TLEGS3WJC2Z9E6FP1', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 3,        0,             'Quad volume'),
  ('app-01HQER8K3TLEGS4XKD30AF7GQ2', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGCRLT7Q3AM3HG1C', 4,        0,             'Hamstring isolation'),
  ('app-01HQER8K3TLEGS5YME41BG8HR3', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PLGEXTV8R4BN4JH2D', 5,        0,             'Quad isolation'),
  ('app-01HQER8K3TLEGS6ZNF52CH9JS4', 'app-01HQER8K3QLEGSDC2W8FS8NP6H', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 6,        0,             'Don''t forget calves');

-- Add set templates for Push Day exercises
-- Barbell Bench Press
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PA', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 8,        135,    'lbs', 1,        'warmup',     120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PB', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 12,       185,    'lbs', 2,        'regularSet', 180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PC', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 10,       205,    'lbs', 3,        'regularSet', 180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PD', 'app-01HQER8K3MBENCHA9X7TY2GQ4W', 'app-01HQER8K3RPUSH1D3X9GT9PQ7J', 8,        225,    'lbs', 4,        'regularSet', 180);

-- Incline Dumbbell Press
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PE', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 12,       60,     'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PF', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 10,       70,     'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PG', 'app-01HQER8K3MINCLNBH6VPW5RN8X', 'app-01HQER8K3RPUSH2E4Y0HV0QR8K', 8,        75,     'lbs', 3,        'regularSet', 120);

-- Overhead Press
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PH', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 10,       95,     'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PJ', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 8,        115,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PK', 'app-01HQER8K3MOVRPRCJ8ZSXM4KTY', 'app-01HQER8K3RPUSH3F5Z1JW1RS9M', 6,        125,    'lbs', 3,        'regularSet', 150);

-- Lateral Raises
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PM', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PN', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PP', 'app-01HQER8K3MLATERD9WN2FQ7HPZ', 'app-01HQER8K3RPUSH4G602KX2STAN', 15,       20,     'lbs', 3,        'regularSet', 90);

-- Tricep Pushdowns
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PQ', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 12,       70,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PR', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 12,       80,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PS', 'app-01HQER8K3MTRICPEY3BG8VK5J0', 'app-01HQER8K3RPUSH5H713MY3TVBP', 10,       90,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Pull Day exercises
-- Deadlift
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PT', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 8,        135,    'lbs', 1,        'warmup',     180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PV', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        225,    'lbs', 2,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PW', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        275,    'lbs', 3,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PX', 'app-01HQER8K3NDEADLG5QD0AS7XP2', 'app-01HQER8K3SPULL1K935P05XWDR', 5,        315,    'lbs', 4,        'regularSet', 240);

-- Pull-ups
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PY', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 10,       0,      'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4PZ', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 8,        0,      'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q0', 'app-01HQER8K3NPLLUPHR8E1BT8YR3', 'app-01HQER8K3SPULL2MA46Q16YXES', 6,        0,      'lbs', 3,        'regularSet', 120);

-- Barbell Rows
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q1', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q2', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 8,        155,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q3', 'app-01HQER8K3NBBROWJ9FZ2CV9ZS4', 'app-01HQER8K3SPULL3NB57R27ZYFT', 8,        165,    'lbs', 3,        'regularSet', 150);

-- Barbell Curls
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q4', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 12,       65,     'lbs', 1,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q5', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 10,       75,     'lbs', 2,        'regularSet', 90),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q6', 'app-01HQER8K3NBBCRLN2JY5FYCBW7', 'app-01HQER8K3SPULL6RE80V5A2BJX', 8,        85,     'lbs', 3,        'regularSet', 90);

-- Add set templates for Leg Day exercises
-- Barbell Squat
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q7', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 10,       135,    'lbs', 1,        'warmup',     180),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q8', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 8,        185,    'lbs', 2,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4Q9', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 8,        225,    'lbs', 3,        'regularSet', 240),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QA', 'app-01HQER8K3PSQUATQ4M07H0EDY9', 'app-01HQER8K3TLEGS1TGA0X7C4DMZ', 6,        245,    'lbs', 4,        'regularSet', 240);

-- Romanian Deadlift
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QB', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 10,       135,    'lbs', 1,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QC', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 10,       155,    'lbs', 2,        'regularSet', 150),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QD', 'app-01HQER8K3PRMDLFR5N18J1FEZA', 'app-01HQER8K3TLEGS2VHB1Y8D5EN0', 8,        175,    'lbs', 3,        'regularSet', 150);

-- Leg Press
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QE', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 12,       270,    'lbs', 1,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QF', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 12,       315,    'lbs', 2,        'regularSet', 120),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QG', 'app-01HQER8K3PLGPRSS6P29K2GF0B', 'app-01HQER8K3TLEGS3WJC2Z9E6FP1', 10,       360,    'lbs', 3,        'regularSet', 120);

-- Calf Raises
INSERT INTO exercise_set_template
  (id,                               exercise_id,                      exercise_for_workout_template_id,  rep_count, weight, unit,  ordering, set_type,     rest_time) VALUES
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QH', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 1,        'regularSet', 60),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QJ', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 2,        'regularSet', 60),
  ('app-01JKWMR3QZ8N5T6H9VDCX2Y4QK', 'app-01HQER8K3PCALFSW9S5CP5KJ3E', 'app-01HQER8K3TLEGS6ZNF52CH9JS4', 15,       135,    'lbs', 3,        'regularSet', 60);
