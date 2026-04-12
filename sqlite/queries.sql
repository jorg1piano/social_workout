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
-- Note: set_type lives directly on exercise_set, so warmup-vs-working status
-- is readable without joining exercise_set_template.
SELECT
    e.name as exercise,
    es.ordering as set_number,
    es.set_type,
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

-- ============================================================================
-- Social Feed Queries
-- ============================================================================

-- 13. Get social feed (paginated, most recent first)
SELECT
    fi.id,
    fi.item_type,
    fi.title,
    fi.description,
    fi.metric_value,
    fi.metric_unit,
    fi.like_count,
    fi.comment_count,
    datetime(fi.occurred_at, 'unixepoch') as occurred,
    up.display_name,
    up.username,
    up.avatar_url
FROM feed_item fi
JOIN user_profile up ON fi.user_id = up.id
ORDER BY fi.occurred_at DESC
LIMIT 20 OFFSET 0;

-- 14. Get feed items for a specific user
SELECT
    fi.id,
    fi.item_type,
    fi.title,
    fi.description,
    fi.metric_value,
    fi.metric_unit,
    fi.like_count,
    fi.comment_count,
    datetime(fi.occurred_at, 'unixepoch') as occurred
FROM feed_item fi
WHERE fi.user_id = 'app-01KP0CGRYVW31E28H1TV6A605D'
ORDER BY fi.occurred_at DESC;

-- 15. Get comments for a feed item
SELECT
    fc.id,
    fc.body,
    datetime(fc.created_at, 'unixepoch') as posted_at,
    up.display_name,
    up.username,
    up.avatar_url
FROM feed_comment fc
JOIN user_profile up ON fc.user_id = up.id
WHERE fc.feed_item_id = 'app-01KP0CGRZAN7GK90JWG3W32623'
ORDER BY fc.created_at ASC;

-- 16. Check if current user has liked a feed item
SELECT EXISTS(
    SELECT 1 FROM feed_like
    WHERE feed_item_id = 'app-01KP0CGRZAN7GK90JWG3W32623'
      AND user_id = 'app-01KP0CGRYVW31E28H1TV6A605D'
) as has_liked;

-- 17. Get feed summary stats for a user profile
SELECT
    up.display_name,
    up.username,
    up.bio,
    COUNT(DISTINCT CASE WHEN fi.item_type = 'workout_completed' THEN fi.id END) as workouts_shared,
    COUNT(DISTINCT CASE WHEN fi.item_type = 'personal_record' THEN fi.id END) as prs_posted,
    MAX(CASE WHEN fi.item_type = 'streak_milestone' THEN fi.metric_value END) as best_streak
FROM user_profile up
LEFT JOIN feed_item fi ON up.id = fi.user_id
WHERE up.id = 'app-01KP0CGRYVW31E28H1TV6A605D'
GROUP BY up.id;

-- ============================================================================
-- Competition Queries
-- ============================================================================

-- 18. List all competitions with participant count and status
SELECT
    c.id,
    c.name,
    c.competition_type,
    c.status,
    datetime(c.start_date, 'unixepoch') as starts,
    datetime(c.end_date, 'unixepoch') as ends,
    up.display_name as created_by,
    COUNT(cp.id) as participant_count
FROM competition c
JOIN user_profile up ON c.created_by = up.id
LEFT JOIN competition_participant cp ON c.id = cp.competition_id
GROUP BY c.id
ORDER BY c.start_date DESC;

-- 19. Get competition details with tracked exercises
SELECT
    c.name as competition_name,
    c.description,
    c.competition_type,
    c.status,
    e.name as exercise_name
FROM competition c
JOIN competition_exercise ce ON c.id = ce.competition_id
JOIN exercise e ON ce.exercise_id = e.id
WHERE c.id = 'app-01KP0Q58BD3B6ETRMH8NFB64HC';

-- 20. Get leaderboard for a competition (ranked by score)
SELECT
    cle.rank,
    up.display_name,
    up.username,
    cle.score,
    datetime(cle.last_activity_at, 'unixepoch') as last_active
FROM competition_leaderboard_entry cle
JOIN user_profile up ON cle.user_id = up.id
WHERE cle.competition_id = 'app-01KP0Q58BD3B6ETRMH8NFB64HC'
ORDER BY cle.score DESC;

-- 21. Get competitions the current user has joined
SELECT
    c.id,
    c.name,
    c.competition_type,
    c.status,
    cle.score as my_score,
    cle.rank as my_rank,
    (SELECT COUNT(*) FROM competition_participant cp2 WHERE cp2.competition_id = c.id) as total_participants
FROM competition c
JOIN competition_participant cp ON c.id = cp.competition_id
LEFT JOIN competition_leaderboard_entry cle ON c.id = cle.competition_id AND cle.user_id = cp.user_id
WHERE cp.user_id = 'app-01KP0CGRYVW31E28H1TV6A605D'
ORDER BY c.status = 'active' DESC, c.start_date DESC;

-- 22. Calculate live total_volume score for a user in a competition
-- Sums weight × reps from exercise_set for all tracked exercises within the date range
SELECT
    up.display_name,
    SUM(es.weight * es.rep_count) as calculated_volume
FROM exercise_set es
JOIN workout w ON es.workout_id = w.id
JOIN competition_exercise ce ON es.exercise_id = ce.exercise_id
JOIN competition c ON ce.competition_id = c.id
JOIN competition_participant cp ON c.id = cp.competition_id AND cp.user_id = 'app-01KP0CGRYVW31E28H1TV6A605D'
JOIN user_profile up ON cp.user_id = up.id
WHERE c.id = 'app-01KP0Q58BD3B6ETRMH8NFB64HC'
  AND es.is_completed = 1
  AND w.start_time >= c.start_date
  AND w.start_time <= c.end_date
GROUP BY cp.user_id;

-- 23. Get active competitions (for home screen / competition list)
SELECT
    c.id,
    c.name,
    c.competition_type,
    datetime(c.end_date, 'unixepoch') as ends,
    (SELECT COUNT(*) FROM competition_participant cp WHERE cp.competition_id = c.id) as participants,
    up.display_name as leader_name,
    MAX(cle.score) as top_score
FROM competition c
LEFT JOIN competition_leaderboard_entry cle ON c.id = cle.competition_id AND cle.rank = 1
LEFT JOIN user_profile up ON cle.user_id = up.id
WHERE c.status = 'active'
GROUP BY c.id
ORDER BY c.end_date ASC;

-- ============================================================================
-- Training Program Queries
-- ============================================================================

-- 22. Get a user's active training program with all its slots
SELECT
    tp.id as program_id,
    tp.name as program_name,
    tp.schedule_type,
    tp.cycle_length_weeks,
    tp.days_per_week,
    pe.current_week,
    pe.current_slot_order,
    pe.cycle_count,
    ps.slot_order,
    ps.week_number,
    ps.day_of_week,
    ps.is_rest_day,
    ps.notes as slot_notes,
    wt.id as template_id,
    wt.name as template_name
FROM program_enrollment pe
JOIN training_program tp ON pe.training_program_id = tp.id
LEFT JOIN program_slot ps ON tp.id = ps.training_program_id
LEFT JOIN workout_template wt ON ps.workout_template_id = wt.id
WHERE pe.user_id = :user_id
  AND pe.is_active = 1
ORDER BY ps.week_number ASC NULLS LAST, ps.slot_order ASC;

-- 23. Get today's workout for a weekly_fixed program
-- Uses day_of_week: 0=Monday..6=Sunday (matching SQLite strftime('%w') with adjustment)
SELECT
    wt.id as template_id,
    wt.name as template_name,
    wt.description,
    ps.notes as slot_notes
FROM program_enrollment pe
JOIN training_program tp ON pe.training_program_id = tp.id
JOIN program_slot ps ON tp.id = ps.training_program_id
JOIN workout_template wt ON ps.workout_template_id = wt.id
WHERE pe.user_id = :user_id
  AND pe.is_active = 1
  AND tp.schedule_type = 'weekly_fixed'
  AND ps.week_number = 1
  AND ps.day_of_week = :today_day_of_week
  AND ps.is_rest_day = 0;

-- 24. Get the next workout for a rotation program
SELECT
    wt.id as template_id,
    wt.name as template_name,
    wt.description,
    ps.slot_order,
    ps.notes as slot_notes
FROM program_enrollment pe
JOIN training_program tp ON pe.training_program_id = tp.id
JOIN program_slot ps ON tp.id = ps.training_program_id
JOIN workout_template wt ON ps.workout_template_id = wt.id
WHERE pe.user_id = :user_id
  AND pe.is_active = 1
  AND tp.schedule_type = 'rotation'
  AND ps.slot_order = pe.current_slot_order
  AND ps.is_rest_day = 0;

-- 25. List all training programs with enrollment status for a user
SELECT
    tp.id,
    tp.name,
    tp.description,
    tp.schedule_type,
    tp.days_per_week,
    pe.id as enrollment_id,
    pe.is_active,
    pe.cycle_count,
    (SELECT COUNT(*) FROM program_slot ps WHERE ps.training_program_id = tp.id AND ps.is_rest_day = 0) as workout_count
FROM training_program tp
LEFT JOIN program_enrollment pe ON tp.id = pe.training_program_id AND pe.user_id = :user_id
ORDER BY pe.is_active DESC NULLS LAST, tp.name ASC;
