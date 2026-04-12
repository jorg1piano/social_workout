#!/bin/bash

# Insert test data into test-db.db
# Usage: ./test-data.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_NAME="$SCRIPT_DIR/test-db.db"

rm -f "$DB_NAME"

echo "Instantiate fresh database schema..."
sqlite3 "$DB_NAME" < "$SCRIPT_DIR/schema.sql"

echo "Inserting test data into test-db.db..."
ERROR_OUTPUT=$(sqlite3 "$DB_NAME" < "$SCRIPT_DIR/exercises_complete.sql" 2>&1)

if [ $? -eq 0 ]; then
  echo "Test data inserted successfully"
else
  echo "Failed to insert test data"
  echo "Error: $ERROR_OUTPUT"
  exit 1
fi
