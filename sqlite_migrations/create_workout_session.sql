-- Created when a new workout session is started
CREATE TABLE workout (
  id INTEGER PRIMARY KEY NOT NULL,
  templateId INTEGER,
  startTime INTEGER,
  stopTime INTEGER,
  FOREIGN KEY(templateId) REFERENCES workout_template(id)
);
