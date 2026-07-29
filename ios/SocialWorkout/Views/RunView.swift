import SwiftUI

/// Where the two trees meet: pick one variant per slot, press Start, and the
/// plan is resolved into a record that no longer depends on it.
struct RunView: View {
    @Environment(AppModel.self) private var model

    @State private var path = NavigationPath()
    @State private var templates: [WorkoutTemplate] = []
    @State private var activeWorkout: WorkoutSummary?

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if let activeWorkout {
                    Section {
                        NavigationLink(value: RunRoute.session(activeWorkout.id)) {
                            InProgressRow(workout: activeWorkout)
                        }
                        .accessibilityIdentifier("resume-session")
                    } header: {
                        HStack {
                            Text("In progress")
                            ModelSideBadge(side: .record)
                        }
                    }
                }

                Section {
                    ForEach(templates) { template in
                        NavigationLink(value: RunRoute.picker(template.id)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name)
                                if let description = template.description, !description.isEmpty {
                                    Text(description).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityIdentifier("start-\(template.name)")
                    }
                    if templates.isEmpty {
                        Text("No active plans. Create one in the Plans tab.")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Start from a plan")
                        ModelSideBadge(side: .plan)
                    }
                }
            }
            .navigationTitle("Run")
            .navigationDestination(for: RunRoute.self) { route in
                switch route {
                case let .picker(templateID):
                    SlotPickerView(templateID: templateID) { workoutID in
                        path.append(RunRoute.session(workoutID))
                    }
                case let .session(workoutID):
                    ActiveWorkoutView(workoutID: workoutID)
                }
            }
            .onAppear(perform: load)
            .onChange(of: model.dataVersion) { load() }
        }
    }

    private func load() {
        templates = model.repository.templates()
        activeWorkout = model.repository.activeWorkout()
    }
}

enum RunRoute: Hashable {
    case picker(String)
    case session(String)
}

private struct InProgressRow: View {
    let workout: WorkoutSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.title)
                Text("started \(Format.relative(workout.startTime))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "figure.run")
                .foregroundStyle(Theme.record)
        }
    }
}

/// One choice per `(block, within)` slot. Archived variants aren't offered;
/// a slot can also be skipped, in which case it simply never reaches the record.
struct SlotPickerView: View {
    @Environment(AppModel.self) private var model

    let templateID: String
    let onStart: (String) -> Void

    @State private var detail: TemplateDetail?
    /// Slot id → chosen variant id. A missing value means "skip this slot".
    @State private var picks: [String: String] = [:]

    var body: some View {
        List {
            if let detail {
                ForEach(detail.blocks) { block in
                    Section {
                        ForEach(block.slots) { slot in
                            SlotPickerRow(
                                slot: slot,
                                showsLegNumber: block.isSuperset,
                                selection: Binding(
                                    get: { picks[slot.id] },
                                    set: { picks[slot.id] = $0 }))
                        }
                    } header: {
                        HStack {
                            Text("Block \(block.block)")
                            if block.isSuperset {
                                Text("superset").font(.caption2.weight(.semibold))
                                    .foregroundStyle(Theme.plan)
                            }
                        }
                    }
                }

                Section {
                    Button(action: start) {
                        Label("Start session", systemImage: "play.fill")
                    }
                    .disabled(picks.values.isEmpty)
                } footer: {
                    Text(
                        """
                        Starting writes one workout_exercise per pick — carrying the \
                        exercise you chose and this session's order — and copies the \
                        planned sets in as blanks to fill. After that, the session \
                        stands on its own.
                        """)
                }
            }
        }
        .navigationTitle(detail?.template.name ?? "Pick your session")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private func load() {
        guard detail == nil else { return }
        detail = try? model.repository.template(id: templateID)
        // Default pick per slot: the lowest active exercise_index.
        for slot in detail?.slots ?? [] {
            picks[slot.id] = slot.defaultVariant?.id
        }
    }

    private func start() {
        // Preserve plan order so block/leg numbering in the record matches.
        let ordered = (detail?.slots ?? []).compactMap { picks[$0.id] }
        guard !ordered.isEmpty else { return }
        guard
            let workoutID = model.performReturning({
                try model.repository.startWorkout(templateID: templateID, picks: ordered)
            })
        else { return }
        model.activeWorkoutID = workoutID
        onStart(workoutID)
    }
}

private struct SlotPickerRow: View {
    let slot: PlanSlot
    let showsLegNumber: Bool
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showsLegNumber {
                Text("Leg \(slot.within)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Picker(selection: $selection) {
                ForEach(slot.activeVariants) { variant in
                    Text(variant.exerciseName).tag(String?.some(variant.id))
                }
                Text("Skip").tag(String?.none)
            } label: {
                Text(chosenName)
            }
            .pickerStyle(.menu)
            .labelsHidden()

            if slot.activeVariants.count > 1 {
                Text("\(slot.activeVariants.count) options for this slot")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var chosenName: String {
        slot.activeVariants.first { $0.id == selection }?.exerciseName ?? "Skip"
    }
}
