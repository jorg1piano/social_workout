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

# Re-insert seed data into the existing dev DB
test-data:
    sqlite3 {{DB}} < sqlite/new-test-data.sql

# Regenerate the randomized test-data SQL file
gen-test-data:
    ./sqlite/generate-new-test-data.sh

# Run the SQL-level model stress tests (plan-vs-record invariants).
# Builds fresh DBs from schema.sql + tests/fixtures.sql, FK enforcement on.
test-model:
    ./sqlite/tests/run.sh

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

# ---------- Prototype: model explorer web app ----------

# Run the Go web app that explores the plan-vs-record model. Bootstraps its own
# app.db from sqlite/schema.sql + exercises_complete.sql on first run, then
# serves a UI on http://localhost:8080 to build plans and run/record sessions.
web:
    cd prototypes/model-explorer && go run . -sqlite-dir ../../sqlite

# Build the model-explorer binary.
web-build:
    cd prototypes/model-explorer && go build -o model-explorer .

# Wipe the explorer's local DB so it re-bootstraps fresh from sqlite/.
web-reset:
    rm -f prototypes/model-explorer/app.db prototypes/model-explorer/app.db-*

# ---------- Mobile ----------

# Copy canonical SQL into mobile/assets/sqlite/ so the Flutter app boots
# from the same schema + seed data as the model explorer. Run this any time
# sqlite/schema.sql, exercises_complete.sql, or new-test-data.sql changes.
copy-schema:
    @mkdir -p mobile/assets/sqlite
    @cp sqlite/schema.sql mobile/assets/sqlite/schema.sql
    @cp sqlite/exercises_complete.sql mobile/assets/sqlite/exercises_complete.sql
    @cp sqlite/new-test-data.sql mobile/assets/sqlite/new-test-data.sql
    @echo "mobile assets synced: schema + exercises + test data"

# Byte-exact parity check between canonical SQL and the mobile asset copies.
# Exits non-zero on drift so CI / pre-commit can gate on it.
check-schema-parity:
    @cmp sqlite/schema.sql mobile/assets/sqlite/schema.sql \
        && cmp sqlite/exercises_complete.sql mobile/assets/sqlite/exercises_complete.sql \
        && cmp sqlite/new-test-data.sql mobile/assets/sqlite/new-test-data.sql \
        && echo "mobile assets in parity with sqlite/"

# Sync canon + run the Flutter app against the first attached device. Use
# this instead of `flutter run` so the assets are always fresh.
mobile-run: copy-schema
    cd mobile && flutter run

# Static analysis for the mobile app. Runs `flutter analyze`; fails on any
# warning so lint regressions block PRs.
mobile-analyze:
    cd mobile && flutter analyze

# Widget + unit tests for the mobile app.
mobile-test:
    cd mobile && flutter test

# ---------- iOS (native SwiftUI) ----------
#
# The Xcode project references sqlite/*.sql directly as bundle resources, so
# there is no copy step and no parity check to run — unlike `copy-schema` above,
# which exists only because Flutter requires assets inside the package.

IOS_SIM := "platform=iOS Simulator,name=iPhone 16 Pro"

# Build the native iOS app for the simulator.
ios-build:
    cd ios && xcodebuild -scheme SocialWorkout -destination '{{IOS_SIM}}' build

# Unit tests (model invariants) + UI tests (the plan -> session -> record flow).
ios-test:
    cd ios && xcodebuild -scheme SocialWorkout -destination '{{IOS_SIM}}' test

# Build, install and launch on the booted simulator. Boots one if needed.
ios-run:
    #!/usr/bin/env bash
    set -euo pipefail
    cd ios
    if ! xcrun simctl list devices booted | grep -q iPhone; then
        xcrun simctl boot 'iPhone 16 Pro'
        open -a Simulator
    fi
    xcodebuild -scheme SocialWorkout -destination '{{IOS_SIM}}' \
        -derivedDataPath build build
    xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/SocialWorkout.app
    xcrun simctl launch booted no.devda.socialworkout

# Open the iOS project in Xcode.
ios-open:
    open ios/SocialWorkout.xcodeproj
