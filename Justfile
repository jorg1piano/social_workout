set shell := ["bash", "-uc"]

DB := "sqlite/test-db.db"
ULID := "tools/generate_ulid/ulid"

# List all recipes
default:
    @just --list

# Rebuild test-db.db with schema only
db-fresh:
    ./sqlite/test-db.sh

# Rebuild test-db.db with schema + exercises_complete.sql seed
db:
    ./sqlite/db.sh

# Rebuild the dev DB and load randomized test workouts
db-with-test-data:
    ./sqlite/db.sh
    sqlite3 {{DB}} < sqlite/new-test-data.sql

# Re-insert seed data into the existing dev DB
test-data:
    sqlite3 {{DB}} < sqlite/new-test-data.sql

# Regenerate the randomized test-data SQL file
gen-test-data:
    ./sqlite/generate-new-test-data.sh

# Open the dev DB in sqlite3
shell:
    sqlite3 {{DB}}

# Dump the current dev DB schema
schema-dump:
    sqlite3 {{DB}} .schema

# Show all tables in the dev DB
tables:
    sqlite3 {{DB}} .tables

# Build the Go ULID generator
build-ulid:
    cd tools/generate_ulid && go build -o ulid .

# Generate a single ULID with the `app-` prefix
ulid:
    ./{{ULID}} generate

# Regenerate exercise mappings (TypeScript tool)
gen-mappings:
    cd tools/generate_mappings && npm install && npx ts-node generate-exercise-mappings.ts

# Delete the dev DB
db-clean:
    rm -f {{DB}}

# Nuke the dev DB and rebuild from scratch with seed data
db-reset: db-clean db
