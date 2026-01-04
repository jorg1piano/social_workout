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
