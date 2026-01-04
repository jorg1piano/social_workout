# Database Schema Review

## Overview
This document captures the review and analysis of the SQLite database schema for the workout tracking application.

## Schema Strengths
- **Good separation between templates and sessions** - Clear distinction between planned workouts (templates) and actual workout sessions
- **Proper foreign key relationships** - Maintains referential integrity across tables
- **Template-based workouts** - Supports reusable workout plans that can be instantiated multiple times
- **Swappable exercises** - The `exerciseIndex` field allows for exercise variations within the same slot
- **Dual tracking** - Tracks both planned sets (template) and actual sets (session)
- **Template comparison** - The `exerciseForWorkoutTemplateId` FK enables comparing actual performance against planned template

## Issues to Fix

### Critical
1. **Missing `weight` field in `exercise_set` table**
   - Currently has a TODO comment
   - This is essential for tracking actual weight performed
   - Should be: `weight DECIMAL(5,2)`

2. **Typo: `INTENGER` should be `INTEGER`**
   - `exercise_set.workoutId`
   - `exercise_for_workout_template.workoutTemplateId`

### Data Type Consistency
3. **`isCompleted` field in `exercise_set`**
   - Currently: `isCompleted INTEGER`
   - Should be: `isCompleted INTEGER DEFAULT 0 NOT NULL`

### Missing Fields
4. **`ordering` field in `exercise_set`**
   - Present in templates but missing in actual sets
   - Needed if users can reorder sets during a workout
   - Add: `ordering INTEGER`

5. **Session notes field in `exercise_set`**
   - Templates have notes, but actual sets don't
   - Add: `notes TEXT` to capture session-specific observations

## Suggestions for Future Enhancement

### Performance
- Add indexes on foreign key columns for faster queries
- Consider composite indexes for common query patterns

### Audit Trail
- Add `createdAt` timestamp fields
- Add `updatedAt` timestamp fields
- Helps with progressive overload tracking and data debugging

### Additional Features
- `restTime` field in `exercise_set_template` and `exercise_set`
- `exerciseVariation` field (e.g., "wide grip", "close grip")
- Soft delete flags instead of hard deletes
- User/profile table for multi-user support

## Action Items

### Immediate (Required for MVP)
- [ ] Fix typo: Change `INTENGER` to `INTEGER` in exercise_set and exercise_for_workout_template
- [ ] Add `weight DECIMAL(5,2)` to exercise_set table
- [ ] Add `isCompleted INTEGER DEFAULT 0 NOT NULL` to exercise_set (update existing definition)
- [ ] Add `ordering INTEGER` to exercise_set table
- [ ] Add `notes TEXT` to exercise_set table

### Short-term (Nice to have)
- [ ] Add indexes on all foreign key columns
- [ ] Add `createdAt` and `updatedAt` timestamp fields to all tables
- [ ] Consider adding `restTime` fields to set templates and actual sets
- [ ] Document expected query patterns for progressive overload tracking

### Long-term (Future features)
- [ ] Design multi-user support (user/profile tables)
- [ ] Add soft delete functionality
- [ ] Consider exercise variation tracking
- [ ] Add data migration strategy for schema updates

## Design Decisions

### Why keep `exerciseForWorkoutTemplateId`?
Despite being able to query by `exerciseId` alone, we keep this FK because:
- Enables direct comparison between template and actual performance
- Preserves workout structure when same exercise appears multiple times
- Allows UI to show "planned vs actual" side-by-side
- Makes it easier to track workout template completion

### Why track both `exerciseId` and `exerciseForWorkoutTemplateId`?
- `exerciseId` - What exercise was performed (e.g., "Bench Press")
- `exerciseForWorkoutTemplateId` - Which specific instance in the workout template (e.g., "First bench press block" vs "Second bench press block")
