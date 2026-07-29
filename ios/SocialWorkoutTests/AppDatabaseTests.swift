import XCTest

@testable import SocialWorkout

final class AppDatabaseTests: XCTestCase {
    private var directory: URL!
    private var databaseURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("swdb-\(UUID().uuidString)", isDirectory: true)
        databaseURL = directory.appendingPathComponent("workout.db")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
        try super.tearDownWithError()
    }

    func testSecondLaunchReusesTheSeededDatabase() throws {
        let first = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
        let seededExercises = first.exercises().count
        XCTAssertGreaterThan(seededExercises, 200)

        // Every launch after the first must reuse what's on disk. Re-running
        // the schema here is what "table body_part_category already exists"
        // looks like to the user.
        let second = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
        XCTAssertEqual(second.exercises().count, seededExercises)
    }

    func testUserEditsSurviveARelaunch() throws {
        let first = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
        let created = try first.createExercise(name: "Zercher Squat", description: nil)

        let second = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
        XCTAssertEqual(try second.exercise(id: created.id)?.name, "Zercher Squat")
    }

    func testResetRestoresTheCanonicalSeed() throws {
        let first = WorkoutRepository(database: try AppDatabase.open(at: databaseURL))
        let created = try first.createExercise(name: "Zercher Squat", description: nil)

        let fresh = WorkoutRepository(database: try AppDatabase.reset(at: databaseURL))
        XCTAssertNil(try fresh.exercise(id: created.id))
        XCTAssertGreaterThan(fresh.exercises().count, 200)
    }

    func testScalarReadsPragmasWhoseColumnIsNamedAfterThemselves() throws {
        let database = try AppDatabase.open(at: databaseURL)
        XCTAssertEqual(try database.scalarInt("PRAGMA user_version"), AppDatabase.schemaVersion)
        XCTAssertEqual(try database.scalarInt("PRAGMA foreign_keys"), 1)
    }

    func testForeignKeysAreEnforcedOnTheConnection() throws {
        let database = try AppDatabase.open(at: databaseURL)
        // ON DELETE RESTRICT: an exercise still referenced by a plan can't go.
        let repository = WorkoutRepository(database: database)
        let referenced = try XCTUnwrap(
            repository.templates().first.flatMap { try? repository.template(id: $0.id) }?
                .variants.first?.exerciseID)

        XCTAssertThrowsError(
            try database.execute("DELETE FROM exercise WHERE id = ?", [referenced])
        ) { error in
            XCTAssertTrue((error as? DatabaseError)?.isConstraintViolation == true)
        }
    }
}
