#!/bin/bash

# Test database setup script
# Deletes test-db.db if it exists, then creates a fresh database with schema.sql

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_NAME="$SCRIPT_DIR/test-db.db"

# Delete the database if it exists
if [ -f "$DB_NAME" ]; then
  echo "Deleting existing test-db.db..."
  rm "$DB_NAME"
fi

echo "Creating new test database..."
sqlite3 "$DB_NAME" < "$SCRIPT_DIR/schema.sql"

if [ $? -eq 0 ]; then
  echo "Test database created successfully: test-db.db"
  echo "Schema applied"
else
  echo "Failed to create test database"
  exit 1
fi
