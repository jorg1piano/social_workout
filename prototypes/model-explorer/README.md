# Model explorer (Go web app)

A tiny web app for *feeling out* the plan-vs-record data model in
`sqlite/schema.sql`. It is a concept explorer, not production code: single user,
single SQLite file, no auth.

## Run

```bash
just web            # http://localhost:8080
# or:
cd prototypes/model-explorer && go run . -sqlite-dir ../../sqlite
```

On first run it creates `app.db` next to the source and bootstraps it from the **canonical**
`sqlite/schema.sql` + `sqlite/exercises_complete.sql`, so the app always reflects
the real schema. `just web-reset` wipes the DB to re-bootstrap fresh.

Flags: `-addr :8080`, `-db app.db`, `-sqlite-dir ../../sqlite`.

## What it demonstrates

The UI has four tabs that map onto the two trees in the model:

- **Exercises** — the shared `exercise` definitions (renames propagate).
- **Plans** (`plan`) — build `workout_template`s: add exercises into
  `(block, within, exercise_index)` slots. `within > 1` in a block = a superset;
  `exercise_index > 0` = a swap alternate for that slot. Attach planned sets
  (`exercise_set_template`).
- **Run a session** — pick one variant per slot; the server resolves the plan
  into the **record**: a `workout`, one `workout_exercise` per pick (carrying
  `exercise_id`, block/within order, and a `source_variant_id` provenance
  pointer), and the planned sets materialized as not-yet-completed
  `exercise_set` rows to fill in.
- **History** (`record`) — renders a session purely from
  `workout → workout_exercise → exercise_set`, with **no template join**. Hard-
  delete the source template and it still reads back identically, with
  provenance nulled out — the self-documenting guarantee, live.

## Layout

- `main.go`   — flags, routing (Go 1.22 `net/http` method+wildcard mux), embeds `static/`.
- `db.go`     — connection (foreign keys ON per DSN), first-run bootstrap, `newID()` (app- ULID).
- `handlers.go` — JSON REST handlers for the endpoints above.
- `static/index.html` — single-page vanilla-JS frontend.

## Notes / gotchas

- Foreign keys are enabled via the DSN pragma (`_pragma=foreign_keys(1)`) so
  every pooled connection enforces them — SQLite defaults them **off**.
- The pool is capped at one connection, so handlers **fully scan a parent
  result set before** issuing per-row child queries; nesting a child query
  inside an open parent iterator would deadlock the single connection.
- All IDs are minted through `newID()` (`app-` + ULID) — never hand-rolled in SQL.
