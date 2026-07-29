import SwiftUI

/// The four tabs follow the two trees in the model, in the order you use them:
/// build the exercise library, arrange it into plans, run a plan, read the
/// record back.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        TabView {
            ExercisesView()
                .tabItem { Label("Exercises", systemImage: "figure.strengthtraining.traditional") }
            PlansView()
                .tabItem { Label("Plans", systemImage: "list.bullet.rectangle") }
            RunView()
                .tabItem { Label("Run", systemImage: "play.circle") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }),
            presenting: model.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }
}
