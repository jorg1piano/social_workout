import SwiftUI

@main
struct SocialWorkoutApp: App {
    @State private var launch = LaunchState.opening

    var body: some Scene {
        WindowGroup {
            switch launch {
            case .opening:
                ProgressView("Preparing your library…")
                    .task { launch = LaunchState.open() }
            case let .ready(model):
                RootView()
                    .environment(model)
            case let .failed(message):
                LaunchFailureView(message: message)
            }
        }
    }
}

/// Opening the database is the one thing that can fail before there is any UI
/// to report it in, so it gets its own state rather than a force-try.
enum LaunchState {
    case opening
    case ready(AppModel)
    case failed(String)

    /// Launch with `-resetStore` to start from the canonical seed. UI tests
    /// pass it so each run begins from known data instead of whatever the last
    /// run left behind.
    static let resetArgument = "-resetStore"

    @MainActor
    static func open() -> LaunchState {
        do {
            let shouldReset = ProcessInfo.processInfo.arguments.contains(resetArgument)
            let database = try shouldReset ? AppDatabase.reset() : AppDatabase.open()
            return .ready(AppModel(database: database))
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}

private struct LaunchFailureView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't open the database", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        }
    }
}
