-- Migration: create competition tables
-- Adds competition, competition_exercise, competition_participant,
-- and competition_leaderboard_entry tables for the competitions feature.

CREATE TABLE IF NOT EXISTS competition (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL,
  description TEXT,
  competition_type TEXT NOT NULL CHECK (competition_type IN ('total_volume', 'max_weight', 'streak', 'total_reps')),
  start_date INTEGER NOT NULL,
  end_date INTEGER NOT NULL,
  created_by TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'completed')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(created_by) REFERENCES user_profile(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS competition_exercise (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  exercise_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS competition_participant (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  joined_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS competition_leaderboard_entry (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  competition_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  score DECIMAL(10,2) NOT NULL DEFAULT 0,
  rank INTEGER,
  last_activity_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES user_profile(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_competition_created_by ON competition(created_by);
CREATE INDEX IF NOT EXISTS idx_competition_status ON competition(status);
CREATE INDEX IF NOT EXISTS idx_competition_exercise_competition_id ON competition_exercise(competition_id);
CREATE INDEX IF NOT EXISTS idx_competition_exercise_exercise_id ON competition_exercise(exercise_id);
CREATE INDEX IF NOT EXISTS idx_competition_participant_competition_id ON competition_participant(competition_id);
CREATE INDEX IF NOT EXISTS idx_competition_participant_user_id ON competition_participant(user_id);
CREATE INDEX IF NOT EXISTS idx_competition_leaderboard_entry_competition_id ON competition_leaderboard_entry(competition_id);
CREATE INDEX IF NOT EXISTS idx_competition_leaderboard_entry_user_id ON competition_leaderboard_entry(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_competition_exercise_unique ON competition_exercise(competition_id, exercise_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_competition_participant_unique ON competition_participant(competition_id, user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_competition_leaderboard_entry_unique ON competition_leaderboard_entry(competition_id, user_id);
