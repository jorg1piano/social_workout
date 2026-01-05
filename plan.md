# Social Workout - Project Plan

## Technology Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Go
- **Database:** SQLite (local), PostgreSQL (server)

## ULID Decision

### What are ULIDs?

ULIDs (Universally Unique Lexicographically Sortable Identifiers) are a modern alternative to UUIDs that provide chronological sortability while maintaining distributed generation capabilities.

**Format:** 26 characters in Crockford Base32 encoding
```
01HJGT8MNTV3X9P0A6Y7Z8C9D
|-------||---------------|
timestamp    randomness
(48 bits)    (80 bits)
```

**Project Prefix:** `app-`
```
app-01HJGT8MNTV3X9P0A6Y7Z8C9D
```

### Packages

- **Dart/Flutter:** https://pub.dev/packages/ulid
- **Go Backend:** https://github.com/oklog/ulid (v2)
  - Install: `go get github.com/oklog/ulid/v2`

### Compatibility

✅ **Fully Compatible** - Both packages implement the same ULID specification:
- Same format (26 characters)
- Same encoding (Crockford Base32)
- Interchangeable between Dart and Go
- Client can generate IDs that server accepts
- Perfect for offline-first architecture

### Performance Characteristics

**Projected Data (3 years, daily workouts):**
- Workouts: 1,095
- Total sets recorded: 32,850
- Database size: ~11-15 MB (vs 5 MB with INTEGER)
- Query overhead: +5-30ms on complex queries
- **User perception:** No difference (all under 100ms threshold)

### Benefits

1. **Chronologically Sortable**
   - `ORDER BY id` gives chronological order automatically
   - No separate `createdAt` needed for sorting
   - Efficient range queries by time

2. **Distributed ID Generation**
   - Client generates IDs offline
   - No server round-trip needed
   - No conflicts during sync
   - Perfect for offline-first mobile app

3. **Better Index Performance**
   - Sequential inserts (like auto-increment)
   - Less index fragmentation than UUID v4
   - Better locality in B-tree indexes

4. **Timestamp Extraction**
   - Can decode timestamp from ID alone
   - Useful for debugging and partitioning
   - First 10 characters encode milliseconds since epoch

5. **Server-Friendly**
   - No ID collision risk across devices
   - URL-safe (no special characters)
   - Case-insensitive
   - Compact (28% smaller than UUID v4)

### Schema Impact

**Database Changes:**
- All `id` columns: `INTEGER PRIMARY KEY` → `TEXT PRIMARY KEY`
- All foreign keys: `INTEGER` → `TEXT`
- Add validation: `CHECK(id LIKE 'app-%')`
- Index performance: Still excellent (sequential inserts)

**Example:**
```sql
-- Before
CREATE TABLE workout (
  id INTEGER PRIMARY KEY NOT NULL,
  ...
);

-- After
CREATE TABLE workout (
  id TEXT PRIMARY KEY NOT NULL CHECK(id LIKE 'app-%'),
  ...
);
```

### Trade-offs

**Advantages:**
- ✅ Offline-first architecture support
- ✅ Chronological sorting built-in
- ✅ Server sync without conflicts
- ✅ Better than UUID v4 for indexes

**Cost:**
- ⚠️ 2-3x larger database (~10 MB extra over 3 years)
- ⚠️ 2-4x slower queries (still <50ms, imperceptible)
- ⚠️ Slightly more storage than INTEGER (but negligible on modern devices)

**Verdict:** Worth it for distributed, offline-first architecture with server sync.

## Database Schema

See `database_schema_review.md` for detailed schema analysis and `sqlite/schema.sql` for the current implementation.

### Key Tables

- `workout_template` - Workout plans (Push/Pull/Legs)
- `exercise` - Exercise library (Bench Press, Squats, etc.)
- `exercise_for_workout_template` - Links exercises to templates
- `exercise_set_template` - Planned sets for templates
- `workout` - Actual workout sessions
- `exercise_set` - Actual sets performed

### Schema Enhancements

- ✅ Added timestamps (`createdAt`, `updatedAt`) to all tables
- ✅ Added `restTime` field to set templates and actual sets
- ✅ Added indexes on all foreign keys
- ✅ Fixed typos (INTENGER → INTEGER)
- ✅ Added missing fields (weight, ordering, notes)

## Next Steps

1. Implement ULID generation in Flutter app
2. Update schema to use TEXT PRIMARY KEYS
3. Implement Go backend with ULID support
4. Design sync protocol between client and server
5. Implement offline-first data layer
