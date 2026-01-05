#!/bin/bash

# Insert test data into test-db.db
# Usage: ./test-data.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_NAME="$SCRIPT_DIR/test-db.db"

if [ ! -f "$DB_NAME" ]; then
  echo "Error: test-db.db not found. Run ./test-db.sh first"
  exit 1
fi

echo "Inserting test data into test-db.db..."
sqlite3 "$DB_NAME" < "$SCRIPT_DIR/exercises_with_categories_and_body_parts.sql"

if [ $? -eq 0 ]; then
  echo "Test data inserted successfully"
else
  echo "Failed to insert test data"
  exit 1
fi
