-- Training program seed data
-- Uses existing workout_template IDs from new-test-data.sql:
--   Push Day = app-01KE6BHGJAFFKEAQ7X760EBPHJ
--   Pull Day = app-01KE6BHGJFXP86HZR1XJBZHQS4
--   Leg Day  = app-01KE6BHGJK7ST9KXA9FBBRW9X0

-- ============================================================================
-- Program 1: PPL 6-Day (weekly_fixed)
-- ============================================================================
INSERT INTO training_program (id, name, description, schedule_type, cycle_length_weeks, days_per_week) VALUES
('app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'Push/Pull/Legs (6-Day)', 'Classic PPL split run twice per week. High frequency, high volume — ideal for intermediate to advanced lifters.', 'weekly_fixed', 1, 6);

INSERT INTO program_slot (id, training_program_id, workout_template_id, week_number, day_of_week, slot_order, is_rest_day) VALUES
('app-01KP0WZWHKB3TY9QPYW3CX1E6D', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 1, 0, 1, 0),
('app-01KP0WZWRWN67033D36YHD4K2C', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 1, 1, 2, 0),
('app-01KP0WZWZXDS9NQ20PNSZ50D0T', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 1, 2, 3, 0),
('app-01KP0WZX7EMSV67XWY3R2PGM6Y', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', 1, 3, 4, 0),
('app-01KP0WZXEHKZ3CDM52B5X0G6QJ', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', 1, 4, 5, 0),
('app-01KP0WZXNQQCXX3XXYSYWCM1JK', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', 1, 5, 6, 0),
('app-01KP0WZXXGRHBWQ9ERNXXZ18CN', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', NULL, 1, 6, 7, 1);

-- ============================================================================
-- Program 2: PPL 3-Day Rotation
-- ============================================================================
INSERT INTO training_program (id, name, description, schedule_type, cycle_length_weeks, days_per_week) VALUES
('app-01KP0WZY4K89AA95EP9ST2560T', 'Push/Pull/Legs (Rotation)', 'PPL rotation — cycle through Push, Pull, Legs regardless of which day it is. Train 3-6 days per week at your own pace.', 'rotation', NULL, 3);

INSERT INTO program_slot (id, training_program_id, workout_template_id, week_number, day_of_week, slot_order, is_rest_day) VALUES
('app-01KP0WZYBHBRYNSFA8QDWY622Q', 'app-01KP0WZY4K89AA95EP9ST2560T', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', NULL, NULL, 1, 0),
('app-01KP0WZYJMXAVTE9KWVMF80EZ7', 'app-01KP0WZY4K89AA95EP9ST2560T', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', NULL, NULL, 2, 0),
('app-01KP0WZYSXV0XWFH6VPVX0ZR3N', 'app-01KP0WZY4K89AA95EP9ST2560T', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', NULL, NULL, 3, 0);

-- ============================================================================
-- Program 3: Freeform (pick any template)
-- ============================================================================
INSERT INTO training_program (id, name, description, schedule_type, cycle_length_weeks, days_per_week) VALUES
('app-01KP0WZZ151PACCZEQ4WTEY4RT', 'Freeform', 'No fixed schedule — pick whichever workout you feel like on any given day.', 'freeform', NULL, NULL);

INSERT INTO program_slot (id, training_program_id, workout_template_id, week_number, day_of_week, slot_order, is_rest_day) VALUES
('app-01KP0WZZ89T82S3AC9MS0210EV', 'app-01KP0WZZ151PACCZEQ4WTEY4RT', 'app-01KE6BHGJAFFKEAQ7X760EBPHJ', NULL, NULL, 1, 0),
('app-01KP0WZZFK7WS1PDMDDW27N0XQ', 'app-01KP0WZZ151PACCZEQ4WTEY4RT', 'app-01KE6BHGJFXP86HZR1XJBZHQS4', NULL, NULL, 2, 0),
('app-01KP0WZZPQX09QQC9YQZFDGF0K', 'app-01KP0WZZ151PACCZEQ4WTEY4RT', 'app-01KE6BHGJK7ST9KXA9FBBRW9X0', NULL, NULL, 3, 0);

-- ============================================================================
-- Enrollment: current user is on the PPL 6-Day program
-- ============================================================================
INSERT INTO program_enrollment (id, user_id, training_program_id, current_week, current_slot_order, started_at, is_active, cycle_count) VALUES
('app-01KP0WZZXQ1RZCN3P4B3JKTV0D', 'app-01KP0CGRYVW31E28H1TV6A605D', 'app-01KP0WZW9BMMK0D0WGAE9PQMQ7', 1, 3, strftime('%s', 'now', '-14 days'), 1, 2);
