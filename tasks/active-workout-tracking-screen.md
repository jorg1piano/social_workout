# Task: Active Workout Tracking Screen (SQLite-backed)

## Goal

Validate the SQLite schema in `sqlite/schema.sql` end-to-end by shipping a
real Hevy-style **active-workout tracking screen** in `mobile/` that
round-trips through the actual data layer. Every observable behavior in the
UI — set completion, rep edits, swap, finish, the Previous column — must be
backed by an `INSERT` / `UPDATE` you can read back with `sqlite3` against the
on-device DB. The bar for this task is not "the screen looks right" — it's
"a value typed in workout 1 shows up in the Previous column of workout 2
after force-stop and relaunch."

This replaces the earlier in-memory `in-workout-swap-exercise-screen` task.
That earlier task shipped a fixture-only screen against a hardcoded
`Workout` object; this task throws the fixture away and runs against a real
sqflite database seeded from the canonical schema and exercise catalog.

## Data layer

- **Package**: `sqflite` (not `drift`). Hand-written DAOs, no codegen.
- **Schema parity**: `mobile/assets/sqlite/schema.sql` is a **byte-equal
  copy** of `sqlite/schema.sql`. A `just copy-schema` recipe in the repo
  root copies the canonical schema into the Flutter assets bundle so the
  two cannot drift; CI / local dev should run it before any DB-touching
  change.
- **Bootstrap**: `lib/data/db/bootstrap.dart` loads three SQL assets via
  `rootBundle.loadString` on first open and runs them inside a transaction:
  1. `assets/sqlite/schema.sql` — full DDL
  2. `assets/sqlite/exercises_complete.sql` — 209-row canonical exercise catalog
  3. `assets/sqlite/new-test-data.sql` — Push Day template + variants + an
     in-progress workout shell
- **Database open**:
  - `AppDatabase.openAndInitialize()` — production path; resolves the
    on-device `social_workout.db` under the app documents dir.
  - `AppDatabase.openAt(String dbPath)` — factored out for tests; the
    widget tests pass `inMemoryDatabasePath`.
  - `onConfigure` runs `PRAGMA foreign_keys = ON` (sqflite ships with FKs
    **off** — schema CHECKs and FK constraints would silently no-op
    otherwise).
  - `onCreate` runs the bootstrap inside the same `Database` handle.
  - Migration tracking via `PRAGMA user_version`; first version pinned at
    `1`. No migration runner yet — we'll grow one when the schema actually
    changes.

## Data model (Dart)

`lib/data/models/` — six row-shape classes plus the shared enum, all
hand-written and aligned to schema column names exactly (no `started_at`
vs `start_time` drift):

| File                                       | Mirrors                                |
|--------------------------------------------|----------------------------------------|
| `db_workout_template.dart`                 | `workout_template`                     |
| `db_workout.dart`                          | `workout`                              |
| `db_exercise.dart`                         | `exercise`                             |
| `db_exercise_for_workout_template.dart`    | `exercise_for_workout_template`        |
| `db_exercise_set_template.dart`            | `exercise_set_template`                |
| `db_exercise_set.dart`                     | `exercise_set`                         |
| `set_type.dart`                            | `SetType` enum (`warmup` / `regularSet` / `dropSet` / `failure`) |

`lib/data/dao/` — three DAOs partition reads/writes by aggregate:

- `template_dao.dart` — workout templates, slots, set templates
- `exercise_dao.dart` — exercise catalog lookups
- `workout_dao.dart` — workout lifecycle, set inserts/updates/deletes,
  swap-aware preservation logic

ULIDs are generated client-side via `lib/data/db/ulid.dart` with the
`app-` prefix; the `26` Crockford-Base32 chars + `app-` = `30` total
matches the schema `CHECK (length(id) = 30)`.

## Screen behavior

Single screen for now: `lib/features/active_workout/active_workout_screen.dart`,
backed by `active_workout_controller.dart`. The controller resolves the
template, finds-or-creates an in-progress workout, picks the current
variant per slot (defaulting to `exercise_index = 0` unless another
variant already has rows in this workout), and exposes the data the
screen needs.

### Top bar
- Left: small back-circle (no-op for this task).
- Center: elapsed-time placeholder (`0:00` static).
- Right: green **Finish** pill that stamps `workout.stop_time = unixepoch('now')`.

### Workout header
- Lowercase bold workout title (e.g. **"push day"**).
- Calendar row + clock row beneath.

### Exercise cards (one per slot, in `ordering`)
- **Exercise name** in blue.
- **Swap pill** (`Icons.swap_horiz` in a tinted rounded container) — only
  rendered when the slot has more than one variant in
  `exercise_for_workout_template`.
- **Set table** with columns: `Set` / `Previous` / `kg` / `Reps` / `✓`
  - `Set` — working-set number; non-`regularSet` rows show a letter badge
    instead: orange `W` for `warmup`, purple `D` for `dropSet`, red `F`
    for `failure`. All three badge styles live in `AppStyle`.
  - `Previous` — the most-recent prior `exercise_set` for this exercise
    in any earlier workout, formatted by `AppStyle.formatWeightDisplay`
    (em dash for null, `bw` for zero, `12,5 kg` for positive, `15 kg (−)`
    for negative/assistance).
  - `kg` / `Reps` — editable input pills, commit on focus loss or on
    `✓` tap (the check tap calls `_commit()` first to flush any pending
    edit before flipping `is_completed`).
  - `✓` — round check cell that toggles `is_completed`.
- **`+ Add Set`** — appends a new `exercise_set` with NULL `weight` /
  `rep_count` and `is_completed = 0`.
- **Set cell is tappable** — opens a bottom sheet picker to change the
  row's `set_type` to any of `warmup` / `regularSet` / `dropSet` /
  `failure`. The picker rows are intent-ordered (Warm-up → Regular →
  Drop set → Failure), the current row is marked with a checkmark, and
  selecting the same type closes the sheet without a DB write. On a
  different selection the controller calls `WorkoutDao.updateSetType`
  and re-reads the slot, so the badge re-renders from disk and the
  working-set numbering re-derives automatically. Numbering counts
  every non-warmup row, so converting `regularSet → dropSet` keeps the
  rows below it numbered the same — drop sets and failure sets are
  intensity modifiers on top of the working progression, not position
  takers. Same `_commit()`-before-open discipline as the `✓` tap.

### Swap interaction
Tapping the swap pill opens a bottom sheet listing every variant for that
slot. Tapping a **different** variant calls
`workout_dao.swapVariant(...)`, which:

1. **Deletes incomplete sets** (`is_completed = 0`) for the slot's current
   `exercise_for_workout_template_id`.
2. **Preserves completed sets** — they remain in the workout under the old
   `exercise_for_workout_template_id`, so the historical record stays
   accurate.
3. **Preloads** the new variant's `exercise_set_template` rows into
   `exercise_set` if the new variant has no rows yet in this workout.

The result: a swapped workout ends up with two `exercise_for_workout_template_id`
values for the same slot, distinguished by which one has completed rows.
This is exactly the schema's intent — no audit table, no `swap_history`,
just multiple variants co-existing in the same workout.

## Schema findings folded back into the project

While building this task we hit four issues that required upstream changes
or documentation, and they should be linked from this spec for future
context:

- **Task A — Push Day seed filled.** The seeded Push Day template was
  missing the variants needed to exercise this screen. Lateral Raise,
  Triceps Pushdown, and Triceps Dip rows were added to
  `sqlite/new-test-data.sql` so the four-card render test has real data.
- **Task B — `sqlite_migrations/` README staleness notice.** The README
  in `sqlite_migrations/` predated the consolidated schema and was
  flagged as stale. Future migration work should write `ALTER TABLE`
  files there, not edit `schema.sql` directly.
- **Task C — `set_type` added to `exercise_set`.** A real schema gap
  caught by the build: warmup vs working classification lived only on
  `exercise_set_template`, so a logged set lost the distinction. Added
  `set_type TEXT NOT NULL CHECK (set_type IN ('warmup','working'))` to
  `exercise_set` and to the seed inserts. The Dart `SetType` enum lives
  in `lib/data/models/set_type.dart`.
- **Task D — Weight sign convention documented.**
  `exercise_set.weight` is `DECIMAL(5,2)` and **signed**:
  `null` = no value, `0` = bodyweight (e.g. push-up), `> 0` = added load
  (`12,5 kg`), `< 0` = assistance (assisted chin-up, `15 kg (−)`). This
  was documented in the schema and folded into
  `AppStyle.formatWeightDisplay` so the Previous column renders all four
  cases sign-correctly from day one — no retrofit when the assisted-pulldown
  screen lands.

## Acceptance criteria

All thirteen verified on the Pixel 3a API 34 emulator (`emulator-5554`)
with screenshot + `sqlite3` evidence captured during the AC sweep.

- [x] **AC #1 — DB lifecycle.** First launch creates `social_workout.db`
      under the app docs dir; `PRAGMA user_version` reads `1`; row counts
      after bootstrap are `exercise=209`, `workout_template=3`, `workout=1`
      (the seeded in-progress shell).
- [x] **AC #2 — Top bar renders.** Back circle / `0:00` / Finish pill all
      visible and styled via `AppStyle`.
- [x] **AC #3 — Header renders.** Lowercase **"push day"**, calendar row,
      clock row.
- [x] **AC #4 — Four cards in `ordering` order.** Bench Press, Overhead
      Press, Lateral Raise, Triceps Pushdown — verified across three
      scroll screenshots.
- [x] **AC #5 — Swap pills only on multi-variant slots.** Slots 1
      (Bench Press ↔ Incline Bench Press) and 4 (Triceps Pushdown ↔
      Triceps Dip) show the pill; slots 2 (Overhead Press) and 3 (Lateral
      Raise) do not.
- [x] **AC #6 — Reps edits persist across relaunch.** Edited a working
      set's reps from `8` → `108`, `am force-stop`'d the app, relaunched,
      saw `108` re-rendered. SQL: `rep_count = 108` survived.
- [x] **AC #7 — `✓` toggle persists.** Tapped the check, killed the app,
      relaunched, saw the row still flooded green. SQL: `is_completed = 1`.
- [x] **AC #8 — `+ Add Set` persists.** New row written with NULL
      `weight` / `rep_count` and `is_completed = 0`; survives relaunch.
- [x] **AC #9 — Swap preserves completed, drops incomplete.** With two
      Bench Press rows completed (warmup + set 1 with the edited
      `rep_count = 108`) and three incomplete, swapped to Incline Bench
      Press: the two completed rows remain in the workout under the old
      `exercise_for_workout_template_id`; the three incomplete rows are
      gone; three fresh Incline Bench Press rows are created from its
      template. Verified by SQL grouping on
      `exercise_for_workout_template_id`.
- [x] **AC #10 — Finish stamps `stop_time`.** Tapping Finish set
      `workout.stop_time` from `NULL` to a unix epoch.
- [x] **AC #11 — Round-trip into Previous column.** After Finish +
      relaunch, a fresh in-progress workout was auto-created. Its Bench
      Press card's Previous column renders **`185 kg × 108`** — the
      exact value edited in the previous workout. This is the whole
      reason the task exists.
- [x] **AC #12 — Tooling green.** `flutter analyze` clean, no suppressed
      lints; `flutter test` 3/3 green (renders all four cards / swap /
      add set).
- [x] **AC #13 — Styling discipline.** Zero hardcoded colors / paddings /
      text styles in widget code — everything routes through `AppStyle`,
      including the new `formatWeightDisplay` formatter.
- [x] **AC #14 — Set cell tap-to-change persists.** Tapping a Set cell
      opens the picker; selecting a different type (`regularSet → dropSet`
      verified on Bench Press set 2 on `emulator-5554`) writes
      `exercise_set.set_type` via `WorkoutDao.updateSetType`, re-renders
      the row badge from disk, and survives `am force-stop` + relaunch.
      Widget test `tap Set cell on Bench Press set 2 opens type sheet,
      selecting Failure persists set_type to disk` covers the path
      end-to-end, including a `runAsync`-wrapped `WorkoutDao.getSet`
      assertion against the on-disk row.

## Visual style

Hevy-inspired chrome — top bar layout, lowercase bold title, blue
exercise-name links, swap pill, set table layout, Add Set affordance,
green Finish pill. Reference screenshot:
`/Users/jorgen/Downloads/Screenshot 2026-04-11 at 10.30.30.jpeg`. All
colors / paddings / text styles defined as constants in
`lib/style/app_style.dart`.

## Known limitations / follow-up

- **G3 — every `exercise_set` must belong to a template slot.** The
  schema requires `exercise_set.exercise_for_workout_template_id` to be
  non-null, so adding "an exercise that isn't in this template" would
  require mutating the template first. Not a bug — a constraint to
  document. A future "ad-hoc exercise" feature will need a template
  mutation step (or a synthetic `ad-hoc` slot).
- **Android package id** is `no.devda.workout`, not the Flutter
  `com.example.workout` default. Any future `adb` / `am` commands should
  use the real id.
- **Schema column naming**: it's `workout.stop_time`, not `ended_at`;
  `exercise_set.rep_count`, not `reps`. Future briefs will use the
  schema names; trust the schema, not the brief.
- **Swap → swap-back loses pre-swap incomplete edits.** By design: the
  swap path deletes incomplete rows for the outgoing variant, which is
  correct for data hygiene (no orphan incomplete rows for an exercise
  the user moved away from). The side effect is that swapping back
  doesn't restore the prior incomplete state — it preloads fresh
  template rows. Document, don't fix.
- **No real timer**, no back-button behavior, no workout-list / picker
  screen, no networking / sync / gRPC. The active workout screen is
  still the app's home route.
- **State management**: still vanilla `setState` + a controller class.
  Riverpod / Bloc are not warranted at this surface area; revisit when
  there's a second screen sharing state.
