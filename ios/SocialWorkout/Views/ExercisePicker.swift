import SwiftUI

/// Searchable list of the exercise library, used wherever something needs an
/// exercise chosen — adding a variant to a plan, mostly.
struct ExercisePicker: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSelect: (Exercise) -> Void

    @State private var searchText = ""
    @State private var exercises: [Exercise] = []

    var body: some View {
        List(exercises) { exercise in
            Button {
                onSelect(exercise)
                dismiss()
            } label: {
                HStack {
                    Text(exercise.name).foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search exercises")
        .onAppear(perform: load)
        .onChange(of: searchText) { load() }
    }

    private func load() {
        exercises = model.repository.exercises(matching: searchText)
    }
}
