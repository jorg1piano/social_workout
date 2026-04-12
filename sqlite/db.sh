#!/bin/bash

# Insert test data into test-db.db
# Usage: ./test-data.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_NAME="$SCRIPT_DIR/test-db.db"

rm -f "$DB_NAME"

echo "Instantiate fresh database schema..."
sqlite3 "$DB_NAME" < "$SCRIPT_DIR/schema.sql"

echo "Inserting exercise library..."
ERROR_OUTPUT=$(sqlite3 "$DB_NAME" < "$SCRIPT_DIR/exercises_complete.sql" 2>&1)

if [ $? -ne 0 ]; then
  echo "Failed to insert exercise library"
  echo "Error: $ERROR_OUTPUT"
  exit 1
fi

echo "Inserting workout test data..."
ERROR_OUTPUT=$(sqlite3 "$DB_NAME" < "$SCRIPT_DIR/new-test-data.sql" 2>&1)

if [ $? -ne 0 ]; then
  echo "Failed to insert workout test data"
  echo "Error: $ERROR_OUTPUT"
  exit 1
fi

echo "Inserting social feed seed data..."
ERROR_OUTPUT=$(sqlite3 "$DB_NAME" < "$SCRIPT_DIR/feed-seed-data.sql" 2>&1)

if [ $? -ne 0 ]; then
  echo "Failed to insert feed seed data"
  echo "Error: $ERROR_OUTPUT"
  exit 1
fi

echo "All test data inserted successfully"
