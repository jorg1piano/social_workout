# Category System Implementation Plan

## Overview
Implement a multi-category system for exercises, allowing each exercise to have multiple body parts and multiple equipment/type categories.

## Current State
The `exercise` table currently has:
- `category TEXT` - single equipment/type category
- `body_part TEXT` - single body part category

## Proposed Changes

### 1. New Category Tables (Add before `exercise` table)

#### body_part_category
```sql
CREATE TABLE body_part_category (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);
```

**Predefined values:**
- core
- arms
- back
- chest
- legs
- shoulders
- Olympic
- Full Body
- Cardio

#### equipment_category
```sql
CREATE TABLE equipment_category (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  name TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);
```

**Predefined values:**
- Barbell
- Dumbbell
- Machine / Other
- Weighted Bodyweight
- Assisted Bodyweight
- Reps only
- Cardio
- Duration

### 2. Junction Tables (Add after `exercise` table)

#### exercise_body_part
```sql
CREATE TABLE exercise_body_part (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  exercise_id TEXT NOT NULL,
  body_part_category_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE CASCADE,
  FOREIGN KEY(body_part_category_id) REFERENCES body_part_category(id) ON DELETE RESTRICT
);
```

#### exercise_equipment
```sql
CREATE TABLE exercise_equipment (
  id TEXT PRIMARY KEY NOT NULL CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  exercise_id TEXT NOT NULL,
  equipment_category_id TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  FOREIGN KEY(exercise_id) REFERENCES exercise(id) ON DELETE CASCADE,
  FOREIGN KEY(equipment_category_id) REFERENCES equipment_category(id) ON DELETE RESTRICT
);
```

### 3. Update exercise table

Remove these fields:
- `category TEXT`
- `body_part TEXT`

### 4. Indexes

Add these indexes for query performance:
```sql
CREATE INDEX idx_exercise_body_part_exercise_id ON exercise_body_part(exercise_id);
CREATE INDEX idx_exercise_body_part_category_id ON exercise_body_part(body_part_category_id);
CREATE INDEX idx_exercise_equipment_exercise_id ON exercise_equipment(exercise_id);
CREATE INDEX idx_exercise_equipment_category_id ON exercise_equipment(equipment_category_id);
```

Add unique constraints to prevent duplicates:
```sql
CREATE UNIQUE INDEX idx_exercise_body_part_unique ON exercise_body_part(exercise_id, body_part_category_id);
CREATE UNIQUE INDEX idx_exercise_equipment_unique ON exercise_equipment(exercise_id, equipment_category_id);
```

### 5. Update drop_schema.sql

Add these tables to the drop sequence (in reverse order):
```sql
DROP TABLE IF EXISTS exercise_equipment;
DROP TABLE IF EXISTS exercise_body_part;
DROP TABLE IF EXISTS equipment_category;
DROP TABLE IF EXISTS body_part_category;
```

## Usage Examples

### Query exercises by body part
```sql
SELECT e.*
FROM exercise e
JOIN exercise_body_part ebp ON e.id = ebp.exercise_id
JOIN body_part_category bpc ON ebp.body_part_category_id = bpc.id
WHERE bpc.name = 'chest';
```

### Query exercises by equipment type
```sql
SELECT e.*
FROM exercise e
JOIN exercise_equipment ee ON e.id = ee.exercise_id
JOIN equipment_category ec ON ee.equipment_category_id = ec.id
WHERE ec.name = 'Barbell';
```

### Add multiple categories to an exercise
```sql
-- Add body parts
INSERT INTO exercise_body_part (id, exercise_id, body_part_category_id)
VALUES ('app-...', 'usr-...', 'app-chest-id');

INSERT INTO exercise_body_part (id, exercise_id, body_part_category_id)
VALUES ('app-...', 'usr-...', 'app-shoulders-id');

-- Add equipment
INSERT INTO exercise_equipment (id, exercise_id, equipment_category_id)
VALUES ('app-...', 'usr-...', 'app-barbell-id');
```

## Benefits

1. **Flexibility**: Exercises can belong to multiple body parts (e.g., bench press = chest + shoulders)
2. **Flexibility**: Exercises can have multiple equipment types (e.g., a cable exercise could be both "Machine/Other" and "Cardio")
3. **Consistency**: Predefined categories ensure data consistency
4. **Extensibility**: Easy to add new categories without schema changes
5. **Query Power**: Easy to filter and search by any combination of categories
