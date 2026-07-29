import Foundation

/// Every read and write the app performs, in one place.
///
/// The method set deliberately mirrors the Go model explorer's HTTP API
/// (`prototypes/model-explorer/handlers.go`) so the two implementations can be
/// compared line for line: the plan tree is built with `addVariant` /
/// `addPlannedSet`, resolved into the record by `startWorkout`, and read back
/// by `workout(id:)` — which touches no plan table at all.
///
/// IDs are always minted here through `ULID.newID()`, never generated in SQL.
struct WorkoutRepository {
    let database: SQLiteDatabase

    init(database: SQLiteDatabase) {
        self.database = database
    }

    // MARK: - Exercise library

    /// The shared exercise definitions. These are referenced by both trees, and
    /// renaming one propagates everywhere — including into past sessions, which
    /// is intended: it's the same movement, spelled better.
    func exercises(matching search: String = "") -> [Exercise] {
        let trimmed = search.trimmingCharacters(in: .whitespaces)
        let sql = """
            SELECT id, name, description FROM exercise
            \(trimmed.isEmpty ? "" : "WHERE name LIKE ?")
            ORDER BY name
            """
        let parameters: [SQLParameter?] = trimmed.isEmpty ? [] : ["%\(trimmed)%"]
        return (try? database.query(sql, parameters).compactMap { try? Exercise(row: $0) }) ?? []
    }

    func exercise(id: String) throws -> Exercise? {
        try database.query("SELECT id, name, description FROM exercise WHERE id = ?", [id])
            .first.map { try Exercise(row: $0) }
    }

    /// Adds a user-authored exercise. `usr-` prefix, per the schema's ID CHECK.
    @discardableResult
    func createExercise(name: String, description: String?) throws -> Exercise {
        let id = ULID.newID(.user)
        try database.execute(
            "INSERT INTO exercise (id, name, description) VALUES (?, ?, ?)",
            [id, name, description])
        return Exercise(id: id, name: name, description: description)
    }

    func renameExercise(id: String, to name: String) throws {
        try database.execute(
            "UPDATE exercise SET name = ?, updated_at = strftime('%s','now') WHERE id = ?",
            [name, id])
    }

    /// Body part tags for an exercise, via the `exercise_body_part` junction.
    func bodyParts(exerciseID: String) -> [String] {
        tags(
            exerciseID: exerciseID,
            sql: """
                SELECT c.name AS name FROM exercise_body_part j
                JOIN body_part_category c ON c.id = j.body_part_category_id
                WHERE j.exercise_id = ? ORDER BY c.name
                """)
    }

    func equipment(exerciseID: String) -> [String] {
        tags(
            exerciseID: exerciseID,
            sql: """
                SELECT c.name AS name FROM exercise_equipment j
                JOIN equipment_category c ON c.id = j.equipment_category_id
                WHERE j.exercise_id = ? ORDER BY c.name
                """)
    }

    private func tags(exerciseID: String, sql: String) -> [String] {
        (try? database.query(sql, [exerciseID]).compactMap { try? $0.text("name") }) ?? []
    }

    /// Progression stats for one exercise across every session it appears in.
    ///
    /// The join runs `exercise_set → workout_exercise → workout`, never through
    /// a template — which is why swapping an exercise between plans, or
    /// deleting the plan entirely, doesn't lose a single data point.
    func stats(exerciseID: String) -> ExerciseStats {
        var stats = ExerciseStats()
        let sql = """
            SELECT COUNT(DISTINCT we.workout_id) AS sessions,
                   COUNT(es.id)                  AS sets,
                   MAX(es.weight)                AS heaviest,
                   MAX(w.start_time)             AS last_at
            FROM exercise_set es
            JOIN workout_exercise we ON we.id = es.workout_exercise_id
            JOIN workout w           ON w.id = we.workout_id
            WHERE we.exercise_id = ? AND es.is_completed = 1
            """
        if let row = try? database.query(sql, [exerciseID]).first {
            stats.sessionCount = row.optionalInt("sessions") ?? 0
            stats.completedSetCount = row.optionalInt("sets") ?? 0
            stats.heaviestWeight = row.optionalDouble("heaviest")
            stats.lastPerformed = row.optionalDate("last_at")
        }
        if let heaviest = stats.heaviestWeight {
            let repsSQL = """
                SELECT MAX(es.rep_count) AS reps
                FROM exercise_set es
                JOIN workout_exercise we ON we.id = es.workout_exercise_id
                WHERE we.exercise_id = ? AND es.is_completed = 1 AND es.weight = ?
                """
            stats.bestWeightReps = (try? database.query(repsSQL, [exerciseID, heaviest]).first)?
                .optionalInt("reps")
        }
        let planSQL = """
            SELECT COUNT(DISTINCT workout_template_id) AS value
            FROM exercise_for_workout_template WHERE exercise_id = ?
            """
        stats.planCount = ((try? database.scalarInt(planSQL, [exerciseID])) ?? nil) ?? 0
        return stats
    }

    // MARK: - Plan tree

    func templates(includeArchived: Bool = false) -> [WorkoutTemplate] {
        let sql = """
            SELECT id, name, description, notes, archived_at FROM workout_template
            \(includeArchived ? "" : "WHERE archived_at IS NULL")
            ORDER BY name
            """
        return (try? database.query(sql).compactMap { try? WorkoutTemplate(row: $0) }) ?? []
    }

    @discardableResult
    func createTemplate(name: String, description: String?, notes: String? = nil) throws -> String {
        let id = ULID.newID(.user)
        try database.execute(
            """
            INSERT INTO workout_template (id, name, description, notes) VALUES (?, ?, ?, ?)
            """,
            [id, name, description, notes])
        return id
    }

    /// A plan with every variant and planned set it holds — archived rows
    /// included, so the plan editor can show and un-archive them.
    func template(id: String) throws -> TemplateDetail? {
        let templateSQL = """
            SELECT id, name, description, notes, archived_at
            FROM workout_template WHERE id = ?
            """
        guard let templateRow = try database.query(templateSQL, [id]).first else { return nil }

        let variantSQL = """
            SELECT v.id, v.exercise_id, e.name AS exercise_name, v.block_ordering,
                   v.within_block_ordering, v.exercise_index, v.archived_at, v.notes
            FROM exercise_for_workout_template v
            JOIN exercise e ON e.id = v.exercise_id
            WHERE v.workout_template_id = ?
            ORDER BY v.block_ordering, v.within_block_ordering, v.exercise_index
            """
        var variants = try database.query(variantSQL, [id]).map { try PlanVariant(row: $0) }
        for index in variants.indices {
            variants[index].plannedSets = plannedSets(variantID: variants[index].id)
        }
        return TemplateDetail(template: try WorkoutTemplate(row: templateRow), variants: variants)
    }

    func plannedSets(variantID: String) -> [PlannedSet] {
        let sql = """
            SELECT id, ordering, set_type, rep_count, weight, unit, rest_time, rir, rpe
            FROM exercise_set_template
            WHERE exercise_for_workout_template_id = ?
            ORDER BY ordering
            """
        return (try? database.query(sql, [variantID]).compactMap { try? PlannedSet(row: $0) }) ?? []
    }

    /// Adds an exercise to a plan slot.
    ///
    /// Throws a constraint error when it would collide with `idx_variant`
    /// (that `(block, within, index)` slot is taken) or `idx_variant_exercise`
    /// (that exercise is already offered in this slot — swap back to it by
    /// clearing `archived_at` instead of adding a second row, so its history
    /// doesn't fork).
    @discardableResult
    func addVariant(
        templateID: String,
        exerciseID: String,
        block: Int,
        within: Int = 1,
        exerciseIndex: Int = 0,
        notes: String? = nil
    ) throws -> String {
        let id = ULID.newID(.user)
        try database.execute(
            """
            INSERT INTO exercise_for_workout_template
              (id, workout_template_id, exercise_id, notes, block_ordering,
               within_block_ordering, exercise_index)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            [id, templateID, exerciseID, notes, block, within, exerciseIndex])
        return id
    }

    /// Archiving hides a variant from the picker without touching history:
    /// sessions that used it keep their `source_variant_id` pointing at it.
    func setVariantArchived(id: String, archived: Bool) throws {
        try database.execute(
            """
            UPDATE exercise_for_workout_template
            SET archived_at = ?, updated_at = strftime('%s','now')
            WHERE id = ?
            """,
            [archived ? Date() : nil, id])
    }

    func setTemplateArchived(id: String, archived: Bool) throws {
        try database.execute(
            """
            UPDATE workout_template SET archived_at = ?, updated_at = strftime('%s','now')
            WHERE id = ?
            """,
            [archived ? Date() : nil, id])
    }

    /// Hard-deletes a plan. The variant tree cascades away, `workout.template_id`
    /// and `workout_exercise.source_variant_id` are SET NULL, and every logged
    /// session still reads back identically. That is the model's central claim,
    /// and this method is how you check it.
    func deleteTemplate(id: String) throws {
        try database.execute("DELETE FROM workout_template WHERE id = ?", [id])
    }

    @discardableResult
    func addPlannedSet(
        variantID: String,
        ordering: Int,
        repCount: Int?,
        weight: Double?,
        unit: String?,
        setType: SetType?,
        restTime: Int
    ) throws -> String {
        // exercise_set_template carries exercise_id too, so read it off the
        // variant rather than trusting a caller to pass a matching one.
        let exerciseSQL = "SELECT exercise_id FROM exercise_for_workout_template WHERE id = ?"
        guard let exerciseID = try database.query(exerciseSQL, [variantID]).first?.text("exercise_id")
        else {
            throw DatabaseError.missingRow("The plan variant \(variantID)")
        }
        let id = ULID.newID(.user)
        try database.execute(
            """
            INSERT INTO exercise_set_template
              (id, rep_count, weight, unit, ordering, set_type, rest_time,
               exercise_id, exercise_for_workout_template_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [id, repCount, weight, unit, ordering, setType?.rawValue, restTime, exerciseID, variantID])
        return id
    }

    func deletePlannedSet(id: String) throws {
        try database.execute("DELETE FROM exercise_set_template WHERE id = ?", [id])
    }

    // MARK: - Record tree

    func workouts() -> [WorkoutSummary] {
        let sql = """
            SELECT w.id, w.template_id, t.name AS template_name, w.start_time, w.stop_time,
                   (SELECT COUNT(*) FROM workout_exercise we WHERE we.workout_id = w.id)
                       AS exercise_count,
                   (SELECT COUNT(*) FROM exercise_set es
                      JOIN workout_exercise we2 ON we2.id = es.workout_exercise_id
                      WHERE we2.workout_id = w.id AND es.is_completed = 1)
                       AS completed_set_count
            FROM workout w
            LEFT JOIN workout_template t ON t.id = w.template_id
            ORDER BY w.start_time DESC, w.id DESC
            """
        return (try? database.query(sql).compactMap { try? WorkoutSummary(row: $0) }) ?? []
    }

    /// The session still running, if any — the one the app resumes into.
    func activeWorkout() -> WorkoutSummary? {
        workouts().first { $0.isInProgress }
    }

    /// Resolves a plan into a record.
    ///
    /// For each picked variant it writes a `workout_exercise` carrying the
    /// exercise actually chosen and this session's block/leg order, with
    /// `source_variant_id` as a severable pointer back to the pick, then
    /// materializes that variant's planned sets as not-yet-completed
    /// `exercise_set` rows to fill in during the session.
    ///
    /// After this returns, nothing about the session depends on the plan.
    @discardableResult
    func startWorkout(templateID: String, picks: [String]) throws -> String {
        try database.transaction {
            let workoutID = ULID.newID()
            try database.execute(
                """
                INSERT INTO workout (id, template_id, start_time)
                VALUES (?, ?, strftime('%s','now'))
                """,
                [workoutID, templateID])

            for variantID in picks {
                let variantSQL = """
                    SELECT exercise_id, block_ordering, within_block_ordering
                    FROM exercise_for_workout_template WHERE id = ?
                    """
                guard let variant = try database.query(variantSQL, [variantID]).first else {
                    throw DatabaseError.missingRow("The plan slot you picked (\(variantID))")
                }
                let workoutExerciseID = ULID.newID()
                try database.execute(
                    """
                    INSERT INTO workout_exercise
                      (id, workout_id, exercise_id, block_ordering, within_block_ordering,
                       source_variant_id)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    [
                        workoutExerciseID, workoutID, try variant.text("exercise_id"),
                        try variant.int("block_ordering"), try variant.int("within_block_ordering"),
                        variantID,
                    ])
                try materializePlannedSets(into: workoutExerciseID, from: variantID)
            }
            return workoutID
        }
    }

    /// Copies a variant's planned sets into `exercise_set` as prefilled, not-yet
    /// completed rows. From here on they are record rows: editing one changes
    /// what you did, not what was planned.
    private func materializePlannedSets(into workoutExerciseID: String, from variantID: String) throws {
        for planned in plannedSets(variantID: variantID) {
            try database.execute(
                """
                INSERT INTO exercise_set
                  (id, workout_exercise_id, rep_count, weight, unit, ordering, set_type,
                   rest_time, is_completed)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)
                """,
                [
                    ULID.newID(), workoutExerciseID, planned.repCount, planned.weight,
                    planned.unit, planned.ordering,
                    (planned.setType ?? .regularSet).rawValue, planned.restTime,
                ])
        }
    }

    /// Reads a session back purely from the record tree —
    /// `workout → workout_exercise → exercise_set` — joining only `exercise`
    /// for the name. No template is consulted, which is why this returns the
    /// same thing before and after the plan is deleted.
    func workout(id: String) throws -> WorkoutDetail? {
        let summarySQL = """
            SELECT w.id, w.template_id, t.name AS template_name, w.start_time, w.stop_time,
                   (SELECT COUNT(*) FROM workout_exercise we WHERE we.workout_id = w.id)
                       AS exercise_count,
                   (SELECT COUNT(*) FROM exercise_set es
                      JOIN workout_exercise we2 ON we2.id = es.workout_exercise_id
                      WHERE we2.workout_id = w.id AND es.is_completed = 1)
                       AS completed_set_count
            FROM workout w
            LEFT JOIN workout_template t ON t.id = w.template_id
            WHERE w.id = ?
            """
        guard let summaryRow = try database.query(summarySQL, [id]).first else { return nil }

        let exerciseSQL = """
            SELECT we.id, we.exercise_id, e.name AS exercise_name, we.block_ordering,
                   we.within_block_ordering, we.source_variant_id, we.notes
            FROM workout_exercise we
            JOIN exercise e ON e.id = we.exercise_id
            WHERE we.workout_id = ?
            ORDER BY we.block_ordering, we.within_block_ordering
            """
        var exercises = try database.query(exerciseSQL, [id]).map { try RecordExercise(row: $0) }
        for index in exercises.indices {
            exercises[index].sets = sets(workoutExerciseID: exercises[index].id)
        }
        return WorkoutDetail(summary: try WorkoutSummary(row: summaryRow), exercises: exercises)
    }

    func sets(workoutExerciseID: String) -> [RecordSet] {
        let sql = """
            SELECT id, ordering, attempt_number, set_type, rep_count, weight, unit,
                   rest_time, is_completed, notes
            FROM exercise_set
            WHERE workout_exercise_id = ?
            ORDER BY ordering, attempt_number
            """
        return (try? database.query(sql, [workoutExerciseID]).compactMap { try? RecordSet(row: $0) })
            ?? []
    }

    /// What you did for this exercise the last time you trained it — the
    /// "previous" column while logging. Found by exercise, across every plan
    /// and session, again without a template join.
    func previousSets(exerciseID: String, excludingWorkoutID: String) -> [RecordSet] {
        let workoutSQL = """
            SELECT we.workout_id AS id
            FROM workout_exercise we
            JOIN workout w ON w.id = we.workout_id
            JOIN exercise_set es ON es.workout_exercise_id = we.id
            WHERE we.exercise_id = ? AND we.workout_id != ? AND es.is_completed = 1
            ORDER BY w.start_time DESC
            LIMIT 1
            """
        guard let previousWorkoutID = (try? database.query(workoutSQL, [exerciseID, excludingWorkoutID]))?
            .first.flatMap({ try? $0.text("id") })
        else { return [] }

        let setsSQL = """
            SELECT es.id, es.ordering, es.attempt_number, es.set_type, es.rep_count, es.weight,
                   es.unit, es.rest_time, es.is_completed, es.notes
            FROM exercise_set es
            JOIN workout_exercise we ON we.id = es.workout_exercise_id
            WHERE we.exercise_id = ? AND we.workout_id = ? AND es.is_completed = 1
            ORDER BY es.ordering, es.attempt_number
            """
        return (try? database.query(setsSQL, [exerciseID, previousWorkoutID])
            .compactMap { try? RecordSet(row: $0) }) ?? []
    }

    func finishWorkout(id: String) throws {
        try database.execute(
            """
            UPDATE workout SET stop_time = strftime('%s','now'),
                               updated_at = strftime('%s','now')
            WHERE id = ?
            """,
            [id])
    }

    /// Discards a session. Cascades to its `workout_exercise` rows and their
    /// sets; other sessions, the plan and the exercise library are untouched.
    func deleteWorkout(id: String) throws {
        try database.execute("DELETE FROM workout WHERE id = ?", [id])
    }

    /// Appends an ad-hoc set — one that was never planned. `ordering` defaults
    /// to the next number for this leg, `attempt` to 1.
    @discardableResult
    func addSet(
        workoutExerciseID: String,
        ordering: Int? = nil,
        attemptNumber: Int = 1,
        setType: SetType = .regularSet,
        repCount: Int? = nil,
        weight: Double? = nil,
        unit: String? = nil,
        restTime: Int = 0
    ) throws -> String {
        let resolvedOrdering = try ordering ?? nextOrdering(workoutExerciseID: workoutExerciseID)
        let id = ULID.newID()
        try database.execute(
            """
            INSERT INTO exercise_set
              (id, workout_exercise_id, rep_count, weight, unit, ordering, attempt_number,
               set_type, rest_time, is_completed)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
            """,
            [
                id, workoutExerciseID, repCount, weight, unit, resolvedOrdering, attemptNumber,
                setType.rawValue, restTime,
            ])
        return id
    }

    /// Logs another go at a set already attempted — a missed lift retried, or a
    /// rest-pause continuation. Same `ordering`, next `attempt_number`, which is
    /// exactly what `idx_exercise_set_attempt` permits.
    @discardableResult
    func addAttempt(to set: RecordSet, workoutExerciseID: String) throws -> String {
        let nextAttemptSQL = """
            SELECT COALESCE(MAX(attempt_number), 0) + 1 AS value FROM exercise_set
            WHERE workout_exercise_id = ? AND ordering IS ?
            """
        let attempt = try database.scalarInt(nextAttemptSQL, [workoutExerciseID, set.ordering]) ?? 2
        return try addSet(
            workoutExerciseID: workoutExerciseID,
            ordering: set.ordering,
            attemptNumber: attempt,
            setType: set.setType,
            repCount: set.repCount,
            weight: set.weight,
            unit: set.unit,
            restTime: set.restTime)
    }

    private func nextOrdering(workoutExerciseID: String) throws -> Int {
        let sql = """
            SELECT COALESCE(MAX(ordering), 0) + 1 AS value FROM exercise_set
            WHERE workout_exercise_id = ?
            """
        return try database.scalarInt(sql, [workoutExerciseID]) ?? 1
    }

    /// Updates a logged set. Passing nil for a field leaves it as it was, which
    /// is how the model explorer's PATCH behaves. For `repCount`, `weight` and
    /// `notes`, clearing the field is itself a real edit — emptying the reps box
    /// mid-session means "I don't know yet", not "don't touch it" — so those take
    /// a double optional: `.some(nil)` writes NULL, `nil` leaves the column be.
    func updateSet(
        id: String,
        repCount: Int?? = nil,
        weight: Double?? = nil,
        unit: String? = nil,
        isCompleted: Bool? = nil,
        notes: String?? = nil
    ) throws {
        var assignments = ["updated_at = strftime('%s','now')"]
        var parameters: [SQLParameter?] = []

        if let repCount {
            assignments.append("rep_count = ?")
            parameters.append(repCount)
        }
        if let weight {
            assignments.append("weight = ?")
            parameters.append(weight)
        }
        if let unit {
            assignments.append("unit = ?")
            parameters.append(unit)
        }
        if let isCompleted {
            assignments.append("is_completed = ?")
            parameters.append(isCompleted)
        }
        if let notes {
            assignments.append("notes = ?")
            parameters.append(notes)
        }
        guard parameters.count > 0 else { return }

        parameters.append(id)
        try database.execute(
            "UPDATE exercise_set SET \(assignments.joined(separator: ", ")) WHERE id = ?",
            parameters)
    }

    func deleteSet(id: String) throws {
        try database.execute("DELETE FROM exercise_set WHERE id = ?", [id])
    }

    func setWorkoutExerciseNotes(id: String, notes: String?) throws {
        try database.execute(
            """
            UPDATE workout_exercise SET notes = ?, updated_at = strftime('%s','now')
            WHERE id = ?
            """,
            [notes, id])
    }
}
