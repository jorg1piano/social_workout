package main

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

// ---- JSON helpers ---------------------------------------------------------

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, code int, msg string) {
	writeJSON(w, code, map[string]string{"error": msg})
}

func decode(r *http.Request, v any) error {
	defer r.Body.Close()
	return json.NewDecoder(r.Body).Decode(v)
}

// ---- Exercise library -----------------------------------------------------

type exercise struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description *string `json:"description"`
}

func (s *server) listExercises(w http.ResponseWriter, r *http.Request) {
	rows, err := s.db.Query(`SELECT id, name, description FROM exercise ORDER BY name`)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	defer rows.Close()
	out := []exercise{}
	for rows.Next() {
		var e exercise
		if err := rows.Scan(&e.ID, &e.Name, &e.Description); err != nil {
			writeErr(w, 500, err.Error())
			return
		}
		out = append(out, e)
	}
	writeJSON(w, 200, out)
}

func (s *server) createExercise(w http.ResponseWriter, r *http.Request) {
	var in exercise
	if err := decode(r, &in); err != nil || in.Name == "" {
		writeErr(w, 400, "name is required")
		return
	}
	in.ID = newID()
	if _, err := s.db.Exec(
		`INSERT INTO exercise (id, name, description) VALUES (?, ?, ?)`,
		in.ID, in.Name, in.Description); err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, in)
}

// ---- Plan tree: templates -------------------------------------------------

type template struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description *string `json:"description"`
	ArchivedAt  *int64  `json:"archived_at"`
}

func (s *server) listTemplates(w http.ResponseWriter, r *http.Request) {
	rows, err := s.db.Query(
		`SELECT id, name, description, archived_at FROM workout_template ORDER BY name`)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	defer rows.Close()
	out := []template{}
	for rows.Next() {
		var t template
		if err := rows.Scan(&t.ID, &t.Name, &t.Description, &t.ArchivedAt); err != nil {
			writeErr(w, 500, err.Error())
			return
		}
		out = append(out, t)
	}
	writeJSON(w, 200, out)
}

func (s *server) createTemplate(w http.ResponseWriter, r *http.Request) {
	var in template
	if err := decode(r, &in); err != nil || in.Name == "" {
		writeErr(w, 400, "name is required")
		return
	}
	in.ID = newID()
	if _, err := s.db.Exec(
		`INSERT INTO workout_template (id, name, description) VALUES (?, ?, ?)`,
		in.ID, in.Name, in.Description); err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, in)
}

type plannedSet struct {
	ID       string   `json:"id"`
	Ordering int      `json:"ordering"`
	SetType  *string  `json:"set_type"`
	RepCount *int     `json:"rep_count"`
	Weight   *float64 `json:"weight"`
	Unit     *string  `json:"unit"`
	RestTime int      `json:"rest_time"`
}

type variant struct {
	ID            string       `json:"id"`
	ExerciseID    string       `json:"exercise_id"`
	ExerciseName  string       `json:"exercise_name"`
	Block         int          `json:"block_ordering"`
	Within        int          `json:"within_block_ordering"`
	ExerciseIndex int          `json:"exercise_index"`
	ArchivedAt    *int64       `json:"archived_at"`
	Notes         *string      `json:"notes"`
	PlannedSets   []plannedSet `json:"planned_sets"`
}

type templateDetail struct {
	template
	Variants []variant `json:"variants"`
}

func (s *server) getTemplate(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var t templateDetail
	err := s.db.QueryRow(
		`SELECT id, name, description, archived_at FROM workout_template WHERE id = ?`, id,
	).Scan(&t.ID, &t.Name, &t.Description, &t.ArchivedAt)
	if err == sql.ErrNoRows {
		writeErr(w, 404, "template not found")
		return
	} else if err != nil {
		writeErr(w, 500, err.Error())
		return
	}

	rows, err := s.db.Query(`
		SELECT v.id, v.exercise_id, e.name, v.block_ordering, v.within_block_ordering,
		       v.exercise_index, v.archived_at, v.notes
		FROM exercise_for_workout_template v
		JOIN exercise e ON e.id = v.exercise_id
		WHERE v.workout_template_id = ?
		ORDER BY v.block_ordering, v.within_block_ordering, v.exercise_index`, id)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	// Scan all variants first, THEN fetch planned sets. Nesting a child query
	// inside the parent row iteration would deadlock the single-conn pool.
	t.Variants = []variant{}
	for rows.Next() {
		var v variant
		if err := rows.Scan(&v.ID, &v.ExerciseID, &v.ExerciseName, &v.Block, &v.Within,
			&v.ExerciseIndex, &v.ArchivedAt, &v.Notes); err != nil {
			rows.Close()
			writeErr(w, 500, err.Error())
			return
		}
		t.Variants = append(t.Variants, v)
	}
	rows.Close()
	for i := range t.Variants {
		t.Variants[i].PlannedSets = s.plannedSetsFor(t.Variants[i].ID)
	}
	writeJSON(w, 200, t)
}

func (s *server) plannedSetsFor(variantID string) []plannedSet {
	rows, err := s.db.Query(`
		SELECT id, ordering, set_type, rep_count, weight, unit, rest_time
		FROM exercise_set_template
		WHERE exercise_for_workout_template_id = ?
		ORDER BY ordering`, variantID)
	if err != nil {
		return []plannedSet{}
	}
	defer rows.Close()
	out := []plannedSet{}
	for rows.Next() {
		var p plannedSet
		if err := rows.Scan(&p.ID, &p.Ordering, &p.SetType, &p.RepCount, &p.Weight, &p.Unit, &p.RestTime); err != nil {
			return out
		}
		out = append(out, p)
	}
	return out
}

func (s *server) addVariant(w http.ResponseWriter, r *http.Request) {
	templateID := r.PathValue("id")
	var in variant
	if err := decode(r, &in); err != nil || in.ExerciseID == "" {
		writeErr(w, 400, "exercise_id is required")
		return
	}
	if in.Within == 0 {
		in.Within = 1 // straight exercise = block of one
	}
	in.ID = newID()
	_, err := s.db.Exec(`
		INSERT INTO exercise_for_workout_template
		  (id, workout_template_id, exercise_id, notes, block_ordering, within_block_ordering, exercise_index)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		in.ID, templateID, in.ExerciseID, in.Notes, in.Block, in.Within, in.ExerciseIndex)
	if err != nil {
		// Surface the swap-dedup / slot-uniqueness constraints as a 409.
		writeErr(w, 409, err.Error())
		return
	}
	writeJSON(w, 201, in)
}

func (s *server) addSetTemplate(w http.ResponseWriter, r *http.Request) {
	variantID := r.PathValue("id")
	var in plannedSet
	if err := decode(r, &in); err != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	// exercise_set_template needs the exercise_id too (denormalized in schema).
	var exerciseID string
	if err := s.db.QueryRow(
		`SELECT exercise_id FROM exercise_for_workout_template WHERE id = ?`, variantID,
	).Scan(&exerciseID); err != nil {
		writeErr(w, 404, "variant not found")
		return
	}
	in.ID = newID()
	_, err := s.db.Exec(`
		INSERT INTO exercise_set_template
		  (id, rep_count, weight, unit, ordering, set_type, rest_time, exercise_id, exercise_for_workout_template_id)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		in.ID, in.RepCount, in.Weight, in.Unit, in.Ordering, in.SetType, in.RestTime, exerciseID, variantID)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, in)
}

// ---- Record tree: workouts ------------------------------------------------

type workoutSummary struct {
	ID           string  `json:"id"`
	TemplateID   *string `json:"template_id"`
	TemplateName *string `json:"template_name"`
	StartTime    *int64  `json:"start_time"`
	StopTime     *int64  `json:"stop_time"`
	ExerciseCnt  int     `json:"exercise_count"`
}

func (s *server) listWorkouts(w http.ResponseWriter, r *http.Request) {
	rows, err := s.db.Query(`
		SELECT wo.id, wo.template_id, wt.name, wo.start_time, wo.stop_time,
		       (SELECT COUNT(*) FROM workout_exercise we WHERE we.workout_id = wo.id)
		FROM workout wo
		LEFT JOIN workout_template wt ON wt.id = wo.template_id
		ORDER BY wo.start_time DESC, wo.id DESC`)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	defer rows.Close()
	out := []workoutSummary{}
	for rows.Next() {
		var s workoutSummary
		if err := rows.Scan(&s.ID, &s.TemplateID, &s.TemplateName, &s.StartTime, &s.StopTime, &s.ExerciseCnt); err != nil {
			writeErr(w, 500, err.Error())
			return
		}
		out = append(out, s)
	}
	writeJSON(w, 200, out)
}

type startWorkoutReq struct {
	TemplateID string   `json:"template_id"`
	Picks      []string `json:"picks"` // chosen exercise_for_workout_template ids, one per slot
}

// startWorkout resolves the plan into the record: it creates a workout, then a
// workout_exercise per picked variant (copying its exercise_id + block/within
// order and pointing source_variant_id back at the pick), and materializes the
// planned sets into not-yet-completed exercise_set rows to fill during the run.
func (s *server) startWorkout(w http.ResponseWriter, r *http.Request) {
	var in startWorkoutReq
	if err := decode(r, &in); err != nil || in.TemplateID == "" || len(in.Picks) == 0 {
		writeErr(w, 400, "template_id and at least one pick are required")
		return
	}
	tx, err := s.db.Begin()
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	defer tx.Rollback()

	workoutID := newID()
	if _, err := tx.Exec(
		`INSERT INTO workout (id, template_id, start_time) VALUES (?, ?, strftime('%s','now'))`,
		workoutID, in.TemplateID); err != nil {
		writeErr(w, 500, err.Error())
		return
	}

	for _, variantID := range in.Picks {
		var exerciseID string
		var block, within int
		err := tx.QueryRow(`
			SELECT exercise_id, block_ordering, within_block_ordering
			FROM exercise_for_workout_template WHERE id = ?`, variantID,
		).Scan(&exerciseID, &block, &within)
		if err != nil {
			writeErr(w, 400, "unknown pick: "+variantID)
			return
		}
		weID := newID()
		if _, err := tx.Exec(`
			INSERT INTO workout_exercise
			  (id, workout_id, exercise_id, block_ordering, within_block_ordering, source_variant_id)
			VALUES (?, ?, ?, ?, ?, ?)`,
			weID, workoutID, exerciseID, block, within, variantID); err != nil {
			writeErr(w, 409, err.Error())
			return
		}
		// Materialize planned sets as prefilled, not-completed record rows.
		// IDs are minted through the app- ULID code path (newID), never in SQL.
		if err := materializePlannedSets(tx, weID, variantID); err != nil {
			writeErr(w, 500, err.Error())
			return
		}
	}

	if err := tx.Commit(); err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"id": workoutID})
}

// materializePlannedSets copies a variant's exercise_set_template rows into
// exercise_set as prefilled, not-yet-completed record rows for the session.
func materializePlannedSets(tx *sql.Tx, weID, variantID string) error {
	rows, err := tx.Query(`
		SELECT rep_count, weight, unit, ordering, COALESCE(set_type, 'regularSet'), rest_time
		FROM exercise_set_template
		WHERE exercise_for_workout_template_id = ?
		ORDER BY ordering`, variantID)
	if err != nil {
		return err
	}
	type tmpl struct {
		rep     *int
		weight  *float64
		unit    *string
		order   int
		setType string
		rest    int
	}
	var planned []tmpl
	for rows.Next() {
		var t tmpl
		if err := rows.Scan(&t.rep, &t.weight, &t.unit, &t.order, &t.setType, &t.rest); err != nil {
			rows.Close()
			return err
		}
		planned = append(planned, t)
	}
	rows.Close()

	for _, t := range planned {
		if _, err := tx.Exec(`
			INSERT INTO exercise_set
			  (id, workout_exercise_id, rep_count, weight, unit, ordering, set_type, rest_time, is_completed)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)`,
			newID(), weID, t.rep, t.weight, t.unit, t.order, t.setType, t.rest); err != nil {
			return err
		}
	}
	return nil
}

type recordSet struct {
	ID          string   `json:"id"`
	Ordering    *int     `json:"ordering"`
	Attempt     int      `json:"attempt_number"`
	SetType     string   `json:"set_type"`
	RepCount    *int     `json:"rep_count"`
	Weight      *float64 `json:"weight"`
	Unit        *string  `json:"unit"`
	RestTime    int      `json:"rest_time"`
	IsCompleted bool     `json:"is_completed"`
}

type recordExercise struct {
	ID              string      `json:"id"`
	ExerciseID      string      `json:"exercise_id"`
	ExerciseName    string      `json:"exercise_name"`
	Block           int         `json:"block_ordering"`
	Within          int         `json:"within_block_ordering"`
	SourceVariantID *string     `json:"source_variant_id"`
	Notes           *string     `json:"notes"`
	Sets            []recordSet `json:"sets"`
}

type workoutDetail struct {
	workoutSummary
	Exercises []recordExercise `json:"exercises"`
}

// getWorkout renders a session PURELY from the record tree — workout ->
// workout_exercise -> exercise_set — with no dependency on the template. Even
// the exercise name comes from exercise (definition), not the plan.
func (s *server) getWorkout(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var d workoutDetail
	err := s.db.QueryRow(`
		SELECT wo.id, wo.template_id, wt.name, wo.start_time, wo.stop_time
		FROM workout wo
		LEFT JOIN workout_template wt ON wt.id = wo.template_id
		WHERE wo.id = ?`, id,
	).Scan(&d.ID, &d.TemplateID, &d.TemplateName, &d.StartTime, &d.StopTime)
	if err == sql.ErrNoRows {
		writeErr(w, 404, "workout not found")
		return
	} else if err != nil {
		writeErr(w, 500, err.Error())
		return
	}

	rows, err := s.db.Query(`
		SELECT we.id, we.exercise_id, e.name, we.block_ordering, we.within_block_ordering,
		       we.source_variant_id, we.notes
		FROM workout_exercise we
		JOIN exercise e ON e.id = we.exercise_id
		WHERE we.workout_id = ?
		ORDER BY we.block_ordering, we.within_block_ordering`, id)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	// Scan all workout_exercise rows first, THEN fetch each one's sets, to
	// avoid a nested query deadlocking the single-conn pool.
	d.Exercises = []recordExercise{}
	for rows.Next() {
		var re recordExercise
		if err := rows.Scan(&re.ID, &re.ExerciseID, &re.ExerciseName, &re.Block, &re.Within,
			&re.SourceVariantID, &re.Notes); err != nil {
			rows.Close()
			writeErr(w, 500, err.Error())
			return
		}
		d.Exercises = append(d.Exercises, re)
	}
	rows.Close()
	for i := range d.Exercises {
		d.Exercises[i].Sets = s.setsFor(d.Exercises[i].ID)
	}
	d.ExerciseCnt = len(d.Exercises)
	writeJSON(w, 200, d)
}

func (s *server) setsFor(weID string) []recordSet {
	rows, err := s.db.Query(`
		SELECT id, ordering, attempt_number, set_type, rep_count, weight, unit, rest_time, is_completed
		FROM exercise_set
		WHERE workout_exercise_id = ?
		ORDER BY ordering, attempt_number`, weID)
	if err != nil {
		return []recordSet{}
	}
	defer rows.Close()
	out := []recordSet{}
	for rows.Next() {
		var rs recordSet
		if err := rows.Scan(&rs.ID, &rs.Ordering, &rs.Attempt, &rs.SetType, &rs.RepCount,
			&rs.Weight, &rs.Unit, &rs.RestTime, &rs.IsCompleted); err != nil {
			return out
		}
		out = append(out, rs)
	}
	return out
}

func (s *server) finishWorkout(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if _, err := s.db.Exec(
		`UPDATE workout SET stop_time = strftime('%s','now'), updated_at = strftime('%s','now') WHERE id = ?`, id,
	); err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "finished"})
}

type addSetReq struct {
	Ordering *int     `json:"ordering"`
	Attempt  *int     `json:"attempt_number"`
	SetType  *string  `json:"set_type"`
	RepCount *int     `json:"rep_count"`
	Weight   *float64 `json:"weight"`
	Unit     *string  `json:"unit"`
	RestTime *int     `json:"rest_time"`
}

func (s *server) addSet(w http.ResponseWriter, r *http.Request) {
	weID := r.PathValue("id")
	var in addSetReq
	if err := decode(r, &in); err != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	setType := "regularSet"
	if in.SetType != nil {
		setType = *in.SetType
	}
	attempt := 1
	if in.Attempt != nil {
		attempt = *in.Attempt
	}
	rest := 0
	if in.RestTime != nil {
		rest = *in.RestTime
	}
	id := newID()
	_, err := s.db.Exec(`
		INSERT INTO exercise_set
		  (id, workout_exercise_id, rep_count, weight, unit, ordering, attempt_number, set_type, rest_time, is_completed)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)`,
		id, weID, in.RepCount, in.Weight, in.Unit, in.Ordering, attempt, setType, rest)
	if err != nil {
		writeErr(w, 409, err.Error())
		return
	}
	writeJSON(w, 201, map[string]string{"id": id})
}

type updateSetReq struct {
	RepCount    *int     `json:"rep_count"`
	Weight      *float64 `json:"weight"`
	Unit        *string  `json:"unit"`
	IsCompleted *bool    `json:"is_completed"`
}

func (s *server) updateSet(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var in updateSetReq
	if err := decode(r, &in); err != nil {
		writeErr(w, 400, "invalid body")
		return
	}
	_, err := s.db.Exec(`
		UPDATE exercise_set SET
		  rep_count    = COALESCE(?, rep_count),
		  weight       = COALESCE(?, weight),
		  unit         = COALESCE(?, unit),
		  is_completed = COALESCE(?, is_completed),
		  updated_at   = strftime('%s','now')
		WHERE id = ?`,
		in.RepCount, in.Weight, in.Unit, in.IsCompleted, id)
	if err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "ok"})
}

func (s *server) deleteSet(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if _, err := s.db.Exec(`DELETE FROM exercise_set WHERE id = ?`, id); err != nil {
		writeErr(w, 500, err.Error())
		return
	}
	writeJSON(w, 200, map[string]string{"status": "deleted"})
}
