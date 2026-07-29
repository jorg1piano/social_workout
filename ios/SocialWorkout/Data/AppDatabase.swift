import Foundation

/// Opens the app's SQLite file and, on first launch, bootstraps it from the
/// canonical SQL in the repository's `sqlite/` directory.
///
/// The three scripts are *referenced*, not copied, by the Xcode project — they
/// are the same files `just db`, the model explorer and the SQL model tests
/// run against — so there is exactly one source of truth for the schema and no
/// parity check to remember. In dependency order:
///
///   1. `schema.sql`             — DDL for every table + index.
///   2. `exercises_complete.sql` — the shared exercise library, with its body
///                                 part and equipment tags.
///   3. `new-test-data.sql`      — Push/Pull/Leg plans with supersets and swap
///                                 variants, plus logged sessions to read back.
enum AppDatabase {
    /// Scripts run, in order, against a fresh database.
    static let bootstrapScripts = ["schema", "exercises_complete", "new-test-data"]

    /// Bumped when the bundled SQL changes shape. Stored in `PRAGMA
    /// user_version`, which is how we tell a fresh file from a seeded one.
    static let schemaVersion = 1

    static var storeURL: URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SocialWorkout", isDirectory: true)
        return root.appendingPathComponent("workout.db")
    }

    /// Opens the database, seeding it if it hasn't been seeded yet.
    static func open(at url: URL = storeURL, bundle: Bundle = .main) throws -> SQLiteDatabase {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        let database = try SQLiteDatabase(path: url.path)
        // Gate on the schema actually being there rather than on the version
        // stamp alone: if a previous launch died mid-bootstrap, a stale stamp
        // would skip seeding and leave the app pointed at an empty database.
        if try !database.tableExists("exercise") {
            try bootstrap(database, bundle: bundle)
        }
        return database
    }

    /// Deletes the store and re-seeds it from the canonical SQL — the app's
    /// equivalent of `just web-reset`, for when you've mangled a plan while
    /// exploring and want the sample data back.
    static func reset(at url: URL = storeURL, bundle: Bundle = .main) throws -> SQLiteDatabase {
        let manager = FileManager.default
        // -wal and -shm siblings must go too, or the fresh file inherits pages
        // from the old one.
        for suffix in ["", "-wal", "-shm"] {
            let sibling = URL(fileURLWithPath: url.path + suffix)
            if manager.fileExists(atPath: sibling.path) {
                try manager.removeItem(at: sibling)
            }
        }
        return try open(at: url, bundle: bundle)
    }

    /// Runs every bootstrap script in a single transaction, so a bad seed file
    /// rolls back cleanly rather than leaving a half-populated database on disk.
    private static func bootstrap(_ database: SQLiteDatabase, bundle: Bundle) throws {
        let scripts = try bootstrapScripts.map { try loadScript(named: $0, from: bundle) }
        try database.transaction {
            for script in scripts {
                try database.executeScript(script)
            }
        }
        // PRAGMA statements are no-ops inside a transaction on some builds, so
        // stamp the version after committing.
        try database.executeScript("PRAGMA user_version = \(schemaVersion)")
    }

    private static func loadScript(named name: String, from bundle: Bundle) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: "sql") else {
            throw DatabaseError.missingResource("\(name).sql")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
