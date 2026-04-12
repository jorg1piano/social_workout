-- Competition seed data
-- Creates sample competitions with participants and leaderboard entries.
--
-- Depends on: schema.sql, exercises_complete.sql, feed-seed-data.sql
-- (user_profile and exercise rows must exist before FK resolution)

-- ============================================================================
-- Competitions
-- ============================================================================

-- Competition 1: Bench Press Volume Challenge (active, total_volume)
-- Runs for the current month — who can bench the most total volume?
INSERT INTO competition (id, name, description, competition_type, start_date, end_date, created_by, status) VALUES
('app-01KP0Q58BD3B6ETRMH8NFB64HC',
 'Bench Press Volume War',
 'Most total bench press volume (weight × reps) this month wins. All bench variants count!',
 'total_volume',
 strftime('%s', 'now', 'start of month'),
 strftime('%s', 'now', 'start of month', '+1 month', '-1 second'),
 'app-01KP0CGRYVW31E28H1TV6A605D',
 'active');

-- Competition 2: Squat Max Challenge (active, max_weight)
-- Who can hit the heaviest squat single?
INSERT INTO competition (id, name, description, competition_type, start_date, end_date, created_by, status) VALUES
('app-01KP0Q58BGD1NPA03E2BY6WBWJ',
 'Squat Max Showdown',
 'Heaviest squat single wins. Post your best attempt!',
 'max_weight',
 strftime('%s', 'now', '-14 days'),
 strftime('%s', 'now', '+14 days'),
 'app-01KP0CGRYY87WWH29CYY028PTP',
 'active');

-- Competition 3: 100 Push-ups Daily (upcoming, streak)
-- Can you do push-ups every day for 30 days?
INSERT INTO competition (id, name, description, competition_type, start_date, end_date, created_by, status) VALUES
('app-01KP0Q58BK05GAZ60R2M8P9HAK',
 '100 Push-ups Daily Challenge',
 'Do at least 100 push-ups every day for 30 days. Longest streak wins!',
 'streak',
 strftime('%s', 'now', '+3 days'),
 strftime('%s', 'now', '+33 days'),
 'app-01KP0CGRZ1H6K81WAMGYWX8DX0',
 'upcoming');

-- ============================================================================
-- Competition Exercises
-- ============================================================================

-- Competition 1 tracks: Bench Press (Barbell) and Incline Bench Press (Barbell)
INSERT INTO competition_exercise (id, competition_id, exercise_id) VALUES
('app-01KP0Q58BPKYG9MF88G2W3PQFB', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KE649R3DHD6HFEM69RKAA5BE'),
('app-01KP0Q58BRH624N748JTAQE6J4', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KE649RTDT6F8FK63GNSJGNVQ');

-- Competition 2 tracks: Squat (Barbell)
INSERT INTO competition_exercise (id, competition_id, exercise_id) VALUES
('app-01KP0Q58BV9N3B5MR3NYXRMREV', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KE649S6V1B1B5CBZAAFF2XPG');

-- Competition 3 tracks: Push Up (bodyweight exercise)
-- Using Bench Press as proxy since the exercise library may not have push-ups;
-- in real usage this would reference the actual push-up exercise ID.
INSERT INTO competition_exercise (id, competition_id, exercise_id) VALUES
('app-01KP0Q58BYV6ZMX1WTM4RRWZ21', 'app-01KP0Q58BK05GAZ60R2M8P9HAK', 'app-01KE649R3DHD6HFEM69RKAA5BE');

-- ============================================================================
-- Competition Participants
-- ============================================================================

-- Competition 1 (Bench Volume): all 4 users joined
INSERT INTO competition_participant (id, competition_id, user_id) VALUES
('app-01KP0Q58C1A2BC5NCKE2KX911T', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRYVW31E28H1TV6A605D'),
('app-01KP0Q58C49VFFVP2JSKZ0WDZ2', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRYY87WWH29CYY028PTP'),
('app-01KP0Q58C69EQAJJY8ZDM12KT7', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0'),
('app-01KP0Q58C9ZFP5TG34MGXR2QTY', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Competition 2 (Squat Max): 3 users joined (Sam opted out)
INSERT INTO competition_participant (id, competition_id, user_id) VALUES
('app-01KP0Q58CCRC0268BPNQSK22XC', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRYVW31E28H1TV6A605D'),
('app-01KP0Q58CFGPJH56H9BKEHXZZV', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRYY87WWH29CYY028PTP'),
('app-01KP0Q58CJS2GQ1BX96P8X60M9', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Competition 3 (Push-ups Daily): 2 users signed up so far
INSERT INTO competition_participant (id, competition_id, user_id) VALUES
('app-01KP0Q58CNFV2NSBAKQ6T1S9T5', 'app-01KP0Q58BK05GAZ60R2M8P9HAK', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0'),
('app-01KP0Q58CRT9ND35MTPB64KSGG', 'app-01KP0Q58BK05GAZ60R2M8P9HAK', 'app-01KP0CGRYVW31E28H1TV6A605D');

-- ============================================================================
-- Leaderboard Entries
-- ============================================================================

-- Competition 1 (Bench Volume) — scores based on weight × reps from workouts
INSERT INTO competition_leaderboard_entry (id, competition_id, user_id, score, rank, last_activity_at) VALUES
('app-01KP0Q58CVAXW6RJZT8R2HX4V5', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRYVW31E28H1TV6A605D', 5765, 1, strftime('%s', 'now', '-3 days')),
('app-01KP0Q58CZAMXR7G0GRSGGY473', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRYY87WWH29CYY028PTP', 4050, 2, strftime('%s', 'now', '-1 day')),
('app-01KP0Q58D1FQ15A05YCBX4EM7D', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 3200, 3, strftime('%s', 'now', '-2 days')),
('app-01KP0Q58D4GN3RJ00R8RZCZ33Z', 'app-01KP0Q58BD3B6ETRMH8NFB64HC', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 2400, 4, strftime('%s', 'now', '-4 days'));

-- Competition 2 (Squat Max) — heaviest single
INSERT INTO competition_leaderboard_entry (id, competition_id, user_id, score, rank, last_activity_at) VALUES
('app-01KP0Q58D7SBBK404ZN0VAJ5QY', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRYY87WWH29CYY028PTP', 275, 1, strftime('%s', 'now', '-2 days')),
('app-01KP0Q58DAMWEAPXJ1R6FHY3W1', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRYVW31E28H1TV6A605D', 265, 2, strftime('%s', 'now', '-1 day')),
('app-01KP0Q58DC8GNBZN8G8VH0MWXC', 'app-01KP0Q58BGD1NPA03E2BY6WBWJ', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 225, 3, strftime('%s', 'now', '-3 days'));

-- Competition 3 (Push-ups) — no scores yet since it's upcoming
INSERT INTO competition_leaderboard_entry (id, competition_id, user_id, score, rank, last_activity_at) VALUES
('app-01KP0Q58DF3GYJX8017MESK5BE', 'app-01KP0Q58BK05GAZ60R2M8P9HAK', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 0, NULL, NULL),
('app-01KP0Q58DJGZ3ZVRS7EQNXBCS7', 'app-01KP0Q58BK05GAZ60R2M8P9HAK', 'app-01KP0CGRYVW31E28H1TV6A605D', 0, NULL, NULL);
