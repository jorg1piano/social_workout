import SwiftUI

/// A plan, laid out along its three ordering axes.
///
///   block_ordering        — one section per block. A block with more than one
///                           leg is a superset you alternate through.
///   within_block_ordering — the legs inside a block.
///   exercise_index        — the variants offered for one leg: index 0 is the
///                           default, 1+ are swaps you can pick at start time.
struct TemplateDetailView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let templateID: String

    @State private var detail: TemplateDetail?
    @State private var isAddingVariant = false
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            if let detail {
                overviewSection(detail)
                ForEach(detail.blocks) { block in
                    blockSection(block)
                }
                addSection
                dangerSection(detail)
            }
        }
        .navigationTitle(detail?.template.name ?? "Plan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PlanVariant.self) { VariantDetailView(variant: $0) }
        .sheet(isPresented: $isAddingVariant) {
            if let detail {
                AddVariantSheet(detail: detail)
            }
        }
        .confirmationDialog(
            "Delete this plan?", isPresented: $isConfirmingDelete, titleVisibility: .visible
        ) {
            Button("Delete plan", role: .destructive, action: deleteTemplate)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                """
                The plan and its variants go away for good. Every session you \
                ever logged from it stays exactly as it is — check the History \
                tab afterwards.
                """)
        }
        .onAppear(perform: load)
        .onChange(of: model.dataVersion) { load() }
    }

    // MARK: Sections

    private func overviewSection(_ detail: TemplateDetail) -> some View {
        Section {
            if let description = detail.template.description, !description.isEmpty {
                Text(description)
            }
            if let notes = detail.template.notes, !notes.isEmpty {
                Text(notes).font(.callout).foregroundStyle(.secondary)
            }
            LabeledContent("Blocks", value: "\(detail.blocks.count)")
            LabeledContent("Slots to pick", value: "\(detail.slots.count)")
        } header: {
            HStack {
                // Not "Plan" — the badge beside it already says that, and List
                // uppercases headers, so the two would read as "PLAN PLAN".
                Text("Overview")
                ModelSideBadge(side: .plan)
                if detail.template.isArchived {
                    Text("· archived").foregroundStyle(.secondary)
                }
            }
        }
    }

    private func blockSection(_ block: PlanBlock) -> some View {
        Section {
            ForEach(block.slots) { slot in
                PlanSlotView(slot: slot, showsLegNumber: block.isSuperset)
            }
        } header: {
            HStack {
                Text("Block \(block.block)")
                if block.isSuperset {
                    Text("superset · \(block.slots.count) legs")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.plan)
                }
            }
        }
    }

    private var addSection: some View {
        Section {
            Button {
                isAddingVariant = true
            } label: {
                Label("Add an exercise", systemImage: "plus.circle")
            }
        }
    }

    private func dangerSection(_ detail: TemplateDetail) -> some View {
        Section {
            Button(detail.template.isArchived ? "Unarchive plan" : "Archive plan") {
                model.perform {
                    try model.repository.setTemplateArchived(
                        id: templateID, archived: !detail.template.isArchived)
                }
            }
            Button("Delete plan", role: .destructive) { isConfirmingDelete = true }
        } footer: {
            Text(
                """
                Archiving hides a plan from the pickers. Deleting removes it \
                outright — history survives either way, because a logged session \
                keeps its own copy of what was done and in what order.
                """)
        }
    }

    // MARK: Actions

    private func load() {
        detail = try? model.repository.template(id: templateID)
    }

    private func deleteTemplate() {
        if model.perform({ try model.repository.deleteTemplate(id: templateID) }) {
            dismiss()
        }
    }
}

/// One `(block, within)` slot: the default pick, its swaps, and any archived
/// variants still on file.
private struct PlanSlotView: View {
    @Environment(AppModel.self) private var model

    let slot: PlanSlot
    let showsLegNumber: Bool

    var body: some View {
        if showsLegNumber {
            Text("Leg \(slot.within)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        ForEach(slot.variants) { variant in
            NavigationLink(value: variant) {
                VariantRow(variant: variant, isDefault: variant.id == slot.defaultVariant?.id)
            }
            .swipeActions {
                Button(variant.isArchived ? "Restore" : "Archive") {
                    model.perform {
                        try model.repository.setVariantArchived(
                            id: variant.id, archived: !variant.isArchived)
                    }
                }
                .tint(variant.isArchived ? Theme.accent : .orange)
            }
        }
    }
}

private struct VariantRow: View {
    let variant: PlanVariant
    let isDefault: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(variant.exerciseName)
                    .foregroundStyle(variant.isArchived ? .secondary : .primary)
                if variant.isArchived {
                    Tag(text: "archived", color: .secondary)
                } else if isDefault {
                    Tag(text: "default", color: Theme.plan)
                } else {
                    Tag(text: "swap \(variant.exerciseIndex)", color: Theme.accent)
                }
            }
            Text(setsSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let notes = variant.notes, !notes.isEmpty {
                Text(notes).font(.caption2).foregroundStyle(.tertiary)
            }
        }
    }

    private var setsSummary: String {
        guard !variant.plannedSets.isEmpty else { return "no planned sets" }
        let working = variant.plannedSets.filter { $0.setType != .warmup }
        let reference = working.first ?? variant.plannedSets[0]
        let count = variant.plannedSets.count
        return "\(count) set\(count == 1 ? "" : "s") · "
            + Format.setSummary(
                reps: reference.repCount, weight: reference.weight, unit: reference.unit)
    }
}

struct Tag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
            .foregroundStyle(color)
    }
}

// MARK: - Adding a variant

/// Where a newly added exercise goes, expressed in the plan's own vocabulary
/// rather than in raw `(block, within, index)` numbers.
enum VariantPlacement: Hashable {
    /// Its own block, run straight through.
    case newBlock
    /// Another leg of an existing block — i.e. make it a superset.
    case supersetPartner(block: Int)
    /// An alternative for an existing leg, choosable when starting a session.
    case swap(block: Int, within: Int)
}

struct AddVariantSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let detail: TemplateDetail

    @State private var placement = VariantPlacement.newBlock
    @State private var selected: Exercise?
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    NavigationLink {
                        ExercisePicker(title: "Choose exercise") { selected = $0 }
                    } label: {
                        LabeledContent("Exercise", value: selected?.name ?? "Choose…")
                    }
                }

                Section {
                    Picker("Placement", selection: $placement) {
                        Text("Its own block").tag(VariantPlacement.newBlock)
                        ForEach(detail.blocks) { block in
                            Text("Superset with block \(block.block)")
                                .tag(VariantPlacement.supersetPartner(block: block.block))
                        }
                        ForEach(detail.slots) { slot in
                            Text(swapLabel(for: slot))
                                .tag(VariantPlacement.swap(block: slot.block, within: slot.within))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Where it goes")
                } footer: {
                    Text(placementExplanation)
                }

                Section("Notes") {
                    TextField("Optional", text: $notes)
                }
            }
            .navigationTitle("Add exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add).disabled(selected == nil)
                }
            }
        }
    }

    private func swapLabel(for slot: PlanSlot) -> String {
        let name = slot.defaultVariant?.exerciseName ?? "leg \(slot.within)"
        return "Swap option for \(name)"
    }

    private var placementExplanation: String {
        switch placement {
        case .newBlock:
            return "A block of its own — a straight exercise, done on its own."
        case .supersetPartner:
            return
                "Another leg of that block. Legs in a block are alternated, which is what makes it a superset."
        case .swap:
            return
                "An alternative for that leg. You choose between the options when you start a session; only the one you pick is recorded."
        }
    }

    /// Turns the chosen placement into the `(block, within, index)` triple the
    /// schema stores, using the highest existing value on the relevant axis.
    private func coordinates() -> (block: Int, within: Int, index: Int) {
        switch placement {
        case .newBlock:
            return ((detail.blocks.map(\.block).max() ?? 0) + 1, 1, 0)
        case let .supersetPartner(block):
            let legs = detail.blocks.first { $0.block == block }?.slots.map(\.within) ?? []
            return (block, (legs.max() ?? 0) + 1, 0)
        case let .swap(block, within):
            let slot = detail.slots.first { $0.block == block && $0.within == within }
            let indices = slot?.variants.map(\.exerciseIndex) ?? []
            return (block, within, (indices.max() ?? 0) + 1)
        }
    }

    private func add() {
        guard let selected else { return }
        let target = coordinates()
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        let created = model.performReturning {
            try model.repository.addVariant(
                templateID: detail.template.id,
                exerciseID: selected.id,
                block: target.block,
                within: target.within,
                exerciseIndex: target.index,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes)
        }
        if created != nil { dismiss() }
    }
}
