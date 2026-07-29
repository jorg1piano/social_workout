import SwiftUI

/// One plan variant and the sets planned for it.
///
/// Planned sets are a template, not a log: nothing here is "done". They get
/// copied into the record when a session starts, and from that moment the two
/// are independent — editing this variant next week doesn't rewrite last week.
struct VariantDetailView: View {
    @Environment(AppModel.self) private var model

    let variant: PlanVariant

    @State private var plannedSets: [PlannedSet] = []
    @State private var isAddingSet = false
    /// Tracked separately because `variant` is the value this screen was pushed
    /// with: archiving writes to the database but can't reach back and update it.
    @State private var isArchived: Bool

    init(variant: PlanVariant) {
        self.variant = variant
        _isArchived = State(initialValue: variant.isArchived)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Exercise", value: variant.exerciseName)
                LabeledContent("Block", value: "\(variant.block)")
                LabeledContent("Leg in block", value: "\(variant.within)")
                LabeledContent(
                    "Variant",
                    value: variant.isDefault ? "default (index 0)" : "swap \(variant.exerciseIndex)")
                if let notes = variant.notes, !notes.isEmpty {
                    LabeledContent("Notes", value: notes)
                }
            } header: {
                HStack {
                    Text("Slot")
                    ModelSideBadge(side: .plan)
                }
            } footer: {
                Text(
                    """
                    A slot is identified by (block \(variant.block), leg \(variant.within)). \
                    Every variant in that slot is an option; exactly one of them \
                    ends up in a given session.
                    """)
            }

            Section {
                if plannedSets.isEmpty {
                    Text("No planned sets. Sessions started from this variant begin empty.")
                        .foregroundStyle(.secondary)
                }
                ForEach(plannedSets) { plannedSet in
                    PlannedSetRow(plannedSet: plannedSet)
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                model.perform {
                                    try model.repository.deletePlannedSet(id: plannedSet.id)
                                }
                            }
                        }
                }
                Button {
                    isAddingSet = true
                } label: {
                    Label("Add planned set", systemImage: "plus.circle")
                }
            } header: {
                Text("Planned sets")
            }

            Section {
                Button(isArchived ? "Restore variant" : "Archive variant") {
                    let target = !isArchived
                    if model.perform({
                        try model.repository.setVariantArchived(id: variant.id, archived: target)
                    }) {
                        isArchived = target
                    }
                }
            } footer: {
                Text(
                    """
                    Archiving takes this option out of the start-a-session picker \
                    and nothing else: sessions that used it keep pointing at it, \
                    and swapping back later restores this same row rather than \
                    forking a second one.
                    """)
            }
        }
        .navigationTitle(variant.exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddingSet) {
            AddPlannedSetSheet(
                variant: variant,
                nextOrdering: (plannedSets.map(\.ordering).max() ?? 0) + 1)
        }
        .onAppear(perform: load)
        .onChange(of: model.dataVersion) { load() }
    }

    private func load() {
        plannedSets = model.repository.plannedSets(variantID: variant.id)
    }
}

private struct PlannedSetRow: View {
    let plannedSet: PlannedSet

    var body: some View {
        HStack {
            Text("\(plannedSet.ordering)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(
                    Format.setSummary(
                        reps: plannedSet.repCount, weight: plannedSet.weight,
                        unit: plannedSet.unit))
                Text(detailLine)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let setType = plannedSet.setType, setType != .regularSet {
                Tag(text: setType.label, color: Theme.color(for: setType))
            }
        }
    }

    private var detailLine: String {
        var parts = ["rest \(Format.rest(plannedSet.restTime))"]
        if let rpe = plannedSet.rpe { parts.append("RPE \(Format.weight(rpe))") }
        if let rir = plannedSet.rir { parts.append("RIR \(Format.weight(rir))") }
        return parts.joined(separator: " · ")
    }
}

private struct AddPlannedSetSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let variant: PlanVariant
    let nextOrdering: Int

    @State private var reps = "8"
    @State private var weight = ""
    @State private var unit = "kg"
    @State private var setType = SetType.regularSet
    @State private var restTime = 90

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Set number", value: "\(nextOrdering)")
                    TextField("Reps", text: $reps).keyboardType(.numberPad)
                    TextField("Weight", text: $weight).keyboardType(.numbersAndPunctuation)
                    Picker("Unit", selection: $unit) {
                        Text("kg").tag("kg")
                        Text("lbs").tag("lbs")
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    Text(
                        """
                        Weight is signed: 0 means bodyweight, and a negative \
                        number means assistance taken off your bodyweight.
                        """)
                }

                Section {
                    Picker("Type", selection: $setType) {
                        ForEach(SetType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    Stepper("Rest \(Format.rest(restTime))", value: $restTime, in: 0...600, step: 15)
                }
            }
            .navigationTitle("Planned set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Add", action: add) }
            }
        }
    }

    private func add() {
        let created = model.performReturning {
            try model.repository.addPlannedSet(
                variantID: variant.id,
                ordering: nextOrdering,
                repCount: Int(reps),
                weight: Double(weight.replacingOccurrences(of: ",", with: ".")),
                unit: unit,
                setType: setType,
                restTime: restTime)
        }
        if created != nil { dismiss() }
    }
}
