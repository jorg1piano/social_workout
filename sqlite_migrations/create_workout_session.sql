-- Created when a new workout session is started
CREATE TABLE workout (
  id INTEGER PRIMARY KEY NOT NULL,
  template_id INTEGER,
  start_time INTEGER,
  stop_time INTEGER,
  FOREIGN KEY(template_id) REFERENCES workout_template(id)
);
