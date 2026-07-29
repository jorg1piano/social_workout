import Foundation

// The types in this file split cleanly in two, and the split is the whole
// point of the data model:
//
//   PLAN   — Exercise, WorkoutTemplate, PlanVariant, PlannedSet.
//            Mutable suggestions. They matter at exactly one moment: when you
//            press Start.
//   RECORD — WorkoutSummary, RecordExercise, RecordSet.
//            What actually happened. Reads back with no reference to the plan,
//            which is why a template can be renamed, reordered, archived or
//            hard-deleted without touching a single logged session.

// MARK: - Shared

/// The four set types the schema's CHECK constraint allows.
enum SetType: String, CaseIterable, Identifiable {
    case warmup
    case regularSet
    case dropSet
    case failure

    var id: String { rawValue }

    var label: String {
        switch self {
        case .warmup: return "Warmup"
        case .regularSet: return "Working"
        case .dropSet: return "Drop set"
        case .failure: return "To failure"
        }
    }

    /// Short marker for dense set tables.
    var badge: String {
        switch self {
        case .warmup: return "W"
        case .regularSet: return ""
        case .dropSet: return "D"
        case .failure: return "F"
        }
    }
}

// MARK: - Plan side

struct Exercise: Identifiable, Hashable {
    let id: String
    var name: String
    var description: String?

    /// True for exercises the user added themselves rather than seed data.
    var isUserCreated: Bool { id.hasPrefix(IDPrefix.user.rawValue) }

    init(row: SQLRow) throws {
        id = try row.text("id")
        name = try row.text("name")
        description = row.optionalText("description")
    }

    init(id: String, name: String, description: String?) {
        self.id = id
        self.name = name
        self.description = description
    }
}

/// Aggregate history for one exercise, gathered across every session it appears
/// in. Reachable only because `workout_exercise` records what was performed:
/// the join never goes near a template.
struct ExerciseStats {
    var sessionCount = 0
    var completedSetCount = 0
    var heaviestWeight: Double?
    var bestWeightReps: Int?
    var lastPerformed: Date?
    var planCount = 0
}

struct WorkoutTemplate: Identifiable, Hashable {
    let id: String
    var name: String
    var description: String?
    var notes: String?
    var archivedAt: Date?

    var isArchived: Bool { archivedAt != nil }

    init(row: SQLRow) throws {
        id = try row.text("id")
        name = try row.text("name")
        description = row.optionalText("description")
        notes = row.optionalText("notes")
        archivedAt = row.optionalDate("archived_at")
    }
}

/// A planned set hanging off one plan variant (`exercise_set_template`).
struct PlannedSet: Identifiable, Hashable {
    let id: String
    var ordering: Int
    var setType: SetType?
    var repCount: Int?
    var weight: Double?
    var unit: String?
    var restTime: Int
    var rir: Double?
    var rpe: Double?

    init(row: SQLRow) throws {
        id = try row.text("id")
        ordering = try row.int("ordering")
        setType = row.optionalText("set_type").flatMap(SetType.init(rawValue:))
        repCount = row.optionalInt("rep_count")
        weight = row.optionalDouble("weight")
        unit = row.optionalText("unit")
        restTime = row.optionalInt("rest_time") ?? 0
        rir = row.optionalDouble("rir")
        rpe = row.optionalDouble("rpe")
    }
}

/// One row of `exercise_for_workout_template`: a specific exercise offered in a
/// specific `(block, within, index)` slot of a plan.
struct PlanVariant: Identifiable, Hashable {
    let id: String
    var exerciseID: String
    var exerciseName: String
    var block: Int
    var within: Int
    var exerciseIndex: Int
    var notes: String?
    var archivedAt: Date?
    var plannedSets: [PlannedSet] = []

    var isArchived: Bool { archivedAt != nil }
    /// `exercise_index == 0` is the slot's default pick; 1, 2, … are swaps.
    var isDefault: Bool { exerciseIndex == 0 }

    init(row: SQLRow) throws {
        id = try row.text("id")
        exerciseID = try row.text("exercise_id")
        exerciseName = try row.text("exercise_name")
        block = try row.int("block_ordering")
        within = try row.int("within_block_ordering")
        exerciseIndex = try row.int("exercise_index")
        notes = row.optionalText("notes")
        archivedAt = row.optionalDate("archived_at")
    }
}

/// One `(block, within)` slot and every variant that can fill it.
///
/// A slot is the unit you pick from when starting a session: exactly one of its
/// variants ends up in the record.
struct PlanSlot: Identifiable, Hashable {
    var block: Int
    var within: Int
    var variants: [PlanVariant]

    var id: String { "\(block)-\(within)" }

    /// Variants offered in the picker. Archived ones are hidden here but remain
    /// in `variants` so history and provenance still resolve.
    var activeVariants: [PlanVariant] { variants.filter { !$0.isArchived } }

    /// The pick used unless the user swaps: lowest active `exercise_index`.
    var defaultVariant: PlanVariant? { activeVariants.first }

    var swaps: [PlanVariant] { Array(activeVariants.dropFirst()) }
}

/// A superset / circuit — or, for a straight exercise, a block of one.
struct PlanBlock: Identifiable, Hashable {
    var block: Int
    var slots: [PlanSlot]

    var id: Int { block }

    /// More than one leg in the block means you alternate between them.
    var isSuperset: Bool { slots.count > 1 }
}

/// A plan with its full variant tree.
struct TemplateDetail {
    var template: WorkoutTemplate
    var variants: [PlanVariant]

    /// Groups the flat variant list into blocks → slots → variants, the shape
    /// the plan is actually read in.
    var blocks: [PlanBlock] {
        let byBlock = Dictionary(grouping: variants, by: \.block)
        return byBlock.keys.sorted().map { block in
            let bySlot = Dictionary(grouping: byBlock[block] ?? [], by: \.within)
            let slots = bySlot.keys.sorted().map { within in
                PlanSlot(
                    block: block,
                    within: within,
                    variants: (bySlot[within] ?? []).sorted { $0.exerciseIndex < $1.exerciseIndex })
            }
            return PlanBlock(block: block, slots: slots)
        }
    }

    /// Every slot in plan order — what the "start a session" picker walks.
    var slots: [PlanSlot] { blocks.flatMap(\.slots) }
}

// MARK: - Record side

struct WorkoutSummary: Identifiable, Hashable {
    let id: String
    /// NULL once the plan it came from is hard-deleted. History doesn't care.
    var templateID: String?
    var templateName: String?
    var startTime: Date?
    var stopTime: Date?
    var exerciseCount: Int
    var completedSetCount: Int

    var isInProgress: Bool { startTime != nil && stopTime == nil }

    var duration: TimeInterval? {
        guard let startTime else { return nil }
        return (stopTime ?? Date()).timeIntervalSince(startTime)
    }

    /// What to call this session now that the plan may be long gone.
    var title: String { templateName ?? "Session" }

    init(row: SQLRow) throws {
        id = try row.text("id")
        templateID = row.optionalText("template_id")
        templateName = row.optionalText("template_name")
        startTime = row.optionalDate("start_time")
        stopTime = row.optionalDate("stop_time")
        exerciseCount = row.optionalInt("exercise_count") ?? 0
        completedSetCount = row.optionalInt("completed_set_count") ?? 0
    }
}

/// A set as performed (`exercise_set`). Its exercise, session and position all
/// come from its parent `workout_exercise` — nothing is copied down here to
/// drift out of sync.
struct RecordSet: Identifiable, Hashable {
    let id: String
    var ordering: Int?
    var attemptNumber: Int
    var setType: SetType
    var repCount: Int?
    var weight: Double?
    var unit: String?
    var restTime: Int
    var isCompleted: Bool
    var notes: String?

    /// Second and later tries at the same set slot — a missed lockout, a
    /// rest-pause continuation.
    var isRetry: Bool { attemptNumber > 1 }

    init(row: SQLRow) throws {
        id = try row.text("id")
        ordering = row.optionalInt("ordering")
        attemptNumber = row.optionalInt("attempt_number") ?? 1
        setType = SetType(rawValue: try row.text("set_type")) ?? .regularSet
        repCount = row.optionalInt("rep_count")
        weight = row.optionalDouble("weight")
        unit = row.optionalText("unit")
        restTime = row.optionalInt("rest_time") ?? 0
        isCompleted = (row.optionalInt("is_completed") ?? 0) != 0
        notes = row.optionalText("notes")
    }
}

/// One leg of one session (`workout_exercise`) — the row that makes a logged
/// workout self-contained.
struct RecordExercise: Identifiable, Hashable {
    let id: String
    var exerciseID: String
    var exerciseName: String
    var block: Int
    var within: Int
    /// Provenance back to the picked plan slot. Nil once the plan is gone —
    /// severed, with no effect on anything else here.
    var sourceVariantID: String?
    var notes: String?
    var sets: [RecordSet] = []

    var completedSets: [RecordSet] { sets.filter(\.isCompleted) }

    /// Sign-aware per the schema: negative weight is assistance removed from
    /// bodyweight, so it contributes no external volume.
    var volume: Double {
        completedSets.reduce(0) { total, set in
            total + Double(set.repCount ?? 0) * max(set.weight ?? 0, 0)
        }
    }

    init(row: SQLRow) throws {
        id = try row.text("id")
        exerciseID = try row.text("exercise_id")
        exerciseName = try row.text("exercise_name")
        block = try row.int("block_ordering")
        within = try row.int("within_block_ordering")
        sourceVariantID = row.optionalText("source_variant_id")
        notes = row.optionalText("notes")
    }
}

/// A block as performed. Same shape as `PlanBlock`, built from record rows only.
struct RecordBlock: Identifiable, Hashable {
    var block: Int
    var exercises: [RecordExercise]

    var id: Int { block }

    var isSuperset: Bool { exercises.count > 1 }
}

struct WorkoutDetail {
    var summary: WorkoutSummary
    var exercises: [RecordExercise]

    var blocks: [RecordBlock] {
        let byBlock = Dictionary(grouping: exercises, by: \.block)
        return byBlock.keys.sorted().map { block in
            RecordBlock(
                block: block,
                exercises: (byBlock[block] ?? []).sorted { $0.within < $1.within })
        }
    }

    var totalVolume: Double { exercises.reduce(0) { $0 + $1.volume } }

    var completedSetCount: Int { exercises.reduce(0) { $0 + $1.completedSets.count } }

    var plannedSetCount: Int { exercises.reduce(0) { $0 + $1.sets.count } }

    /// True when at least one leg still points at the plan slot it came from.
    /// False after the plan is deleted — the session reads back exactly the
    /// same either way, which is the guarantee worth showing.
    var hasProvenance: Bool { exercises.contains { $0.sourceVariantID != nil } }
}
