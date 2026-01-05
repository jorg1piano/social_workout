CREATE TABLE exercise_set_template (
  id INTEGER PRIMARY KEY NOT NULL,
  rep_count INTEGER,
  weight DECIMAL(5,2),
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT, /*kilos, pounds*/
  ordering INTEGER NOT NULL,

  /*TODO: Consider placing this in a separate column to facilitate custom types added by a user*/
  set_type TEXT, /* warmup, regularSet, dropSet, failure */

  exercise_id INTEGER NOT NULL, /* Foreign key relationships */

  /* Since an exercise in theory could appear multiple times during a workout...*/
  /* this links the exercise to a specific set */
  exercise_for_workout_template_id INTEGER NOT NULL,

  FOREIGN KEY(exercise_id) REFERENCES exercise(id),
  FOREIGN KEY(exercise_for_workout_template_id) REFERENCES exercise_for_workout_template(id)
);
