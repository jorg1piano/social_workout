import SwiftUI

/// The shared exercise library — the one table both trees point at.
struct ExercisesView: View {
    @Environment(AppModel.self) private var model
    @State private var searchText = ""
    @State private var exercises: [Exercise] = []
    @State private var isAddingExercise = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(exercises) { exercise in
                        NavigationLink(value: exercise) {
                            ExerciseRow(exercise: exercise)
                        }
                    }
                } header: {
                    Text("\(exercises.count) exercises")
                } footer: {
                    Text(
                        """
                        Definitions shared by every plan and every logged session. \
                        Rename one and the new name shows up everywhere, history \
                        included — it's the same movement, spelled better.
                        """)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Exercises")
            .navigationDestination(for: Exercise.self) { ExerciseDetailView(exercise: $0) }
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { DatabaseMenu() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isAddingExercise = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("New exercise")
                }
            }
            .sheet(isPresented: $isAddingExercise) { NewExerciseSheet() }
            .onAppear(perform: load)
            .onChange(of: model.dataVersion) { load() }
            .onChange(of: searchText) { load() }
        }
    }

    private func load() {
        exercises = model.repository.exercises(matching: searchText)
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 8) {
            Text(exercise.name)
            if exercise.isUserCreated {
                Text("yours")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.accent)
            }
        }
    }
}

/// One exercise: what it is, and everything you've ever done with it.
struct ExerciseDetailView: View {
    @Environment(AppModel.self) private var model

    let exercise: Exercise
    @State private var name: String
    /// What's actually in the database. `exercise` is the value this screen was
    /// pushed with, so it still says the old name after a rename.
    @State private var savedName: String
    @State private var bodyParts: [String] = []
    @State private var equipment: [String] = []
    @State private var stats = ExerciseStats()

    init(exercise: Exercise) {
        self.exercise = exercise
        _name = State(initialValue: exercise.name)
        _savedName = State(initialValue: exercise.name)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $name)
                    .onSubmit(rename)
                if name.trimmingCharacters(in: .whitespaces) != savedName {
                    Button("Save rename", action: rename)
                }
            }

            if let description = exercise.description, !description.isEmpty {
                Section("Description") { Text(description) }
            }

            if !bodyParts.isEmpty || !equipment.isEmpty {
                Section("Tags") {
                    if !bodyParts.isEmpty {
                        LabeledContent("Body parts", value: bodyParts.joined(separator: ", "))
                    }
                    if !equipment.isEmpty {
                        LabeledContent("Equipment", value: equipment.joined(separator: ", "))
                    }
                }
            }

            Section {
                LabeledContent("Sessions", value: "\(stats.sessionCount)")
                LabeledContent("Completed sets", value: "\(stats.completedSetCount)")
                LabeledContent("Heaviest set") {
                    Text(
                        Format.setSummary(
                            reps: stats.bestWeightReps, weight: stats.heaviestWeight, unit: nil))
                }
                LabeledContent("Last performed", value: Format.relative(stats.lastPerformed))
                LabeledContent("Used in plans", value: "\(stats.planCount)")
            } header: {
                HStack {
                    Text("History")
                    ModelSideBadge(side: .record)
                }
            } footer: {
                Text(
                    """
                    Counted across every session, by joining sets to \
                    workout_exercise — no template is involved, so moving this \
                    exercise between plans (or deleting a plan) never loses a set.
                    """)
            }
        }
        .navigationTitle(savedName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
        .onChange(of: model.dataVersion) { load() }
    }

    private func load() {
        bodyParts = model.repository.bodyParts(exerciseID: exercise.id)
        equipment = model.repository.equipment(exerciseID: exercise.id)
        stats = model.repository.stats(exerciseID: exercise.id)
    }

    private func rename() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != savedName else { return }
        if model.perform({ try model.repository.renameExercise(id: exercise.id, to: trimmed) }) {
            savedName = trimmed
            name = trimmed
        }
    }
}

private struct NewExerciseSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
                } footer: {
                    Text("Saved with a usr- ID, marking it as yours rather than seed data.")
                }
            }
            .navigationTitle("New exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func add() {
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        let created = model.performReturning {
            try model.repository.createExercise(
                name: name.trimmingCharacters(in: .whitespaces),
                description: trimmedDescription.isEmpty ? nil : trimmedDescription)
        }
        if created != nil { dismiss() }
    }
}

/// Reset the local store back to the canonical seed — handy after exploring
/// destructive edits like "delete the plan and check history survives".
struct DatabaseMenu: View {
    @Environment(AppModel.self) private var model
    @State private var isConfirmingReset = false

    var body: some View {
        Menu {
            Button("Reset to seed data…", systemImage: "arrow.counterclockwise") {
                isConfirmingReset = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .confirmationDialog(
            "Reset the database?", isPresented: $isConfirmingReset, titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) { model.resetDatabase() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deletes everything on this device and re-seeds from the canonical SQL.")
        }
    }
}

/// Marks a screen or section as belonging to the plan or the record tree.
struct ModelSideBadge: View {
    let side: ModelSide

    var body: some View {
        Text(side.rawValue)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(side.color.opacity(0.18), in: Capsule())
            .foregroundStyle(side.color)
    }
}
