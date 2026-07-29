# Social Workout — iOS (SwiftUI)

A native iOS app implementing the plan-vs-record data model from
`sqlite/schema.sql`. It is the same ground the Go
[model explorer](../prototypes/model-explorer) covers — build the plan, run it,
keep the record — as an app you can actually train with.

No third-party dependencies: SwiftUI, and the system `libsqlite3` behind a thin
wrapper.

## Run

```bash
just ios-run        # build + launch on a booted simulator
just ios-test       # unit + UI tests
just ios-open       # open in Xcode
```

Or directly:

```bash
cd ios
xcodebuild -scheme SocialWorkout -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Requires Xcode 16 or newer (the project uses file-system-synchronized groups, so
files added under `SocialWorkout/` are picked up without editing the project).

## The canonical SQL is not copied

The Xcode project references `../sqlite/schema.sql`,
`../sqlite/exercises_complete.sql` and `../sqlite/new-test-data.sql` **directly**
as bundle resources. There is no `ios/` copy of the schema and therefore no
parity check to run and no drift to police — unlike `mobile/`, where Flutter
requires assets to live inside the package (`just copy-schema`).

On first launch the app creates its store in Application Support and runs those
three scripts, in order, in one transaction. Wipe and re-seed at any time from
the ••• menu on the Exercises tab ("Reset to seed data"), the app's equivalent of
`just web-reset`.

## What's implemented

The four tabs follow the two trees in the model.

- **Exercises** — the shared `exercise` definitions, searchable, with body part
  and equipment tags. Add your own (minted `usr-`), rename any of them and watch
  the new name appear in history too. Per-exercise stats — sessions, completed
  sets, heaviest set, last performed — are aggregated across every workout by
  joining through `workout_exercise`, never through a template.

- **Plans** `PLAN` — `workout_template`s laid out along the three ordering axes:
  blocks (a block with more than one leg is a superset), legs within a block, and
  swap variants within a leg (`exercise_index` 0 = default, 1+ = alternates). Add
  an exercise as its own block, as a superset partner, or as a swap option; the
  sheet speaks in those terms and derives the `(block, within, index)` triple
  itself. Attach planned sets, archive variants, archive or hard-delete the plan.

- **Run** — pick one variant per slot (defaults preselected, archived hidden, any
  slot skippable) and start. That resolves the plan into the record: a `workout`,
  one `workout_exercise` per pick carrying the exercise and this session's order
  plus a severable `source_variant_id`, and the planned sets materialized as
  not-yet-completed `exercise_set` rows. Then log: edit reps and weight, tick
  sets off, append ad-hoc sets, or log a second attempt at the same set number
  (rest-pause, a missed lift). A "last time" line shows what you did the previous
  session — found by exercise across all workouts.

- **History** `RECORD` — sessions rendered purely from
  `workout → workout_exercise → exercise_set`, with no template join anywhere.
  Each session ends with a provenance line reading "intact" or "severed": delete
  the plan in the Plans tab and come back to see the record read identically with
  the pointer nulled out.

## Layout

```
SocialWorkout/
  App/     SocialWorkoutApp.swift  — entry point, database open, -resetStore flag
           AppModel.swift          — repository + error + change-notification
  Data/    ULID.swift              — app-/usr- prefixed, monotonic, Crockford32
           SQLiteDatabase.swift    — libsqlite3 wrapper, FK enforcement, tx
           AppDatabase.swift       — store location, first-run bootstrap, reset
           Models.swift            — plan types and record types, split apart
           WorkoutRepository.swift — every query, mirroring the explorer's API
  Views/   one file per screen, plus Theme.swift for the plan/record palette
SocialWorkoutTests/      model invariants through the repository (27 tests)
SocialWorkoutUITests/    the plan → session → record flow, driven for real
```

`WorkoutRepository` deliberately mirrors the endpoints in
`prototypes/model-explorer/handlers.go`, so the Swift and Go implementations can
be read side by side.

## Notes / gotchas

- **Foreign keys are off by default in SQLite**, per connection. `SQLiteDatabase`
  turns them on at open; without that, cascade-on-delete and the SET NULL
  provenance behaviour silently stop happening.
- **Constraint violations are shown to the user, not swallowed.** The plan tree
  enforces its rules with unique indexes (`idx_variant`, `idx_variant_exercise`,
  `idx_exercise_set_attempt`), so "that slot is taken" arrives as a legible
  alert — the same distinction the explorer draws by answering 409 rather than
  500.
- **IDs are minted in Swift**, never in SQL, so every row gets an `app-`/`usr-`
  ULID that sorts chronologically and can be generated offline.
- **List section headers are uppercased by SwiftUI**, which is why UI tests match
  header text case-insensitively.
- The database is used synchronously on the main thread. For a single-user local
  store of a few thousand rows every query is sub-millisecond; the one slow
  operation, first-run seeding, happens behind the launch screen.
