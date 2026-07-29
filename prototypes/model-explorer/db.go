package main

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

	"github.com/oklog/ulid/v2"
	_ "modernc.org/sqlite"
)

// newID mints an app-prefixed ULID, matching the schema CHECK
// (id LIKE 'app-%' AND length(id) = 30).
func newID() string {
	return "app-" + ulid.Make().String()
}

// openDB opens (creating if needed) the SQLite database with foreign-key
// enforcement on for every pooled connection. On first run it bootstraps the
// schema and exercise library from the canonical sqlite/ directory, so the app
// always reflects the real model rather than a hand-copied subset.
func openDB(dbPath, sqliteDir string) (*sql.DB, error) {
	dsn := fmt.Sprintf("file:%s?_pragma=foreign_keys(1)&_pragma=busy_timeout(5000)", dbPath)
	db, err := sql.Open("sqlite", dsn)
	if err != nil {
		return nil, err
	}
	// modernc keeps a connection pool; keep it to one writer to avoid
	// "database is locked" on this tiny single-user explorer app.
	db.SetMaxOpenConns(1)

	if err := db.Ping(); err != nil {
		return nil, err
	}

	bootstrapped, err := hasTable(db, "exercise")
	if err != nil {
		return nil, err
	}
	if !bootstrapped {
		if err := runSQLFile(db, filepath.Join(sqliteDir, "schema.sql")); err != nil {
			return nil, fmt.Errorf("load schema.sql: %w", err)
		}
		if err := runSQLFile(db, filepath.Join(sqliteDir, "exercises_complete.sql")); err != nil {
			return nil, fmt.Errorf("load exercises_complete.sql: %w", err)
		}
	}
	return db, nil
}

func hasTable(db *sql.DB, name string) (bool, error) {
	var n int
	err := db.QueryRow(
		`SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?`, name,
	).Scan(&n)
	return n > 0, err
}

func runSQLFile(db *sql.DB, path string) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	_, err = db.Exec(string(b))
	return err
}
