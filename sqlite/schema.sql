-- Database schema for workout tracking application
-- Tables are ordered to respect foreign key dependencies

-- 1. workout_template - No dependencies
CREATE TABLE workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT
);

-- 2. exercise - No dependencies
CREATE TABLE exercise (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT,
  category TEXT,
  bodyPart TEXT
);

-- 3. workout_session - Depends on: workout_template
CREATE TABLE workout (
  id INTEGER PRIMARY KEY NOT NULL,
  templateId INTEGER,
  startTime INTEGER,
  stopTime INTEGER,
  FOREIGN KEY(templateId) REFERENCES workout_template(id)
);

-- 4. exercise_for_workout_template - Depends on: workout_template, exercise
CREATE TABLE exercise_for_workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  workoutTemplateId INTEGER NOT NULL,
  exerciseId INTEGER NOT NULL,
  notes TEXT,
  ordering INTEGER,
  exerciseIndex INTEGER DEFAULT 0 NOT NULL,
  FOREIGN KEY(workoutTemplateId) REFERENCES workout_template(id),
  FOREIGN KEY(exerciseId) REFERENCES exercise(id)
);

-- 5. exercise_set_template - Depends on: exercise, exercise_for_workout_template
CREATE TABLE exercise_set_template (
  id INTEGER PRIMARY KEY NOT NULL,
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER NOT NULL,
  setType TEXT,
  exerciseId INTEGER NOT NULL,
  exerciseForWorkoutTemplateId INTEGER NOT NULL,
  FOREIGN KEY(exerciseId) REFERENCES exercise(id),
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id)
);

-- 6. exercise_set - Depends on: workout, exercise, exercise_for_workout_template
CREATE TABLE exercise_set (
  id INTEGER PRIMARY KEY NOT NULL,
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT,
  ordering INTEGER,
  notes TEXT,
  workoutId INTEGER NOT NULL,
  exerciseId INTEGER NOT NULL,
  exerciseForWorkoutTemplateId INTEGER NOT NULL,
  isCompleted INTEGER DEFAULT 0 NOT NULL,
  FOREIGN KEY(workoutId) REFERENCES workout(id),
  FOREIGN KEY(exerciseId) REFERENCES exercise(id),
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id)
);
