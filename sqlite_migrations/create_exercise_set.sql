-- exercise_set table contains a set for a given exercise
-- rir - Reps in reserve
-- rpe - Rate of perceived exertion
CREATE TABLE exercise_set (
  id INTEGER PRIMARY KEY NOT NULL,
  rep_count INTEGER,
  weight DECIMAL(5,2),
  duration INTEGER, /* Duration in seconds for timed exercises (cardio, planks, etc.) */
  rir DECIMAL(5,2),
  rpe DECIMAL(5,2),
  unit TEXT, /*kg, pound*/
  ordering INTEGER,
  notes TEXT,

  /* Foreign key relationships */
  workout_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,

  /* Since an exercise in theory could appear multiple times during a workout...*/
  /* this links the exercise to a specific set */
  exercise_for_workout_template_id INTEGER NOT NULL,
  is_completed INTEGER DEFAULT 0 NOT NULL,
  FOREIGN KEY(workout_id) REFERENCES workout(id),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id),
  FOREIGN KEY(exercise_for_workout_template_id) REFERENCES exercise_for_workout_template(id)
);
