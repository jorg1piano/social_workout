-- Sample queries demonstrating how the workout tracking app might use the test data

-- 1. Get all workout templates with their exercise counts
SELECT
    wt.name,
    wt.description,
    COUNT(DISTINCT ewt.ordering) as exercise_slots,
    COUNT(ewt.id) as total_exercise_variants
FROM workout_template wt
LEFT JOIN exercise_for_workout_template ewt ON wt.id = ewt.workout_template_id
GROUP BY wt.id
ORDER BY wt.name;

-- 2. View a complete workout template with all exercise variants
SELECT
    wt.name as template_name,
    ewt.ordering,
    ewt.exercise_index,
    e.name as exercise_name,
    ewt.notes,
    COUNT(est.id) as planned_sets
FROM workout_template wt
JOIN exercise_for_workout_template ewt ON wt.id = ewt.workout_template_id
JOIN exercise e ON ewt.exercise_id = e.id
LEFT JOIN exercise_set_template est ON ewt.id = est.exercise_for_workout_template_id
WHERE wt.name = 'Push Day'
GROUP BY ewt.id
ORDER BY ewt.ordering, ewt.exercise_index;

-- 3. Get planned sets for a specific exercise variant
SELECT
    est.ordering as set_number,
    est.set_type,
    est.rep_count,
    est.weight,
    est.unit,
    est.rir,
    est.rpe,
    est.rest_time
FROM exercise_set_template est
JOIN exercise_for_workout_template ewt ON est.exercise_for_workout_template_id = ewt.id
JOIN exercise e ON ewt.exercise_id = e.id
WHERE e.name = 'Bench Press (Barbell)'
  AND ewt.exercise_index = 0
ORDER BY est.ordering;

-- 4. View recent workout history
SELECT
    w.id,
    wt.name as template_name,
    datetime(w.start_time, 'unixepoch') as started,
    datetime(w.stop_time, 'unixepoch') as finished,
    CASE
        WHEN w.stop_time IS NULL THEN 'In Progress'
        ELSE printf('%.0f min', (w.stop_time - w.start_time) / 60.0)
    END as duration
FROM workout w
LEFT JOIN workout_template wt ON w.template_id = wt.id
ORDER BY w.start_time DESC;

-- 5. Get completed sets for a specific workout
SELECT
    e.name as exercise,
    es.ordering as set_number,
    es.rep_count,
    es.weight,
    es.unit,
    es.rir,
    es.rpe,
    es.notes
FROM exercise_set es
JOIN exercise e ON es.exercise_id = e.id
WHERE es.workout_id = 'app-01KE6BHGMXHSVYM0R5GAQW7FQD'  -- First Push Day workout
  AND es.is_completed = 1
ORDER BY es.ordering;

-- 6. Track progression for a specific exercise variant over time
SELECT
    datetime(w.start_time, 'unixepoch') as workout_date,
    es.ordering as set_number,
    es.weight,
    es.rep_count,
    es.rir,
    es.rpe
FROM exercise_set es
JOIN workout w ON es.workout_id = w.id
JOIN exercise e ON es.exercise_id = e.id
WHERE e.name = 'Bench Press'
  AND es.is_completed = 1
ORDER BY w.start_time DESC, es.ordering;

-- 7. Compare template vs actual performance for a workout
WITH template_sets AS (
    SELECT
        e.name,
        ewt.ordering,
        est.ordering as set_num,
        est.weight as planned_weight,
        est.rep_count as planned_reps
    FROM exercise_set_template est
    JOIN exercise_for_workout_template ewt ON est.exercise_for_workout_template_id = ewt.id
    JOIN exercise e ON ewt.exercise_id = e.id
    WHERE ewt.workout_template_id = 'app-01KE6BHGJAFFKEAQ7X760EBPHJ'
      AND ewt.exercise_index = 0
),
actual_sets AS (
    SELECT
        e.name,
        es.ordering as set_num,
        es.weight as actual_weight,
        es.rep_count as actual_reps
    FROM exercise_set es
    JOIN exercise e ON es.exercise_id = e.id
    WHERE es.workout_id = 'app-01KE6BHGMXHSVYM0R5GAQW7FQD'
      AND es.is_completed = 1
)
SELECT
    t.name,
    t.set_num,
    t.planned_weight,
    a.actual_weight,
    t.planned_reps,
    a.actual_reps,
    CASE
        WHEN a.actual_reps >= t.planned_reps THEN '✓'
        ELSE 'X'
    END as hit_target
FROM template_sets t
LEFT JOIN actual_sets a ON t.name = a.name AND t.set_num = a.set_num
ORDER BY t.ordering, t.set_num;

-- 8. Get workout volume (total weight lifted) for each session
SELECT
    wt.name as template,
    datetime(w.start_time, 'unixepoch') as date,
    SUM(es.weight * es.rep_count) as total_volume,
    COUNT(DISTINCT es.exercise_id) as exercises_performed,
    COUNT(es.id) as total_sets
FROM workout w
JOIN workout_template wt ON w.template_id = wt.id
JOIN exercise_set es ON w.id = es.workout_id
WHERE es.is_completed = 1
  AND es.weight IS NOT NULL
GROUP BY w.id
ORDER BY w.start_time DESC;

-- 9. Find which exercise variants were actually used in workouts
SELECT
    wt.name as template,
    e.name as exercise,
    ewt.exercise_index as variant_index,
    COUNT(DISTINCT w.id) as times_used
FROM exercise_set es
JOIN workout w ON es.workout_id = w.id
JOIN exercise_for_workout_template ewt ON es.exercise_for_workout_template_id = ewt.id
JOIN workout_template wt ON ewt.workout_template_id = wt.id
JOIN exercise e ON ewt.exercise_id = e.id
WHERE es.is_completed = 1
GROUP BY ewt.id
ORDER BY wt.name, ewt.ordering, ewt.exercise_index;

-- 10. Get current workout in progress with next recommended set
SELECT
    wt.name as workout,
    e.name as current_exercise,
    est.ordering as next_set,
    est.set_type,
    est.rep_count as target_reps,
    est.weight as target_weight,
    est.unit,
    est.rest_time
FROM workout w
JOIN workout_template wt ON w.template_id = wt.id
JOIN exercise_for_workout_template ewt ON wt.id = ewt.workout_template_id
JOIN exercise e ON ewt.exercise_id = e.id
JOIN exercise_set_template est ON ewt.id = est.exercise_for_workout_template_id
WHERE w.stop_time IS NULL  -- workout in progress
  AND w.id = 'app-01KE6BHGN8KZT7FNXFQM9ZAQJY'
ORDER BY est.ordering
LIMIT 1;

-- 11. Calculate personal records (PRs) for each exercise
SELECT
    e.name as exercise,
    MAX(es.weight) as max_weight,
    es.unit,
    datetime(w.start_time, 'unixepoch') as achieved_date
FROM exercise_set es
JOIN exercise e ON es.exercise_id = e.id
JOIN workout w ON es.workout_id = w.id
WHERE es.is_completed = 1
  AND es.weight IS NOT NULL
GROUP BY es.exercise_id
ORDER BY e.name;

-- 12. Weekly workout summary
SELECT
    strftime('%Y-%W', datetime(w.start_time, 'unixepoch')) as week,
    COUNT(DISTINCT w.id) as workouts_completed,
    SUM(CASE WHEN w.stop_time IS NOT NULL THEN (w.stop_time - w.start_time) / 60.0 ELSE 0 END) as total_minutes,
    SUM(es.weight * es.rep_count) as total_volume
FROM workout w
LEFT JOIN exercise_set es ON w.id = es.workout_id AND es.is_completed = 1
GROUP BY week
ORDER BY week DESC;
