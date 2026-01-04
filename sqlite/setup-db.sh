#!/bin/bash

# Setup a new SQLite database with the workout schema
# Usage: ./setup-db.sh <database-name.db>

if [ -z "$1" ]; then
  echo "Error: No database name provided"
  echo "Usage: ./setup-db.sh <database-name.db>"
  exit 1
fi

DB_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up database: $DB_NAME"

# Create the database and apply schema
sqlite3 "$DB_NAME" < "$SCRIPT_DIR/schema.sql"

if [ $? -eq 0 ]; then
  echo "✓ Database created successfully: $DB_NAME"
  echo "✓ Schema applied"
else
  echo "✗ Failed to create database"
  exit 1
fi
