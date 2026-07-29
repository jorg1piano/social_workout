import SwiftUI

/// Everything you've logged, read back from the record tree alone.
struct HistoryView: View {
    @Environment(AppModel.self) private var model
    @State private var workouts: [WorkoutSummary] = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(workouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutRow(workout: workout)
                        }
                        .accessibilityIdentifier("session-row")
                    }
                    if workouts.isEmpty {
                        Text("Nothing logged yet.").foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Sessions")
                        ModelSideBadge(side: .record)
                    }
                } footer: {
                    Text(
                        """
                        Rendered from workout → workout_exercise → exercise_set, \
                        with no template join anywhere. A session that came from a \
                        plan since deleted reads back exactly the same.
                        """)
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: WorkoutSummary.self) {
                WorkoutDetailView(workoutID: $0.id)
            }
            .onAppear(perform: load)
            .onChange(of: model.dataVersion) { load() }
        }
    }

    private func load() {
        workouts = model.repository.workouts()
    }
}

private struct WorkoutRow: View {
    let workout: WorkoutSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(workout.title)
                if workout.isInProgress {
                    Tag(text: "in progress", color: Theme.record)
                }
                if workout.templateID == nil {
                    Tag(text: "plan deleted", color: .secondary)
                }
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var subtitle: String {
        var parts = [Format.date(workout.startTime)]
        if !workout.isInProgress {
            parts.append(Format.duration(workout.duration))
        }
        parts.append("\(workout.exerciseCount) exercises")
        parts.append("\(workout.completedSetCount) sets")
        return parts.joined(separator: " · ")
    }
}

/// A single session, in full.
///
/// Nothing on this screen is read through a template — not the exercise order,
/// not the names, not the sets. The one place the plan appears is the
/// provenance line at the bottom, and that line is allowed to say "gone".
struct WorkoutDetailView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let workoutID: String

    @State private var detail: WorkoutDetail?
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            if let detail {
                summarySection(detail)
                ForEach(detail.blocks) { block in
                    blockSection(block)
                }
                provenanceSection(detail)
            }
        }
        .navigationTitle(detail?.summary.title ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if detail?.summary.isInProgress == true {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Continue") { ActiveWorkoutView(workoutID: workoutID) }
                }
            }
        }
        .confirmationDialog(
            "Delete this session?", isPresented: $isConfirmingDelete, titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deleteWorkout)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Its exercises and sets go with it. Other sessions and the plan are untouched.")
        }
        .onAppear(perform: load)
        .onChange(of: model.dataVersion) { load() }
    }

    private func summarySection(_ detail: WorkoutDetail) -> some View {
        Section {
            LabeledContent("Started", value: Format.relative(detail.summary.startTime))
            LabeledContent("Duration", value: Format.duration(detail.summary.duration))
            LabeledContent(
                "Sets", value: "\(detail.completedSetCount) of \(detail.plannedSetCount) completed")
            LabeledContent("Volume", value: Format.volume(detail.totalVolume))
        } header: {
            HStack {
                Text("Session")
                ModelSideBadge(side: .record)
            }
        }
    }

    private func blockSection(_ block: RecordBlock) -> some View {
        Section {
            ForEach(block.exercises) { exercise in
                RecordExerciseView(exercise: exercise, isSuperset: block.isSuperset)
            }
        } header: {
            HStack {
                Text("Block \(block.block)")
                if block.isSuperset {
                    Text("superset").font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.record)
                }
            }
        }
    }

    private func provenanceSection(_ detail: WorkoutDetail) -> some View {
        Section {
            LabeledContent("Came from", value: detail.summary.templateName ?? "plan deleted")
            LabeledContent("Slot provenance", value: detail.hasProvenance ? "intact" : "severed")
            Button("Delete session", role: .destructive) { isConfirmingDelete = true }
        } header: {
            Text("Provenance")
        } footer: {
            Text(
                detail.hasProvenance
                    ? """
                    Each exercise above still points back at the plan slot it was \
                    picked from. That pointer is the only link to the plan, and \
                    deleting the plan just sets it to null — everything above stays.
                    """
                    : """
                    The plan this came from is gone, so the pointers were set to \
                    null. The session above is unchanged — that's the whole point \
                    of keeping the record self-contained.
                    """)
        }
    }

    private func load() {
        detail = try? model.repository.workout(id: workoutID)
    }

    private func deleteWorkout() {
        if model.perform({ try model.repository.deleteWorkout(id: workoutID) }) {
            dismiss()
        }
    }
}

private struct RecordExerciseView: View {
    let exercise: RecordExercise
    let isSuperset: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(exercise.exerciseName).font(.headline)
                if isSuperset {
                    Tag(text: "leg \(exercise.within)", color: Theme.record)
                }
            }
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes).font(.caption2).foregroundStyle(.secondary)
            }
            ForEach(exercise.sets) { set in
                RecordSetRow(set: set)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct RecordSetRow: View {
    let set: RecordSet

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .leading)
            Text(Format.setSummary(reps: set.repCount, weight: set.weight, unit: set.unit))
                .font(.callout)
                .foregroundStyle(set.isCompleted ? .primary : .secondary)
            Spacer(minLength: 0)
            if set.setType != .regularSet {
                Tag(text: set.setType.label, color: Theme.color(for: set.setType))
            }
            if !set.isCompleted {
                Tag(text: "not done", color: .secondary)
            }
        }
    }

    private var label: String {
        let ordering = set.ordering.map(String.init) ?? "–"
        return set.isRetry ? "\(ordering)·\(set.attemptNumber)" : ordering
    }
}
