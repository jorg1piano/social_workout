-- Describes an exercise: Push up, Barbell curls, etc..
CREATE TABLE exercise (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT,
  description TEXT,
  notes TEXT,
  category TEXT,
  body_part TEXT
);
