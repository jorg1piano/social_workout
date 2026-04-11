Strengths

  1. Exercise variants system - The ordering + exercise_index pattern elegantly
  handles exercise substitutions (flat bench vs incline, barbell vs dumbbell). This is
   more flexible than rigid templates.
  2. Template vs execution separation - Clear distinction between
  exercise_set_template (planned) and exercise_set (actual) allows tracking adherence
  and progression.
  3. ULIDs with prefixes - The app-/usr- prefixing is smart for distinguishing system
  vs user-created data while maintaining sortability.
  4. RIR/RPE tracking - Including both Reps In Reserve and Rate of Perceived Exertion
  gives good intensity metrics for progressive overload.
  5. Flexible exercise tracking - Supporting both rep_count + weight and duration
  handles strength training and cardio/timed exercises.

  Potential Issues

  1. Nullable workout times - workout.start_time and stop_time are nullable, but you
  probably want start_time to be NOT NULL (a workout must have started). Only
  stop_time should be nullable for in-progress workouts.
  2. Missing workout completion flag - You track exercise_set.is_completed, but
  there's no workout.is_completed or status field. How do you distinguish between:
    - Abandoned workouts (started but never finished)
    - In-progress workouts (actively being performed)
    - Completed workouts (finished normally)
  3. Set ordering gaps - If a user skips a set or adds extra sets mid-workout,
  exercise_set.ordering could have gaps or duplicates. Consider whether this matters
  for your use case.
  4. No variant selection tracking - When a workout starts, how do you record which
  exercise variants were chosen? The exercise_set table links to
  exercise_for_workout_template_id, which works, but there's no explicit "variant
  selection" snapshot at workout start.
  5. Body part/equipment data missing - Test data doesn't populate exercise_body_part
  or exercise_equipment tables, making it hard to query "show me all chest exercises"
  or "exercises I can do with dumbbells only."

  Questions

  - How do you handle workout template modifications after workouts using that
  template have been logged?
  - Should exercise_set.ordering be nullable? Currently it is, but sets should always
  have an order.
  - Do you need workout-level notes/rating fields for tracking overall session
  quality?

  Overall it's a solid foundation for a workout tracking app.