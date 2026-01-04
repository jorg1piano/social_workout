-- The exercises that makes up a workout.
-- An exercise can appear multiple times in a template
--
-- "For this workoutTemplateId, I have these exercises"

CREATE TABLE exercise_for_workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  workoutTemplateId INTEGER NOT NULL,
  exerciseId INTEGER NOT NULL,
  notes TEXT,
  ordering INTEGER,
  exerciseIndex INTEGER DEFAULT 0 NOT NULL, /* Some exercises could be useful to swapping out some exercises */
  FOREIGN KEY(workoutTemplateId) REFERENCES workout_template(id),
  FOREIGN KEY(exerciseId) REFERENCES exercise(id)
);

CREATE TABLE exercise_set_template (
  id INTEGER PRIMARY KEY NOT NULL,
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT, /*kilos, pounds*/
  ordering INTEGER NOT NULL,

  /*TODO: Consider placing this in a separate column to facilitate custom types added by a user*/
  setType TEXT, /* warmup, regularSet, dropSet, failure */

  exerciseId INTEGER NOT NULL, /* Foreign key relationships */

  /* Since an exercise in theory could appear multiple times during a workout...*/
  /* this links the exercise to a specific set */
  exerciseForWorkoutTemplateId INTEGER NOT NULL,

  FOREIGN KEY(exerciseId) REFERENCES exercise(id),
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id)
);
-- exercise_set table contains a set for a given exercise
-- RIR - Reps in reserve
-- RPE - Rate of perceived exertion

CREATE TABLE exercise_set (
  id INTEGER PRIMARY KEY NOT NULL,
  repCount INTEGER,
  weight DECIMAL(5,2),
  RIR DECIMAL(5,2),
  RPE DECIMAL(5,2),
  unit TEXT, /*kg, pound*/
  ordering INTEGER,
  notes TEXT,

  /* Foreign key relationships */
  workoutId INTEGER NOT NULL,
  exerciseId INTEGER NOT NULL,

  /* Since an exercise in theory could appear multiple times during a workout...*/
  /* this links the exercise to a specific set */
  exerciseForWorkoutTemplateId INTEGER NOT NULL,
  isCompleted INTEGER DEFAULT 0 NOT NULL,
  FOREIGN KEY(workoutId) REFERENCES workout(id),
  FOREIGN KEY(exerciseId) REFERENCES exercise(id),
  FOREIGN KEY(exerciseForWorkoutTemplateId) REFERENCES exercise_for_workout_template(id)
);
-- Describes an exercise: Push up, Barbell curls, etc..

CREATE TABLE exercise (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT,
  category TEXT,
  bodyPart TEXT
);
-- Created when a new workout session is started

CREATE TABLE workout (
  id INTEGER PRIMARY KEY NOT NULL,
  templateId INTEGER,
  startTime INTEGER,
  stopTime INTEGER,
  FOREIGN KEY(templateId) REFERENCES workout_template(id)
);
-- Workout table contains workouts: ie "Chest day", "Pull", etc...
-- This does not connect to anything else

CREATE TABLE workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT
);
