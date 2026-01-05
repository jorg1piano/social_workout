-- The exercises that makes up a workout.
-- An exercise can appear multiple times in a template
--
-- "For this workout_template_id, I have these exercises"
CREATE TABLE exercise_for_workout_template (
  id INTEGER PRIMARY KEY NOT NULL,
  workout_template_id INTEGER NOT NULL,
  exercise_id INTEGER NOT NULL,
  notes TEXT,
  ordering INTEGER,
  exercise_index INTEGER DEFAULT 0 NOT NULL, /* Some exercises could be useful to swapping out some exercises */
  FOREIGN KEY(workout_template_id) REFERENCES workout_template(id),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id)
);
