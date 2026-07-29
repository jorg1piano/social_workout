import SwiftUI

/// The plan tree: workout templates and the variants that fill their slots.
struct PlansView: View {
    @Environment(AppModel.self) private var model
    @State private var templates: [WorkoutTemplate] = []
    @State private var showsArchived = false
    @State private var isAddingTemplate = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(templates) { template in
                        NavigationLink(value: template) {
                            TemplateRow(template: template)
                        }
                        .accessibilityIdentifier("plan-\(template.name)")
                    }
                    if templates.isEmpty {
                        Text("No plans yet.").foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Templates")
                        ModelSideBadge(side: .plan)
                    }
                } footer: {
                    Text(
                        """
                        A plan is a suggestion, and it only matters at the moment \
                        you press Start. Edit it, archive it, delete it — logged \
                        sessions don't move.
                        """)
                }
            }
            .navigationTitle("Plans")
            .navigationDestination(for: WorkoutTemplate.self) {
                TemplateDetailView(templateID: $0.id)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle(isOn: $showsArchived) { Text("Archived") }
                        .toggleStyle(.button)
                        .font(.caption)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isAddingTemplate = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("New plan")
                }
            }
            .sheet(isPresented: $isAddingTemplate) { NewTemplateSheet() }
            .onAppear(perform: load)
            .onChange(of: model.dataVersion) { load() }
            .onChange(of: showsArchived) { load() }
        }
    }

    private func load() {
        templates = model.repository.templates(includeArchived: showsArchived)
    }
}

private struct TemplateRow: View {
    let template: WorkoutTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(template.name)
                if template.isArchived {
                    Text("archived")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            if let description = template.description, !description.isEmpty {
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct NewTemplateSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name, e.g. Leg Day", text: $name)
                TextField("Description (optional)", text: $description)
            }
            .navigationTitle("New plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: create)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func create() {
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        let created = model.performReturning {
            try model.repository.createTemplate(
                name: name.trimmingCharacters(in: .whitespaces),
                description: trimmedDescription.isEmpty ? nil : trimmedDescription)
        }
        if created != nil { dismiss() }
    }
}
