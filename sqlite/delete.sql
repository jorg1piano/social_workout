-- Drop all tables in reverse dependency order
-- Drop tables with foreign keys first, then independent tables

DROP TABLE IF EXISTS exercise_set;
DROP TABLE IF EXISTS exercise_set_template;
DROP TABLE IF EXISTS exercise_for_workout_template;
DROP TABLE IF EXISTS workout;
DROP TABLE IF EXISTS exercise_equipment;
DROP TABLE IF EXISTS exercise_body_part;
DROP TABLE IF EXISTS exercise;
DROP TABLE IF EXISTS workout_template;
DROP TABLE IF EXISTS equipment_category;
DROP TABLE IF EXISTS body_part_category;
