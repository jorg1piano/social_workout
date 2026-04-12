-- Social feed seed data
-- Creates user profiles, feed items (workout completions, PRs, streaks),
-- likes, and comments for development and testing.
--
-- Depends on: schema.sql, exercises_complete.sql, new-test-data.sql
-- (workout and exercise rows must exist before feed_item FKs can resolve)

-- ============================================================================
-- User Profiles
-- ============================================================================
-- User 1: The current/local user
INSERT INTO user_profile (id, display_name, username, avatar_url, bio, is_current_user) VALUES
('app-01KP0CGRYVW31E28H1TV6A605D', 'Alex Johnson', 'alexj', NULL, 'Push/Pull/Legs enthusiast. Chasing a 3-plate bench.', 1);

-- User 2: A friend
INSERT INTO user_profile (id, display_name, username, avatar_url, bio, is_current_user) VALUES
('app-01KP0CGRYY87WWH29CYY028PTP', 'Maria Garcia', 'maria_lifts', NULL, 'Powerlifter in training. Squat is life.', 0);

-- User 3: Another friend
INSERT INTO user_profile (id, display_name, username, avatar_url, bio, is_current_user) VALUES
('app-01KP0CGRZ1H6K81WAMGYWX8DX0', 'Sam Chen', 'samthelifter', NULL, 'Consistency over intensity. 200-day streak and counting.', 0);

-- User 4: Another friend
INSERT INTO user_profile (id, display_name, username, avatar_url, bio, is_current_user) VALUES
('app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 'Jordan Taylor', 'jtfit', NULL, 'Former runner, now addicted to deadlifts.', 0);

-- ============================================================================
-- Feed Items
-- ============================================================================

-- Feed Item 1: Alex completed Push Day (references real workout from test data)
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRYVW31E28H1TV6A605D', 'workout_completed',
 'Completed Push Day',
 'Bench Press 4x8 @ 205 lbs, OHP 3x8 @ 125 lbs, Lateral Raises, Tricep Pushdowns. Solid session!',
 'app-01KE6BHGMXHSVYM0R5GAQW7FQD', NULL,
 75, 'minutes',
 3, 2,
 strftime('%s', 'now', '-3 days', '+11 hours'));

-- Feed Item 2: Maria hit a squat PR
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRYY87WWH29CYY028PTP', 'personal_record',
 'New Squat PR!',
 'Finally hit 275 lbs on back squat! Been chasing this for months.',
 NULL, 'app-01KE649S6V1B1B5CBZAAFF2XPG',
 275, 'lbs',
 8, 4,
 strftime('%s', 'now', '-2 days', '+14 hours'));

-- Feed Item 3: Sam hit a 200-day streak
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 'streak_milestone',
 '200-Day Workout Streak!',
 'Haven''t missed a single day in 200 days. Rest days count as stretching/mobility.',
 NULL, NULL,
 200, 'days',
 12, 3,
 strftime('%s', 'now', '-2 days', '+8 hours'));

-- Feed Item 4: Alex completed Pull Day (references real workout)
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZFR4YHCSGYAQC3BRG1', 'app-01KP0CGRYVW31E28H1TV6A605D', 'workout_completed',
 'Completed Pull Day',
 'Deadlift 3x5 @ 315 lbs, Pull-ups, Barbell Rows, Curls. Back is pumped.',
 'app-01KE6BHGN1G3AS2HXRNC3FTF5K', NULL,
 90, 'minutes',
 2, 1,
 strftime('%s', 'now', '-2 days', '+11 hours'));

-- Feed Item 5: Jordan completed a workout
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZJF8ANDVJ0E357WTAR', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 'workout_completed',
 'Completed Leg Day',
 'Squats, RDLs, Leg Press, and calves. Legs are toast.',
 NULL, NULL,
 60, 'minutes',
 4, 1,
 strftime('%s', 'now', '-1 day', '+16 hours'));

-- Feed Item 6: Alex hit a deadlift PR
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRYVW31E28H1TV6A605D', 'personal_record',
 'New Deadlift PR!',
 'Pulled 365 lbs for a clean single. Next stop: 4 plates!',
 'app-01KE6BHGN1G3AS2HXRNC3FTF5K', 'app-01KE649R9AJJEY97C4SQMPGK0P',
 365, 'lbs',
 6, 2,
 strftime('%s', 'now', '-2 days', '+11 hours', '+30 minutes'));

-- Feed Item 7: Maria completed a workout
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZQV1FZMF3075F82HBP', 'app-01KP0CGRYY87WWH29CYY028PTP', 'workout_completed',
 'Completed Upper Body Day',
 'Bench 5x5 @ 135, OHP, Rows, and accessories. Feeling strong!',
 NULL, NULL,
 55, 'minutes',
 3, 0,
 strftime('%s', 'now', '-1 day', '+10 hours'));

-- Feed Item 8: Sam completed a workout
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZSCET7S5KZVN50TDVR', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 'workout_completed',
 'Completed Full Body Day',
 'Light full-body session. Squats, bench, rows, and some core work.',
 NULL, NULL,
 45, 'minutes',
 1, 0,
 strftime('%s', 'now', '-1 day', '+7 hours'));

-- Feed Item 9: Jordan hit a 30-day streak
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZWRH52R3PW33BB9P3S', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 'streak_milestone',
 '30-Day Workout Streak!',
 'One month of consistent training. Building the habit.',
 NULL, NULL,
 30, 'days',
 5, 2,
 strftime('%s', 'now', '-12 hours'));

-- Feed Item 10: Alex completed Leg Day (references real workout)
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGRZYAPWZMYM16R6TT4CA', 'app-01KP0CGRYVW31E28H1TV6A605D', 'workout_completed',
 'Completed Leg Day',
 'Squats 4x6 @ 275 lbs, RDLs, Leg Press, Extensions, Curls, Calves. Everything hurts.',
 'app-01KE6BHGN4YT8HXPS69FARA9Z2', NULL,
 105, 'minutes',
 4, 1,
 strftime('%s', 'now', '-1 day', '+11 hours'));

-- Feed Item 11: Maria hit a bench PR
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRYY87WWH29CYY028PTP', 'personal_record',
 'New Bench Press PR!',
 'Hit 155 lbs for a double! Slow and steady progress.',
 NULL, 'app-01KE649R3DHD6HFEM69RKAA5BE',
 155, 'lbs',
 7, 3,
 strftime('%s', 'now', '-6 hours'));

-- Feed Item 12: Sam completed today's workout
INSERT INTO feed_item (id, user_id, item_type, title, description, workout_id, exercise_id, metric_value, metric_unit, like_count, comment_count, occurred_at) VALUES
('app-01KP0CGS0365G3ZJ9GRY53RGT2', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 'workout_completed',
 'Completed Push Day',
 'Day 201. Push session: bench, dips, flyes. Keeping the streak alive!',
 NULL, NULL,
 50, 'minutes',
 2, 1,
 strftime('%s', 'now', '-3 hours'));

-- ============================================================================
-- Feed Likes
-- ============================================================================

-- Likes on Feed Item 1 (Alex's Push Day) — 3 likes
INSERT INTO feed_like (id, feed_item_id, user_id) VALUES
('app-01KP0CGS053BF2P8FKB6WRCD4E', 'app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRYY87WWH29CYY028PTP'),
('app-01KP0CGS07ZKBAN9QY0AXWJSQM', 'app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0'),
('app-01KP0CGS0AB2GTSRVSGNWS84QM', 'app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Likes on Feed Item 2 (Maria's Squat PR) — 8 likes (all 4 users + would be more, but we only have 4)
INSERT INTO feed_like (id, feed_item_id, user_id) VALUES
('app-01KP0CGS0CZQG9M9K7F98K08HW', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRYVW31E28H1TV6A605D'),
('app-01KP0CGS0E5E1Z84H53ERVNHR5', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0'),
('app-01KP0CGS0G015596MDY1A9TV48', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Likes on Feed Item 3 (Sam's 200-day streak) — all 3 others liked
INSERT INTO feed_like (id, feed_item_id, user_id) VALUES
('app-01KP0CGS0J98KRZ218M1KH5XNG', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRYVW31E28H1TV6A605D'),
('app-01KP0CGS0N1FMZB7XDQVB3WX82', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRYY87WWH29CYY028PTP'),
('app-01KP0CGS0Q84V76VT6ZWF4K601', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Likes on Feed Item 6 (Alex's Deadlift PR)
INSERT INTO feed_like (id, feed_item_id, user_id) VALUES
('app-01KP0CGS0SCGTYG6GZQAR1JZ8G', 'app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRYY87WWH29CYY028PTP'),
('app-01KP0CGS0VKDEQKFZ4NZDFMVS4', 'app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0'),
('app-01KP0CGS0XJEHT9Q7EZW1CABFB', 'app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD');

-- Likes on Feed Item 11 (Maria's Bench PR)
INSERT INTO feed_like (id, feed_item_id, user_id) VALUES
('app-01KP0CGS0ZTTCB0Y39GVG34295', 'app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRYVW31E28H1TV6A605D'),
('app-01KP0CGS1225B44F47ATHF9JKX', 'app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0');

-- ============================================================================
-- Feed Comments
-- ============================================================================

-- Comments on Feed Item 1 (Alex's Push Day) — 2 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS14TZPZY0DMSZRW6J12', 'app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRYY87WWH29CYY028PTP',
 'Nice session! How''s the bench progressing?');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS16PGGSZNS0EFRGSN6F', 'app-01KP0CGRZ7DRH1XD8NAKGGVGN6', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0',
 'Solid work. 205 for reps is no joke!');

-- Comments on Feed Item 2 (Maria's Squat PR) — 4 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS18VXXAMQZMPCHW2XN9', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'That''s insane! 275 is a huge milestone.');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1B4C6KNP9D86HW5037', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0',
 'Congrats Maria! 3 plates next?');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1D0D7J20GZF36WNTR3', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD',
 'You''re making the rest of us look bad!');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1GHF2CNPX0C9DRRPYM', 'app-01KP0CGRZAN7GK90JWG3W32623', 'app-01KP0CGRYY87WWH29CYY028PTP',
 'Thanks everyone! 3 plates is the dream. Maybe by summer.');

-- Comments on Feed Item 3 (Sam's 200-day streak) — 3 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1JR34SMSZ4FC5SZKTE', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'Absolute machine. 200 days is incredible consistency.');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1M8B6MB97CJDG5YQBB', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRYY87WWH29CYY028PTP',
 'This is so inspiring. I can barely keep a 2-week streak going!');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1PPZGP4HC1PEHTG0AD', 'app-01KP0CGRZDXG7H8BHAHCD8DCM0', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD',
 'Legend status. What''s your secret?');

-- Comments on Feed Item 6 (Alex's Deadlift PR) — 2 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1S8367ATQKFHFXB4YE', 'app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD',
 'Fellow deadlift lover here - 365 is awesome! 4 plates soon.');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1VS7CME08BFXGCJ4XY', 'app-01KP0CGRZM4DTAKTNDGJKRTRGV', 'app-01KP0CGRYY87WWH29CYY028PTP',
 'Strong pull! What grip are you using?');

-- Comments on Feed Item 9 (Jordan's 30-day streak) — 2 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1XMG6NMQSF7Q38JVMT', 'app-01KP0CGRZWRH52R3PW33BB9P3S', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'First 30 days is the hardest part. Keep it up!');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS1ZKFQ11MAZAPEC5KFT', 'app-01KP0CGRZWRH52R3PW33BB9P3S', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0',
 'Welcome to the streak club!');

-- Comments on Feed Item 11 (Maria's Bench PR) — 3 comments
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS22DEC47YJ5S0ZGX6V5', 'app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'Bench gains! Nice work Maria.');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS24WPAST6QWW05NW38E', 'app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD',
 'Slow and steady wins the race. Respect.');
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS26JFT9VS09WZ7CYS8C', 'app-01KP0CGS00JB511G5HTZZ0Z1PF', 'app-01KP0CGRYY87WWH29CYY028PTP',
 'Thanks! Paused reps are really helping my lockout.');

-- Comment on Feed Item 4 (Alex's Pull Day) — 1 comment
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS29EB2629ESE3G4JE4K', 'app-01KP0CGRZFR4YHCSGYAQC3BRG1', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD',
 '315 deadlift in a pull day? Beast mode.');

-- Comment on Feed Item 5 (Jordan's Leg Day) — 1 comment
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS2BVZ51M0K8CQMEBECT', 'app-01KP0CGRZJF8ANDVJ0E357WTAR', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'Welcome to the legs-are-toast club!');

-- Comment on Feed Item 10 (Alex's Leg Day) — 1 comment
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS2DPEMWWQAE6CDCMQ3A', 'app-01KP0CGRZYAPWZMYM16R6TT4CA', 'app-01KP0CGRYY87WWH29CYY028PTP',
 '275 squat! You and I should have a squat-off sometime.');

-- Comment on Feed Item 12 (Sam's Push Day) — 1 comment
INSERT INTO feed_comment (id, feed_item_id, user_id, body) VALUES
('app-01KP0CGS2GS50R6Y5MQ7V0RDCH', 'app-01KP0CGS0365G3ZJ9GRY53RGT2', 'app-01KP0CGRYVW31E28H1TV6A605D',
 'Day 201! You never stop.');

-- ============================================================================
-- Planned Workouts ("Who's working out today" Stories row)
-- ============================================================================

-- Alex: Push Day today at 6 PM
INSERT INTO planned_workout (id, user_id, workout_template_id, planned_date, planned_time, notes) VALUES
('app-01KP0QG2KZ84Z9EZ8X8G01M43R', 'app-01KP0CGRYVW31E28H1TV6A605D', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ',
 strftime('%s', 'now', 'start of day'), strftime('%s', 'now', 'start of day', '+18 hours'),
 'Going heavy on bench today');

-- Maria: Leg Day today at 7:30 AM (early bird)
INSERT INTO planned_workout (id, user_id, workout_template_id, planned_date, planned_time, notes) VALUES
('app-01KP0QG2M3X23BFMADA6BZ35E7', 'app-01KP0CGRYY87WWH29CYY028PTP', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0',
 strftime('%s', 'now', 'start of day'), strftime('%s', 'now', 'start of day', '+7 hours', '+30 minutes'),
 NULL);

-- Sam: Pull Day today, no specific time
INSERT INTO planned_workout (id, user_id, workout_template_id, planned_date, planned_time, notes) VALUES
('app-01KP0QG2M65GT4DWX5X6KQEV1B', 'app-01KP0CGRZ1H6K81WAMGYWX8DX0', 'app-01KE6BHGJFXP86HZR1XJBZHQS4',
 strftime('%s', 'now', 'start of day'), NULL,
 'Day 202 — keeping the streak alive');

-- Jordan: Push Day today, no specific time
INSERT INTO planned_workout (id, user_id, workout_template_id, planned_date, planned_time, notes) VALUES
('app-01KP0QG2M9CQ4QGN7DCRWS0GS3', 'app-01KP0CGRZ4HQW4CHEWFB9YG3KD', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ',
 strftime('%s', 'now', 'start of day'), NULL,
 NULL);

-- Alex also has Leg Day planned tomorrow at 5 PM (shows only today's in stories)
INSERT INTO planned_workout (id, user_id, workout_template_id, planned_date, planned_time, notes) VALUES
('app-01KP0QG2MD7FV0E6R6QZBTWGPP', 'app-01KP0CGRYVW31E28H1TV6A605D', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0',
 strftime('%s', 'now', 'start of day', '+1 day'), strftime('%s', 'now', 'start of day', '+1 day', '+17 hours'),
 'Squat day — aiming for 285');
