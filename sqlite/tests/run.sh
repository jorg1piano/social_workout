#!/usr/bin/env bash
#
# SQL-level stress tests for the plan-vs-record data model.
#
# Builds a fresh DB from sqlite/schema.sql + tests/fixtures.sql for each
# scenario, enables `PRAGMA foreign_keys = ON` on every connection (sqlite3
# defaults it OFF), and asserts the model's referential-integrity, uniqueness,
# self-documenting and soft-delete invariants.
#
# Usage:  ./sqlite/tests/run.sh   (or: just test-model)
# Exit:   0 if all assertions pass, 1 otherwise.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQLITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$SQLITE_DIR/.." && pwd)"
SCHEMA="$SQLITE_DIR/schema.sql"
FIXTURES="$SCRIPT_DIR/fixtures.sql"
ULID="$REPO_DIR/tools/generate_ulid/ulid"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

PASS=0
FAIL=0

# ---- fixture ULIDs (real, minted via tools/generate_ulid) ------------------
EXA='app-01KXVSX4FC4PYWAEW1W5WDE34C'   # Leg Extension
EXB='app-01KXVSX4FGT864AWYABVGBDZXW'   # Lying Leg Curl
EXC='app-01KXVSX4FK94F831GHT4GNC0EA'   # Squat
EXD='app-01KXVSX4FPTFF9BC8R1YJP31ET'   # Sissy Squat (swap for A)
EXE='app-01KXVSX4FS0CE8Y3X0Q4CF0C0R'   # Seated Leg Curl (swap for B)
EXF='app-01KXVSX4FWDHY4RNBASD6Z4DJW'   # Bench Press
TPL1='app-01KXVSX4FZFNQ1K5F1WEXGYGPG'  # Leg Day template
V_A0='app-01KXVSX4G2SSFVMFGHS3XQV6HT'  # EXA @ b1w1 i0
V_A1='app-01KXVSX4G61WMXE8DKPF88M554'  # EXD @ b1w1 i1
V_B0='app-01KXVSX4G84N39STFCE1A904MQ'  # EXB @ b1w2 i0
V_B1='app-01KXVSX4GBN4T6BM1A2GMEA64C'  # EXE @ b1w2 i1
V_C0='app-01KXVSX4GEAPJXTFX8YND3P83E'  # EXC @ b2w1 i0
W1='app-01KXVSX4GHKB907MKT4CGTPEV2'    # logged superset session (picked swaps)
W2='app-01KXVSX4GMBN197D2J0WS2590E'    # sibling session (Squat only)
WE1='app-01KXVSX4GQEJY0NAY4JF69ZWSB'   # W1 Sissy  b1w1
WE2='app-01KXVSX4GSNP6HMJGFZBPCN3AG'   # W1 Seated b1w2
WE3='app-01KXVSX4GW02F6ZSQ01999A298'   # W1 Squat  b2w1
WE4='app-01KXVSX4GZGR76CFGD0T15WWGQ'   # W2 Squat  b1w1

uid() { echo "app-$("$ULID" generate)"; }

new_db() {
  local db
  db="$(mktemp "$WORKDIR/dbXXXXXX")"
  sqlite3 "$db" < "$SCHEMA"
  sqlite3 "$db" < "$FIXTURES"
  echo "$db"
}

_run() { sqlite3 "$1" "PRAGMA foreign_keys = ON; $2" 2>&1; }

pass() { PASS=$((PASS + 1)); printf '  \033[32mPASS\033[0m %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m %s\n     -> %s\n' "$1" "$2"; }

# assert_ok DB "desc" "sql"  — statement must succeed
assert_ok() {
  local db="$1" desc="$2" sql="$3" out rc
  out="$(_run "$db" "$sql")"; rc=$?
  if [ $rc -eq 0 ]; then pass "$desc"; else fail "$desc" "expected success, rc=$rc: $out"; fi
}

# assert_fail DB "desc" "sql"  — statement must fail with a constraint error
assert_fail() {
  local db="$1" desc="$2" sql="$3" out rc
  out="$(_run "$db" "$sql")"; rc=$?
  if [ $rc -ne 0 ] && printf '%s' "$out" | grep -qi 'constraint failed'; then
    pass "$desc"
  else
    fail "$desc" "expected constraint failure, rc=$rc: $out"
  fi
}

# assert_eq DB "desc" "sql" "expected"  — query output must equal expected
assert_eq() {
  local db="$1" desc="$2" sql="$3" expected="$4" out rc
  out="$(_run "$db" "$sql")"; rc=$?
  if [ $rc -eq 0 ] && [ "$out" = "$expected" ]; then
    pass "$desc"
  else
    fail "$desc" "expected [$expected], got [$out] (rc=$rc)"
  fi
}

section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ===========================================================================
section "1. Delete workout cascades to workout_exercise + exercise_set; sibling untouched"
DB="$(new_db)"
assert_ok  "$DB" "delete workout W1 succeeds"                 "DELETE FROM workout WHERE id='$W1';"
assert_eq  "$DB" "W1 workout_exercise rows gone"              "SELECT COUNT(*) FROM workout_exercise WHERE workout_id='$W1';" "0"
assert_eq  "$DB" "W1 exercise_set rows cascaded away"         "SELECT COUNT(*) FROM exercise_set WHERE workout_exercise_id IN ('$WE1','$WE2','$WE3');" "0"
assert_eq  "$DB" "sibling W2 workout_exercise intact"         "SELECT COUNT(*) FROM workout_exercise WHERE workout_id='$W2';" "1"
assert_eq  "$DB" "sibling W2 exercise_set intact"             "SELECT COUNT(*) FROM exercise_set WHERE workout_exercise_id='$WE4';" "2"

# ===========================================================================
section "2. Hard-delete template with history: cascades plan, SET NULLs provenance, record survives"
DB="$(new_db)"
assert_ok  "$DB" "hard-delete workout_template succeeds"      "DELETE FROM workout_template WHERE id='$TPL1';"
assert_eq  "$DB" "exercise_for_workout_template cascaded away" "SELECT COUNT(*) FROM exercise_for_workout_template WHERE workout_template_id='$TPL1';" "0"
assert_eq  "$DB" "workouts survive"                           "SELECT COUNT(*) FROM workout;" "2"
assert_eq  "$DB" "workout.template_id SET NULL"              "SELECT COUNT(*) FROM workout WHERE template_id IS NOT NULL;" "0"
assert_eq  "$DB" "workout_exercise rows survive"             "SELECT COUNT(*) FROM workout_exercise;" "4"
assert_eq  "$DB" "exercise_set rows survive"                 "SELECT COUNT(*) FROM exercise_set;" "11"
assert_eq  "$DB" "all source_variant_id SET NULL"           "SELECT COUNT(*) FROM workout_exercise WHERE source_variant_id IS NOT NULL;" "0"
assert_eq  "$DB" "WE1 exercise_id intact (self-documenting)" "SELECT exercise_id FROM workout_exercise WHERE id='$WE1';" "$EXD"
assert_eq  "$DB" "WE3 set data intact"                      "SELECT rep_count||'x'||weight FROM exercise_set WHERE id='app-01KXVSX4HQ91062DY3JHJQV43N';" "6x105"

# ===========================================================================
section "3. Deleting an exercise still referenced is RESTRICTed"
DB="$(new_db)"
assert_fail "$DB" "delete exercise used by workout_exercise (Squat) blocked" "DELETE FROM exercise WHERE id='$EXC';"
assert_fail "$DB" "delete exercise used only by a variant (Leg Ext) blocked" "DELETE FROM exercise WHERE id='$EXA';"

# ===========================================================================
section "4. idx_workout_exercise_order: (workout, block, within) uniqueness"
DB="$(new_db)"
assert_fail "$DB" "duplicate (W2, block1, within1) rejected"  "INSERT INTO workout_exercise (id, workout_id, exercise_id, block_ordering, within_block_ordering) VALUES ('$(uid)','$W2','$EXF',1,1);"
assert_ok   "$DB" "same block, different within (superset) ok" "INSERT INTO workout_exercise (id, workout_id, exercise_id, block_ordering, within_block_ordering) VALUES ('$(uid)','$W2','$EXF',1,2);"
assert_ok   "$DB" "different block, same within ok"           "INSERT INTO workout_exercise (id, workout_id, exercise_id, block_ordering, within_block_ordering) VALUES ('$(uid)','$W2','$EXF',2,1);"

# ===========================================================================
section "5. idx_exercise_set_attempt: (workout_exercise, ordering, attempt) uniqueness"
DB="$(new_db)"
assert_fail "$DB" "duplicate (WE4, ordering1, attempt1) rejected" "INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, attempt_number) VALUES ('$(uid)','$WE4',5,110,'kg',1,1);"
assert_ok   "$DB" "rest-pause: same ordering, attempt 2 ok"       "INSERT INTO exercise_set (id, workout_exercise_id, rep_count, weight, unit, ordering, attempt_number) VALUES ('$(uid)','$WE4',3,110,'kg',1,2);"

# ===========================================================================
section "6. idx_variant: (template, block, within, exercise_index) uniqueness"
DB="$(new_db)"
assert_fail "$DB" "duplicate variant slot (TPL1,1,1,0) rejected" "INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, block_ordering, within_block_ordering, exercise_index) VALUES ('$(uid)','$TPL1','$EXF',1,1,0);"

# ===========================================================================
section "7. idx_variant_exercise: one exercise per slot (swap-back must reactivate)"
DB="$(new_db)"
assert_fail "$DB" "second variant for same exercise in slot rejected" "INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, block_ordering, within_block_ordering, exercise_index) VALUES ('$(uid)','$TPL1','$EXA',1,1,2);"

# ===========================================================================
section "8. Self-documenting: render superset purely from record, before AND after template delete"
DB="$(new_db)"
RENDER="SELECT e.name||'|'||we.block_ordering||'|'||we.within_block_ordering||'|'||COUNT(es.id) \
        FROM workout_exercise we \
        JOIN exercise e ON we.exercise_id = e.id \
        LEFT JOIN exercise_set es ON es.workout_exercise_id = we.id \
        WHERE we.workout_id='$W1' \
        GROUP BY we.id ORDER BY we.block_ordering, we.within_block_ordering;"
EXPECT_RENDER=$'Sissy Squat|1|1|3\nSeated Leg Curl|1|2|3\nSquat|2|1|3'
assert_eq  "$DB" "record render (with template present)"     "$RENDER" "$EXPECT_RENDER"
assert_ok  "$DB" "hard-delete the template"                  "DELETE FROM workout_template WHERE id='$TPL1';"
assert_eq  "$DB" "record render IDENTICAL after template gone" "$RENDER" "$EXPECT_RENDER"
assert_eq  "$DB" "provenance nulled after template gone"      "SELECT COUNT(*) FROM workout_exercise WHERE workout_id='$W1' AND source_variant_id IS NOT NULL;" "0"

# ===========================================================================
section "9. Per-exercise stats aggregate across workouts/templates via workout_exercise"
DB="$(new_db)"
assert_eq  "$DB" "Squat sets counted across W1 + W2"         "SELECT COUNT(es.id) FROM exercise_set es JOIN workout_exercise we ON es.workout_exercise_id = we.id WHERE we.exercise_id='$EXC';" "5"
assert_eq  "$DB" "Squat appears in 2 distinct workouts"      "SELECT COUNT(DISTINCT we.workout_id) FROM exercise_set es JOIN workout_exercise we ON es.workout_exercise_id = we.id WHERE we.exercise_id='$EXC';" "2"

# ===========================================================================
section "10. Archiving is cosmetic: hides from picker, kept in history, provenance stays valid"
DB="$(new_db)"
assert_ok  "$DB" "archive the Seated Leg Curl swap variant"  "UPDATE exercise_for_workout_template SET archived_at = strftime('%s','now') WHERE id='$V_B1';"
assert_eq  "$DB" "picker (archived_at IS NULL) excludes it"  "SELECT COUNT(*) FROM exercise_for_workout_template WHERE workout_template_id='$TPL1' AND block_ordering=1 AND within_block_ordering=2 AND archived_at IS NULL;" "1"
assert_eq  "$DB" "history (unfiltered) still includes it"    "SELECT COUNT(*) FROM exercise_for_workout_template WHERE workout_template_id='$TPL1' AND block_ordering=1 AND within_block_ordering=2;" "2"
assert_eq  "$DB" "workout_exercise provenance still resolves" "SELECT COUNT(*) FROM workout_exercise we JOIN exercise_for_workout_template v ON we.source_variant_id = v.id WHERE we.id='$WE2';" "1"

# ===========================================================================
section "11. Swap-back reactivates the archived row instead of forking history"
DB="$(new_db)"
assert_ok  "$DB" "archive the Seated Leg Curl swap variant"  "UPDATE exercise_for_workout_template SET archived_at = strftime('%s','now') WHERE id='$V_B1';"
assert_fail "$DB" "re-adding same exercise in slot still rejected (dedup counts archived)" "INSERT INTO exercise_for_workout_template (id, workout_template_id, exercise_id, block_ordering, within_block_ordering, exercise_index) VALUES ('$(uid)','$TPL1','$EXE',1,2,2);"
assert_ok  "$DB" "reactivate by clearing archived_at"        "UPDATE exercise_for_workout_template SET archived_at = NULL WHERE id='$V_B1';"
assert_eq  "$DB" "variant is active again"                   "SELECT (archived_at IS NULL) FROM exercise_for_workout_template WHERE id='$V_B1';" "1"

# ===========================================================================
printf '\n\033[1m----------------------------------------\033[0m\n'
printf 'Total: %d passed, %d failed\n' "$PASS" "$FAIL"
if [ "$FAIL" -ne 0 ]; then exit 1; fi
