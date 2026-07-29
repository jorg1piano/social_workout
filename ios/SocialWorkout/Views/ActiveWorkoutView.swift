import SwiftUI

/// Logging a session in progress.
///
/// Every edit here writes to `exercise_set` — the record. The plan it came from
/// is never touched: change a weight, add a set, delete one, and the template
/// you started from is exactly as it was.
struct ActiveWorkoutView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let workoutID: String

    @State private var detail: WorkoutDetail?
    @State private var previousByExercise: [String: [RecordSet]] = [:]
    @State private var isConfirmingFinish = false

    var body: some View {
        List {
            if let detail {
                headerSection(detail)
                ForEach(detail.blocks) { block in
                    blockSection(block)
                }
                finishSection(detail)
            }
        }
        .navigationTitle(detail?.summary.title ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Finish this session?", isPresented: $isConfirmingFinish, titleVisibility: .visible
        ) {
            Button("Finish", action: finish)
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("Stamps the stop time. Sets you never completed stay as unfinished rows.")
        }
        .onAppear(perform: load)
        .onChange(of: model.dataVersion) { load() }
    }

    // MARK: Sections

    private func headerSection(_ detail: WorkoutDetail) -> some View {
        Section {
            if detail.summary.isInProgress, let start = detail.summary.startTime {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    LabeledContent("Elapsed") {
                        Text(Format.duration(context.date.timeIntervalSince(start)))
                            .monospacedDigit()
                    }
                }
            } else {
                LabeledContent("Duration", value: Format.duration(detail.summary.duration))
            }
            LabeledContent(
                "Sets completed", value: "\(detail.completedSetCount) of \(detail.plannedSetCount)")
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
                ExerciseLogView(
                    exercise: exercise,
                    previous: previousByExercise[exercise.exerciseID] ?? [],
                    isSuperset: block.isSuperset)
            }
        } header: {
            HStack {
                Text("Block \(block.block)")
                if block.isSuperset {
                    Text("superset · alternate the legs")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.record)
                }
            }
        }
    }

    private func finishSection(_ detail: WorkoutDetail) -> some View {
        Section {
            if detail.summary.isInProgress {
                Button {
                    isConfirmingFinish = true
                } label: {
                    Label("Finish session", systemImage: "flag.checkered")
                }
            } else {
                LabeledContent("Finished", value: Format.relative(detail.summary.stopTime))
            }
        }
    }

    // MARK: Actions

    private func load() {
        detail = try? model.repository.workout(id: workoutID)
        for exercise in detail?.exercises ?? [] where previousByExercise[exercise.exerciseID] == nil {
            previousByExercise[exercise.exerciseID] = model.repository.previousSets(
                exerciseID: exercise.exerciseID, excludingWorkoutID: workoutID)
        }
    }

    private func finish() {
        if model.perform({ try model.repository.finishWorkout(id: workoutID) }) {
            model.activeWorkoutID = nil
        }
    }
}

/// One leg of the session: its sets, what you did last time, and the controls
/// to log more.
private struct ExerciseLogView: View {
    @Environment(AppModel.self) private var model

    let exercise: RecordExercise
    let previous: [RecordSet]
    let isSuperset: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(exercise.exerciseName).font(.headline)
                if isSuperset {
                    Tag(text: "leg \(exercise.within)", color: Theme.record)
                }
            }

            if !previous.isEmpty {
                Text("last time: \(previousSummary)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            ForEach(exercise.sets) { set in
                SetLogRow(
                    set: set,
                    onSave: { reps, weight in
                        model.performQuietly {
                            try model.repository.updateSet(
                                id: set.id, repCount: .some(reps), weight: .some(weight))
                        }
                    },
                    onToggle: {
                        model.perform {
                            try model.repository.updateSet(
                                id: set.id, isCompleted: !set.isCompleted)
                        }
                    },
                    onDelete: {
                        model.perform { try model.repository.deleteSet(id: set.id) }
                    },
                    onRetry: {
                        model.perform {
                            try model.repository.addAttempt(
                                to: set, workoutExerciseID: exercise.id)
                        }
                    })
            }

            Button {
                model.perform {
                    try model.repository.addSet(
                        workoutExerciseID: exercise.id,
                        repCount: exercise.sets.last?.repCount,
                        weight: exercise.sets.last?.weight,
                        unit: exercise.sets.last?.unit,
                        restTime: exercise.sets.last?.restTime ?? 0)
                }
            } label: {
                Label("Add set", systemImage: "plus.circle").font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }

    private var previousSummary: String {
        previous
            .map { Format.setSummary(reps: $0.repCount, weight: $0.weight, unit: $0.unit) }
            .joined(separator: ", ")
    }
}

/// A single logged set. Reps and weight are written straight through as you
/// type; ticking the checkbox is what marks it done.
private struct SetLogRow: View {
    let set: RecordSet
    let onSave: (Int?, Double?) -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onRetry: () -> Void

    @State private var reps: String
    @State private var weight: String

    init(
        set: RecordSet,
        onSave: @escaping (Int?, Double?) -> Void,
        onToggle: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.set = set
        self.onSave = onSave
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onRetry = onRetry
        _reps = State(initialValue: set.repCount.map(String.init) ?? "")
        _weight = State(initialValue: set.weight.map { Format.weight($0) } ?? "")
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.caption.monospacedDigit())
                .foregroundStyle(set.setType == .warmup ? Theme.color(for: .warmup) : .secondary)
                .frame(width: 34, alignment: .leading)

            TextField("reps", text: $reps)
                .keyboardType(.numberPad)
                .frame(width: 46)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .onChange(of: reps) { save() }

            Text("×").foregroundStyle(.tertiary)

            TextField("kg", text: $weight)
                .keyboardType(.numbersAndPunctuation)
                .frame(width: 62)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .onChange(of: weight) { save() }

            Spacer(minLength: 0)

            Button(action: onToggle) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.isCompleted ? Theme.record : Color.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(set.isCompleted ? "Mark set not done" : "Mark set done")
        }
        .swipeActions {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Retry", action: onRetry).tint(Theme.accent)
        }
    }

    /// "1", or "1·2" for the second attempt at set 1.
    private var label: String {
        let ordering = set.ordering.map(String.init) ?? "–"
        let badge = set.setType.badge
        let attempt = set.isRetry ? "·\(set.attemptNumber)" : ""
        return badge.isEmpty ? ordering + attempt : "\(ordering)\(attempt)\(badge)"
    }

    private func save() {
        let normalized = weight.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "−", with: "-")
        onSave(Int(reps), Double(normalized))
    }
}
