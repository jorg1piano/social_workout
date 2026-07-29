import Foundation
import SQLite3

/// SQLite tells us to copy bound strings/blobs rather than borrow them, which
/// is what `SQLITE_TRANSIENT` means. The C macro doesn't survive into Swift.
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// A value as SQLite stores it. The schema only uses TEXT / INTEGER / REAL
/// (times are unix seconds, booleans are 0/1), so there's no blob case.
enum SQLValue: Equatable {
    case null
    case integer(Int64)
    case real(Double)
    case text(String)
}

/// Anything that can be bound to a `?` placeholder.
protocol SQLParameter {
    var sqlValue: SQLValue { get }
}

extension String: SQLParameter {
    var sqlValue: SQLValue { .text(self) }
}

extension Int: SQLParameter {
    var sqlValue: SQLValue { .integer(Int64(self)) }
}

extension Int64: SQLParameter {
    var sqlValue: SQLValue { .integer(self) }
}

extension Double: SQLParameter {
    var sqlValue: SQLValue { .real(self) }
}

extension Bool: SQLParameter {
    var sqlValue: SQLValue { .integer(self ? 1 : 0) }
}

extension Date: SQLParameter {
    /// Unix seconds — the schema's time representation everywhere.
    var sqlValue: SQLValue { .integer(Int64(timeIntervalSince1970)) }
}

enum DatabaseError: LocalizedError {
    case open(path: String, message: String)
    case statement(message: String, sql: String)
    case constraint(message: String, sql: String)
    case missingColumn(String)
    case missingRow(String)
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case let .open(path, message):
            return "Could not open the database at \(path): \(message)"
        case let .statement(message, _):
            return message
        case let .constraint(message, _):
            return message
        case let .missingColumn(column):
            return "Query result has no column named '\(column)'"
        case let .missingRow(what):
            return "\(what) no longer exists"
        case let .missingResource(name):
            return "Bundled SQL resource '\(name)' is missing from the app bundle"
        }
    }

    /// True when SQLite rejected the write because of a CHECK / UNIQUE /
    /// FOREIGN KEY constraint. The plan tree leans on uniqueness constraints
    /// (`idx_variant`, `idx_variant_exercise`, `idx_exercise_set_attempt`) to
    /// enforce its rules, so the UI shows these to the user rather than
    /// treating them as crashes — the same distinction the model explorer
    /// makes when it answers 409 instead of 500.
    var isConstraintViolation: Bool {
        if case .constraint = self { return true }
        return false
    }
}

/// One row of a result set, addressed by column name.
struct SQLRow {
    private let values: [String: SQLValue]

    init(values: [String: SQLValue]) {
        self.values = values
    }

    func text(_ column: String) throws -> String {
        guard case let .text(value) = try require(column) else {
            throw DatabaseError.missingColumn(column)
        }
        return value
    }

    func int(_ column: String) throws -> Int {
        guard let value = optionalInt(column) else { throw DatabaseError.missingColumn(column) }
        return value
    }

    func bool(_ column: String) throws -> Bool {
        try int(column) != 0
    }

    func date(_ column: String) throws -> Date {
        Date(timeIntervalSince1970: Double(try int(column)))
    }

    func optionalText(_ column: String) -> String? {
        if case let .text(value) = values[column] { return value }
        return nil
    }

    func optionalInt(_ column: String) -> Int? {
        switch values[column] {
        case let .integer(value): return Int(value)
        case let .real(value): return Int(value)
        case let .text(value): return Int(value)
        default: return nil
        }
    }

    func optionalDouble(_ column: String) -> Double? {
        switch values[column] {
        case let .real(value): return value
        case let .integer(value): return Double(value)
        case let .text(value): return Double(value)
        default: return nil
        }
    }

    /// Unix-seconds column as a `Date`; nil when the column is NULL — which is
    /// meaningful all over this schema (`archived_at`, `stop_time`).
    func optionalDate(_ column: String) -> Date? {
        optionalInt(column).map { Date(timeIntervalSince1970: Double($0)) }
    }

    private func require(_ column: String) throws -> SQLValue {
        guard let value = values[column] else { throw DatabaseError.missingColumn(column) }
        return value
    }
}

/// A thin, synchronous wrapper over the system libsqlite3.
///
/// Synchronous on purpose: this is a single-user, on-device database of a few
/// thousand rows where every query is sub-millisecond, and the alternative —
/// an async actor — would buy nothing but ceremony. The one genuinely slow
/// operation is first-launch seeding, which happens once, behind the launch
/// screen, before any of this is on screen to block.
final class SQLiteDatabase {
    private var handle: OpaquePointer?

    /// Opens (creating if needed) the database at `path` with foreign keys ON.
    ///
    /// SQLite defaults `foreign_keys` to OFF *per connection*, and this model
    /// puts real weight on FK behaviour — ON DELETE CASCADE from workout down
    /// to sets, ON DELETE SET NULL for provenance, ON DELETE RESTRICT for
    /// exercises still in use. Without this pragma the model silently stops
    /// being the model.
    init(path: String) throws {
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(path, &handle, flags, nil) == SQLITE_OK, handle != nil else {
            let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            sqlite3_close_v2(handle)
            handle = nil
            throw DatabaseError.open(path: path, message: message)
        }
        try executeScript("PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 5000;")
    }

    deinit {
        sqlite3_close_v2(handle)
    }

    /// Runs a multi-statement SQL script (schema DDL, seed files, pragmas).
    func executeScript(_ sql: String) throws {
        var errorPointer: UnsafeMutablePointer<CChar>?
        let status = sqlite3_exec(handle, sql, nil, nil, &errorPointer)
        guard status == SQLITE_OK else {
            let message = errorPointer.map { String(cString: $0) } ?? "unknown error"
            sqlite3_free(errorPointer)
            throw error(status: status, message: message, sql: sql)
        }
    }

    func query(_ sql: String, _ parameters: [SQLParameter?] = []) throws -> [SQLRow] {
        let statement = try prepare(sql, parameters)
        defer { sqlite3_finalize(statement) }

        let columnNames = (0..<sqlite3_column_count(statement)).map {
            String(cString: sqlite3_column_name(statement, $0))
        }

        var rows: [SQLRow] = []
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else {
                throw error(status: status, message: lastErrorMessage, sql: sql)
            }
            var values: [String: SQLValue] = [:]
            for (index, name) in columnNames.enumerated() {
                values[name] = value(of: statement, at: Int32(index))
            }
            rows.append(SQLRow(values: values))
        }
        return rows
    }

    /// Runs a statement that returns no rows. Returns the number of rows changed.
    @discardableResult
    func execute(_ sql: String, _ parameters: [SQLParameter?] = []) throws -> Int {
        let statement = try prepare(sql, parameters)
        defer { sqlite3_finalize(statement) }

        let status = sqlite3_step(statement)
        guard status == SQLITE_DONE || status == SQLITE_ROW else {
            throw error(status: status, message: lastErrorMessage, sql: sql)
        }
        return Int(sqlite3_changes(handle))
    }

    /// First column of the first row, for `SELECT COUNT(*) …` and `PRAGMA`
    /// reads. Positional on purpose: pragmas name their result column after
    /// themselves, so looking one up by an expected name silently returns nil.
    func scalarInt(_ sql: String, _ parameters: [SQLParameter?] = []) throws -> Int? {
        let statement = try prepare(sql, parameters)
        defer { sqlite3_finalize(statement) }

        let status = sqlite3_step(statement)
        if status == SQLITE_DONE { return nil }
        guard status == SQLITE_ROW else {
            throw error(status: status, message: lastErrorMessage, sql: sql)
        }
        guard sqlite3_column_count(statement) > 0,
            sqlite3_column_type(statement, 0) != SQLITE_NULL
        else { return nil }
        return Int(sqlite3_column_int64(statement, 0))
    }

    /// Whether a table exists — how the app tells a fresh database file from a
    /// seeded one.
    func tableExists(_ name: String) throws -> Bool {
        let sql = "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = ?"
        return (try scalarInt(sql, [name]) ?? 0) > 0
    }

    /// Runs `body` inside a transaction, rolling back if it throws.
    ///
    /// Resolving a plan into a record touches three tables and must be
    /// all-or-nothing: a half-started session with no sets to fill in would be
    /// worse than no session at all.
    func transaction<T>(_ body: () throws -> T) throws -> T {
        try executeScript("BEGIN IMMEDIATE")
        do {
            let result = try body()
            try executeScript("COMMIT")
            return result
        } catch {
            // Best-effort rollback: if this throws too, the original error is
            // the one worth surfacing.
            try? executeScript("ROLLBACK")
            throw error
        }
    }

    private func prepare(_ sql: String, _ parameters: [SQLParameter?]) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        let status = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard status == SQLITE_OK else {
            sqlite3_finalize(statement)
            throw error(status: status, message: lastErrorMessage, sql: sql)
        }
        for (offset, parameter) in parameters.enumerated() {
            let index = Int32(offset + 1)
            switch parameter?.sqlValue ?? .null {
            case .null:
                sqlite3_bind_null(statement, index)
            case let .integer(value):
                sqlite3_bind_int64(statement, index, value)
            case let .real(value):
                sqlite3_bind_double(statement, index, value)
            case let .text(value):
                sqlite3_bind_text(statement, index, value, -1, SQLITE_TRANSIENT)
            }
        }
        return statement
    }

    private func value(of statement: OpaquePointer?, at index: Int32) -> SQLValue {
        switch sqlite3_column_type(statement, index) {
        case SQLITE_INTEGER:
            return .integer(sqlite3_column_int64(statement, index))
        case SQLITE_FLOAT:
            return .real(sqlite3_column_double(statement, index))
        case SQLITE_TEXT:
            return .text(String(cString: sqlite3_column_text(statement, index)))
        default:
            return .null
        }
    }

    private var lastErrorMessage: String {
        handle.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
    }

    private func error(status: Int32, message: String, sql: String) -> DatabaseError {
        // The primary result code lives in the low 8 bits; SQLITE_CONSTRAINT
        // arrives extended (e.g. SQLITE_CONSTRAINT_UNIQUE = 2067).
        if status & 0xFF == SQLITE_CONSTRAINT {
            return .constraint(message: message, sql: sql)
        }
        return .statement(message: message, sql: sql)
    }
}
