// Command backend is a THROWAWAY PROTOTYPE — not production code.
//
// It is a tiny web app for exploring the plan-vs-record data model in
// sqlite/schema.sql. It lets you build exercises and workout plans (the mutable
// "plan" tree), then start and execute a session (the immutable "record" tree)
// — surfacing how supersets, swap variants, and provenance work.
//
// It is meant to be run on localhost by one person and thrown away. It has no
// authentication, no authorization, no input validation, and no request limits;
// it leaks raw SQL errors to callers and has no tests. Do not deploy it, expose
// it to a network, or grow the real backend out of it. See README.md.
package main

import (
	"database/sql"
	"embed"
	"flag"
	"io/fs"
	"log"
	"net/http"
)

//go:embed static
var staticFS embed.FS

type server struct {
	db *sql.DB
}

func main() {
	addr := flag.String("addr", ":8080", "listen address")
	dbPath := flag.String("db", "app.db", "path to the SQLite database file")
	sqliteDir := flag.String("sqlite-dir", "../sqlite", "dir holding canonical schema.sql + exercises_complete.sql")
	flag.Parse()

	db, err := openDB(*dbPath, *sqliteDir)
	if err != nil {
		log.Fatalf("open db: %v", err)
	}
	defer db.Close()

	s := &server{db: db}
	mux := http.NewServeMux()
	s.routes(mux)

	// Serve the embedded single-page frontend at /.
	sub, err := fs.Sub(staticFS, "static")
	if err != nil {
		log.Fatal(err)
	}
	mux.Handle("/", http.FileServer(http.FS(sub)))

	log.Printf("Social Workout model explorer on http://localhost%s", *addr)
	log.Printf("  db=%s  (bootstrapped from %s on first run)", *dbPath, *sqliteDir)
	if err := http.ListenAndServe(*addr, mux); err != nil {
		log.Fatal(err)
	}
}

func (s *server) routes(mux *http.ServeMux) {
	// Exercise library.
	mux.HandleFunc("GET /api/exercises", s.listExercises)
	mux.HandleFunc("POST /api/exercises", s.createExercise)

	// Plan tree: templates -> variants -> planned sets.
	mux.HandleFunc("GET /api/templates", s.listTemplates)
	mux.HandleFunc("POST /api/templates", s.createTemplate)
	mux.HandleFunc("GET /api/templates/{id}", s.getTemplate)
	mux.HandleFunc("POST /api/templates/{id}/variants", s.addVariant)
	mux.HandleFunc("POST /api/variants/{id}/set-templates", s.addSetTemplate)

	// Record tree: workouts -> workout_exercise -> exercise_set.
	mux.HandleFunc("GET /api/workouts", s.listWorkouts)
	mux.HandleFunc("POST /api/workouts/start", s.startWorkout)
	mux.HandleFunc("GET /api/workouts/{id}", s.getWorkout)
	mux.HandleFunc("POST /api/workouts/{id}/finish", s.finishWorkout)
	mux.HandleFunc("POST /api/workout-exercises/{id}/sets", s.addSet)
	mux.HandleFunc("PATCH /api/sets/{id}", s.updateSet)
	mux.HandleFunc("DELETE /api/sets/{id}", s.deleteSet)
}
