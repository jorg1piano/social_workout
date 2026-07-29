import XCTest

@testable import SocialWorkout

/// The plan-vs-record invariants, asserted through the app's own API.
///
/// `sqlite/tests/run.sh` proves these at the SQL level. These tests prove the
/// Swift layer actually preserves them — that resolving a plan copies what it
/// must, and that reading a session back never quietly reaches for a template.
final class PlanRecordTests: XCTestCase {
    private var databaseURL: URL!
    private var repository: WorkoutRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        databaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("swtests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("workout.db")
        // Seeded from the canonical sqlite/*.sql bundled with the host app —
        // the same files the Go explorer and the SQL tests run against.
        repository = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
    }

    override func tearDownWithError() throws {
        repository = nil
        try? FileManager.default.removeItem(at: databaseURL.deletingLastPathComponent())
        try super.tearDownWithError()
    }

    // MARK: Helpers

    private func template(named name: String) throws -> TemplateDetail {
        let summary = try XCTUnwrap(
            repository.templates(includeArchived: true).first { $0.name == name },
            "seed data has no template named \(name)")
        return try XCTUnwrap(repository.template(id: summary.id))
    }

    /// Starts a session taking every slot's default pick.
    private func startWithDefaults(_ detail: TemplateDetail) throws -> String {
        let picks = detail.slots.compactMap { $0.defaultVariant?.id }
        return try repository.startWorkout(templateID: detail.template.id, picks: picks)
    }

    // MARK: Bootstrap

    func testBootstrapSeedsTheCanonicalLibraryAndPlans() throws {
        XCTAssertGreaterThan(repository.exercises().count, 200)
        let names = Set(repository.templates().map(\.name))
        XCTAssertTrue(names.isSuperset(of: ["Push Day", "Pull Day", "Leg Day"]))
    }

    func testSeededPlanExposesSupersetsAndSwapVariants() throws {
        let legDay = try template(named: "Leg Day")
        XCTAssertTrue(
            legDay.blocks.contains { $0.isSuperset },
            "Leg Day should contain a superset — a block with more than one leg")

        let pushDay = try template(named: "Push Day")
        let slotWithSwap = try XCTUnwrap(pushDay.slots.first { $0.activeVariants.count > 1 })
        XCTAssertEqual(slotWithSwap.defaultVariant?.exerciseIndex, 0)
        XCTAssertFalse(slotWithSwap.swaps.isEmpty)
    }

    // MARK: Resolving a plan into a record

    func testStartingCopiesOrderAndMaterializesPlannedSets() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        let session = try XCTUnwrap(repository.workout(id: workoutID))

        let picks = plan.slots.compactMap(\.defaultVariant)
        XCTAssertEqual(session.exercises.count, picks.count)

        for (performed, picked) in zip(session.exercises, picks) {
            XCTAssertEqual(performed.exerciseID, picked.exerciseID)
            XCTAssertEqual(performed.block, picked.block)
            XCTAssertEqual(performed.within, picked.within)
            XCTAssertEqual(performed.sourceVariantID, picked.id, "provenance pointer not set")
            XCTAssertEqual(
                performed.sets.count, picked.plannedSets.count,
                "planned sets were not materialized for \(picked.exerciseName)")
        }
        XCTAssertEqual(session.completedSetCount, 0, "materialized sets must start not-completed")
    }

    func testStartingRecordsTheSwapYouPickedNotTheDefault() throws {
        let plan = try template(named: "Push Day")
        let slot = try XCTUnwrap(plan.slots.first { $0.swaps.count > 0 })
        let swap = try XCTUnwrap(slot.swaps.first)

        let workoutID = try repository.startWorkout(
            templateID: plan.template.id, picks: [swap.id])
        let session = try XCTUnwrap(repository.workout(id: workoutID))

        XCTAssertEqual(session.exercises.count, 1)
        XCTAssertEqual(session.exercises[0].exerciseID, swap.exerciseID)
        XCTAssertNotEqual(session.exercises[0].exerciseID, slot.defaultVariant?.exerciseID)
    }

    func testStartingIsAllOrNothing() throws {
        let plan = try template(named: "Push Day")
        let good = try XCTUnwrap(plan.slots.first?.defaultVariant?.id)
        let before = repository.workouts().count

        XCTAssertThrowsError(
            try repository.startWorkout(templateID: plan.template.id, picks: [good, "app-nope"]))
        XCTAssertEqual(repository.workouts().count, before, "a failed start left a workout behind")
    }

    // MARK: The self-documenting guarantee

    func testSessionReadsBackIdenticallyAfterItsPlanIsDeleted() throws {
        let plan = try template(named: "Leg Day")
        let workoutID = try startWithDefaults(plan)

        let before = try XCTUnwrap(repository.workout(id: workoutID))
        XCTAssertTrue(before.hasProvenance)

        try repository.deleteTemplate(id: plan.template.id)
        let after = try XCTUnwrap(repository.workout(id: workoutID))

        XCTAssertEqual(
            after.exercises.map(\.exerciseName), before.exercises.map(\.exerciseName))
        XCTAssertEqual(
            after.exercises.map(\.block), before.exercises.map(\.block))
        XCTAssertEqual(
            after.exercises.map(\.within), before.exercises.map(\.within))
        XCTAssertEqual(
            after.exercises.map { $0.sets.count }, before.exercises.map { $0.sets.count })

        // Only the links to the plan are gone.
        XCTAssertNil(after.summary.templateID)
        XCTAssertFalse(after.hasProvenance)
        XCTAssertTrue(after.exercises.allSatisfy { $0.sourceVariantID == nil })
    }

    func testArchivingAVariantHidesItFromPickingWithoutTouchingHistory() throws {
        let plan = try template(named: "Push Day")
        let slot = try XCTUnwrap(plan.slots.first { $0.activeVariants.count > 1 })
        let variant = try XCTUnwrap(slot.defaultVariant)
        let workoutID = try repository.startWorkout(
            templateID: plan.template.id, picks: [variant.id])

        try repository.setVariantArchived(id: variant.id, archived: true)

        let reloaded = try XCTUnwrap(repository.template(id: plan.template.id))
        let reloadedSlot = try XCTUnwrap(
            reloaded.slots.first { $0.block == slot.block && $0.within == slot.within })
        XCTAssertFalse(reloadedSlot.activeVariants.contains { $0.id == variant.id })
        XCTAssertTrue(reloadedSlot.variants.contains { $0.id == variant.id })

        // Provenance still resolves — archiving carries no historical weight.
        let session = try XCTUnwrap(repository.workout(id: workoutID))
        XCTAssertEqual(session.exercises.first?.sourceVariantID, variant.id)
    }

    // MARK: Plan constraints surface as constraint errors

    func testDuplicateSlotIsRejectedAsAConstraintViolation() throws {
        let plan = try template(named: "Push Day")
        let existing = try XCTUnwrap(plan.slots.first?.defaultVariant)
        let otherExercise = try XCTUnwrap(
            repository.exercises().first { $0.id != existing.exerciseID })

        XCTAssertThrowsError(
            try repository.addVariant(
                templateID: plan.template.id,
                exerciseID: otherExercise.id,
                block: existing.block,
                within: existing.within,
                exerciseIndex: existing.exerciseIndex)
        ) { error in
            XCTAssertTrue((error as? DatabaseError)?.isConstraintViolation == true)
        }
    }

    func testSameExerciseTwiceInASlotIsRejectedSoSwapBackReactivates() throws {
        let plan = try template(named: "Push Day")
        let existing = try XCTUnwrap(plan.slots.first?.defaultVariant)
        let takenIndices = try XCTUnwrap(
            plan.slots.first { $0.block == existing.block && $0.within == existing.within })
            .variants.map(\.exerciseIndex)

        XCTAssertThrowsError(
            try repository.addVariant(
                templateID: plan.template.id,
                exerciseID: existing.exerciseID,
                block: existing.block,
                within: existing.within,
                exerciseIndex: (takenIndices.max() ?? 0) + 1)
        ) { error in
            XCTAssertTrue((error as? DatabaseError)?.isConstraintViolation == true)
        }
    }

    // MARK: Logging

    func testCompletingSetsCountsTowardVolumeAndStats() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        let session = try XCTUnwrap(repository.workout(id: workoutID))
        let leg = try XCTUnwrap(session.exercises.first)
        let set = try XCTUnwrap(leg.sets.first)
        // The seed data already contains logged sessions for this exercise, so
        // stats are compared as a delta rather than against a clean slate —
        // which is the point: they accumulate across every session.
        let before = repository.stats(exerciseID: leg.exerciseID)

        try repository.updateSet(id: set.id, repCount: .some(5), weight: .some(100), isCompleted: true)

        let updated = try XCTUnwrap(repository.workout(id: workoutID))
        XCTAssertEqual(updated.completedSetCount, 1)
        XCTAssertEqual(updated.totalVolume, 500)

        let after = repository.stats(exerciseID: leg.exerciseID)
        XCTAssertEqual(after.completedSetCount, before.completedSetCount + 1)
        XCTAssertEqual(after.sessionCount, before.sessionCount + 1)
        XCTAssertEqual(after.heaviestWeight, max(before.heaviestWeight ?? 0, 100))
    }

    func testRetryingASetKeepsTheSetNumberAndBumpsTheAttempt() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        let leg = try XCTUnwrap(try repository.workout(id: workoutID)?.exercises.first)
        let set = try XCTUnwrap(leg.sets.first)

        try repository.addAttempt(to: set, workoutExerciseID: leg.id)

        let reloaded = try XCTUnwrap(
            try repository.workout(id: workoutID)?.exercises.first)
        let attempts = reloaded.sets.filter { $0.ordering == set.ordering }
        XCTAssertEqual(attempts.count, 2)
        XCTAssertEqual(attempts.map(\.attemptNumber).sorted(), [1, 2])
    }

    func testAddedSetTakesTheNextSetNumber() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        let leg = try XCTUnwrap(try repository.workout(id: workoutID)?.exercises.first)
        let highest = leg.sets.compactMap(\.ordering).max() ?? 0

        try repository.addSet(workoutExerciseID: leg.id, repCount: 8, weight: 60, unit: "kg")

        let reloaded = try XCTUnwrap(try repository.workout(id: workoutID)?.exercises.first)
        XCTAssertEqual(reloaded.sets.compactMap(\.ordering).max(), highest + 1)
    }

    func testPreviousSetsLookAcrossSessionsWithoutATemplateJoin() throws {
        let plan = try template(named: "Push Day")
        let firstID = try startWithDefaults(plan)
        let firstLeg = try XCTUnwrap(try repository.workout(id: firstID)?.exercises.first)
        for set in firstLeg.sets {
            try repository.updateSet(id: set.id, repCount: .some(6), weight: .some(90), isCompleted: true)
        }
        try repository.finishWorkout(id: firstID)

        // Delete the plan before looking back, to prove the lookup doesn't need it.
        try repository.deleteTemplate(id: plan.template.id)

        let secondID = try repository.startWorkout(
            templateID: try template(named: "Pull Day").template.id,
            picks: [try XCTUnwrap(try template(named: "Pull Day").slots.first?.defaultVariant?.id)])

        let previous = repository.previousSets(
            exerciseID: firstLeg.exerciseID, excludingWorkoutID: secondID)
        XCTAssertEqual(previous.count, firstLeg.sets.count)
        XCTAssertTrue(previous.allSatisfy { $0.weight == 90 && $0.repCount == 6 })
    }

    func testDeletingASessionLeavesOtherSessionsAndThePlanAlone() throws {
        let plan = try template(named: "Push Day")
        let doomedID = try startWithDefaults(plan)
        let survivorID = try startWithDefaults(plan)

        try repository.deleteWorkout(id: doomedID)

        XCTAssertNil(try repository.workout(id: doomedID))
        XCTAssertNotNil(try repository.workout(id: survivorID))
        XCTAssertNotNil(try repository.template(id: plan.template.id))
    }

    func testRenamingAnExercisePropagatesIntoLoggedSessions() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        let leg = try XCTUnwrap(try repository.workout(id: workoutID)?.exercises.first)

        try repository.renameExercise(id: leg.exerciseID, to: "Barbell Bench Press (comp grip)")

        let reloaded = try XCTUnwrap(try repository.workout(id: workoutID)?.exercises.first)
        XCTAssertEqual(reloaded.exerciseName, "Barbell Bench Press (comp grip)")
    }

    func testFinishingStampsTheStopTime() throws {
        let plan = try template(named: "Push Day")
        let workoutID = try startWithDefaults(plan)
        XCTAssertTrue(try XCTUnwrap(repository.workout(id: workoutID)).summary.isInProgress)

        try repository.finishWorkout(id: workoutID)

        let finished = try XCTUnwrap(repository.workout(id: workoutID)).summary
        XCTAssertFalse(finished.isInProgress)
        XCTAssertNotNil(finished.stopTime)
    }

    func testUserCreatedRowsUseTheUsrPrefix() throws {
        let exercise = try repository.createExercise(name: "Jefferson Curl", description: nil)
        XCTAssertTrue(exercise.isUserCreated)

        let templateID = try repository.createTemplate(name: "Mobility", description: nil)
        XCTAssertTrue(templateID.hasPrefix(IDPrefix.user.rawValue))
    }
}
