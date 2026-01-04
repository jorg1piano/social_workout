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
