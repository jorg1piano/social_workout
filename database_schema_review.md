# Database Schema Review

## Overview
This document captures the review and analysis of the SQLite database schema for the workout tracking application.

## Schema Strengths
- **Good separation between templates and sessions** - Clear distinction between planned workouts (templates) and actual workout sessions
- **Proper foreign key relationships** - Maintains referential integrity across tables with cascade rules
- **Template-based workouts** - Supports reusable workout plans that can be instantiated multiple times
- **Swappable exercises** - The `exercise_index` field allows for exercise variations within the same slot
  - **IMPORTANT**: `exercise_index` is scoped per ordering slot, not globally. Multiple exercises can share the same exercise_index if they have different ordering values. For example, ordering=1, exercise_index=0 (Barbell Bench) and ordering=2, exercise_index=0 (Barbell OHP) can both exist.
- **Dual tracking** - Tracks both planned sets (template) and actual sets (session)
- **Template comparison** - The `exercise_for_workout_template_id` FK enables comparing actual performance against planned template
- **Unique constraint enforcement** - Composite unique index on (workout_template_id, ordering, exercise_index) prevents duplicate variants
- **Comprehensive indexing** - All foreign keys indexed for query performance
- **Audit trails** - All tables include created_at and updated_at timestamps
- **ULID-based IDs** - Chronologically sortable, distributed generation support for offline-first architecture

## Issues to Fix

### ✅ Completed (as of current schema)
1. ✅ **Added `weight` field to `exercise_set` table** - Now `weight DECIMAL(5,2)`
2. ✅ **Fixed typos** - All INTEGER types corrected
3. ✅ **`is_completed` field** - Now `is_completed INTEGER DEFAULT 0 NOT NULL`
4. ✅ **`ordering` field in `exercise_set`** - Added as `ordering INTEGER`
5. ✅ **Session notes field** - Added `notes TEXT` to `exercise_set`
6. ✅ **Indexes added** - All foreign keys have indexes
7. ✅ **Timestamps added** - All tables have `created_at` and `updated_at`
8. ✅ **`rest_time` field added** - Both templates and actual sets
9. ✅ **NOT NULL constraints** - Added to `name` fields and `ordering` in `exercise_for_workout_template`
10. ✅ **Foreign key cascade rules** - Proper ON DELETE behavior defined
11. ✅ **Unique constraint** - Composite index on (workout_template_id, ordering, exercise_index)

### Remaining Considerations
None critical - schema is production-ready for MVP

## Suggestions for Future Enhancement

### ✅ Completed
- ✅ Indexes on foreign key columns
- ✅ Composite unique index on exercise variants
- ✅ `created_at` and `updated_at` timestamp fields
- ✅ `rest_time` field in both templates and actual sets
- ✅ All column names converted to snake_case (industry standard)

### Potential Future Features
- `exercise_variation` field (e.g., "wide grip", "close grip") - could be added to `exercise_for_workout_template.notes` for now
- Soft delete flags instead of hard deletes
- User/profile table for multi-user support
- Unit validation CHECK constraint (kg/lbs/bodyweight)
- Exercise categories/tags for better filtering

## Action Items

### ✅ Completed
- [x] Fix typo: Change `INTENGER` to `INTEGER` in exercise_set and exercise_for_workout_template
- [x] Add `weight DECIMAL(5,2)` to exercise_set table
- [x] Add `is_completed INTEGER DEFAULT 0 NOT NULL` to exercise_set
- [x] Add `ordering INTEGER` to exercise_set table
- [x] Add `notes TEXT` to exercise_set table
- [x] Add indexes on all foreign key columns
- [x] Add `created_at` and `updated_at` timestamp fields to all tables
- [x] Add `rest_time` fields to set templates and actual sets
- [x] Add NOT NULL constraints to name fields
- [x] Add NOT NULL to ordering in exercise_for_workout_template
- [x] Add foreign key cascade rules (ON DELETE CASCADE/RESTRICT/SET NULL)
- [x] Add composite unique index on (workout_template_id, ordering, exercise_index)
- [x] Add comprehensive schema documentation
- [x] Convert all column names to snake_case (industry standard)

### Future Considerations
- [ ] Design multi-user support (user/profile tables)
- [ ] Add soft delete functionality
- [ ] Add unit validation CHECK constraint
- [ ] Add data migration strategy for schema updates
- [ ] Document expected query patterns for progressive overload tracking

## Design Decisions

### How does `exercise_index` work?
`exercise_index` is **scoped per ordering slot**, not globally across the template:

**Example:**
```
Template: "Push Day"
├─ ordering=1, exercise_index=0, exercise="Barbell Bench Press"
├─ ordering=1, exercise_index=1, exercise="Dumbbell Bench Press"
├─ ordering=1, exercise_index=2, exercise="Machine Chest Press"
├─ ordering=2, exercise_index=0, exercise="Barbell OHP"    ← Same index (0) as above
├─ ordering=2, exercise_index=1, exercise="Dumbbell OHP"   ← Same index (1) as above
└─ ordering=3, exercise_index=0, exercise="Tricep Dips"
```

**Key Point:** exercise_index=0 can appear multiple times (once per ordering value). The unique constraint is on the **composite** (workout_template_id, ordering, exercise_index), not on exercise_index alone.

**Use Case:** User picks one variant per slot:
- Slot 1 (ordering=1): Choose exercise_index=1 (Dumbbells today)
- Slot 2 (ordering=2): Choose exercise_index=0 (Barbell OHP)
- Slot 3 (ordering=3): Only exercise_index=0 available

### Why keep `exercise_for_workout_template_id`?
Despite being able to query by `exercise_id` alone, we keep this FK because:
- Enables direct comparison between template and actual performance
- Preserves workout structure when same exercise appears multiple times
- Allows UI to show "planned vs actual" side-by-side
- Makes it easier to track workout template completion
- **Critical for variant tracking**: Records which exercise_index was chosen during the workout

### Why track both `exercise_id` and `exercise_for_workout_template_id`?
- `exercise_id` - What exercise was performed (e.g., "Bench Press")
- `exercise_for_workout_template_id` - Which specific instance in the workout template (e.g., "First bench press block" vs "Second bench press block") AND which variant was chosen (barbell vs dumbbell)
