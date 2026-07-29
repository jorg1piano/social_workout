import Foundation
import Observation

/// App-wide state: the open database, the repository over it, and the two
/// things every screen needs — a way to report an error and a way to know the
/// data changed.
///
/// Screens load what they need on appear and reload when `dataVersion` bumps.
/// With a local database where every read is sub-millisecond, that's cheaper
/// and far easier to follow than keeping a cache in sync by hand.
@MainActor
@Observable
final class AppModel {
    private(set) var repository: WorkoutRepository
    private(set) var dataVersion = 0

    /// Set when a write fails. Constraint violations land here too — they are
    /// the model telling the user something legitimate ("that slot is taken"),
    /// not a crash.
    var errorMessage: String?

    /// The session currently running, if there is one. Kept here rather than in
    /// a screen so the Run tab can resume it after a relaunch.
    var activeWorkoutID: String?

    init(repository: WorkoutRepository) {
        self.repository = repository
        activeWorkoutID = repository.activeWorkout()?.id
    }

    convenience init(database: SQLiteDatabase) {
        self.init(repository: WorkoutRepository(database: database))
    }

    /// Runs a write, surfacing any failure and telling every screen to reload.
    /// Returns true when it succeeded.
    @discardableResult
    func perform(_ action: () throws -> Void) -> Bool {
        do {
            try action()
            dataVersion += 1
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// `perform` for writes that produce something — a new row's ID, usually.
    /// Returns nil when the write failed.
    func performReturning<T>(_ action: () throws -> T) -> T? {
        do {
            let result = try action()
            dataVersion += 1
            return result
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// A write that deliberately does *not* bump `dataVersion`: used for
    /// keystroke-by-keystroke edits, where reloading the screen mid-typing
    /// would fight the text field for control of its own contents.
    func performQuietly(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Reloads every screen without writing anything.
    func refresh() {
        dataVersion += 1
    }

    /// Throws away the local database and re-seeds it from the canonical SQL —
    /// the app's `just web-reset`. Useful after exploring destructive edits.
    func resetDatabase() {
        do {
            repository = WorkoutRepository(database: try AppDatabase.reset())
            activeWorkoutID = repository.activeWorkout()?.id
            dataVersion += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
