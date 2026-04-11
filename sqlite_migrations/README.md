# sqlite_migrations/ — STALE

**This directory is historical and does not reflect the current schema.** Do not
apply these files to a database, and do not treat them as a migration chain.

## Status

The `create_*.sql` files here were the original table definitions from before the
project moved to:

- ULID primary keys (`TEXT PRIMARY KEY` with `app-` / `usr-` prefix + length CHECK)
- Category junction tables (`exercise_body_part`, `exercise_equipment`,
  `body_part_category`, `equipment_category`)
- `exercise_set.attempt_number`, `exercise_set_template.set_type`, `rest_time`,
  `duration`, and several other columns
- Cascade rules (`ON DELETE CASCADE` / `RESTRICT` / `SET NULL`) and FK indexes

None of those changes were back-ported here. Every file still declares
`id INTEGER PRIMARY KEY`, and some reference columns (`category`, `body_part`)
that no longer exist on their current owner tables.

## Source of truth

`sqlite/schema.sql` is the canonical schema. Seed data lives in
`sqlite/exercises_complete.sql` (library) and `sqlite/new-test-data.sql`
(templates + sessions). Dev-DB rebuild is driven by `sqlite/db.sh` and the
`Makefile` targets — none of them consult this directory.

## Going forward

When a real Go server lands and we need a forward-migration chain, the plan is
to either:

1. Retire this directory and start a fresh `migrations/` chain whose `0001_init.sql`
   matches `schema.sql` byte-for-byte, or
2. Generate migrations alongside `schema.sql` changes and enforce that the
   two stay in lockstep via a build step.

Until then, please treat these files as historical artifacts only.
