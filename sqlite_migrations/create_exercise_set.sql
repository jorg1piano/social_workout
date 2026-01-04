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
