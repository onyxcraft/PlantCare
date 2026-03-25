import SwiftUI
import PhotosUI

struct PlantDetailView: View {
    let plant: Plant
    let viewModel: PlantViewModel

    @State private var showingEditSheet = false
    @State private var showingHealthLogSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let photoData = plant.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.2))
                        .frame(height: 300)
                        .overlay {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    InfoCard(title: "Watering Status") {
                        VStack(alignment: .leading, spacing: 12) {
                            if plant.isOverdue {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                    Text("Overdue by \(plant.daysOverdue) days")
                                        .foregroundStyle(.red)
                                }
                                .font(.headline)
                            } else if plant.needsWateringToday {
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundStyle(.blue)
                                    Text("Needs watering today")
                                        .foregroundStyle(.blue)
                                }
                                .font(.headline)
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Water in \(plant.daysUntilWatering) days")
                                        .foregroundStyle(.green)
                                }
                                .font(.headline)
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Last Watered")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(plant.lastWateredDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never")
                                        .font(.subheadline)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Next Due")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(plant.nextWateringDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                                        .font(.subheadline)
                                }
                            }

                            Button {
                                viewModel.waterPlant(plant)
                            } label: {
                                Label("Mark as Watered", systemImage: "drop.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    InfoCard(title: "Plant Information") {
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(label: "Species", value: plant.species)
                            InfoRow(label: "Location", value: plant.location.rawValue, icon: plant.location.icon)
                            InfoRow(label: "Watering Frequency", value: "Every \(plant.wateringIntervalDays) days")
                            InfoRow(label: "Added", value: plant.createdDate.formatted(date: .abbreviated, time: .omitted))

                            if !plant.notes.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notes")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(plant.notes)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }

                    InfoCard(title: "Health Log") {
                        VStack(alignment: .leading, spacing: 12) {
                            if plant.healthLogs.isEmpty {
                                Text("No health logs yet")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            } else {
                                ForEach(plant.healthLogs.sorted(by: { $0.date > $1.date }).prefix(3)) { log in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(log.notes)
                                            .font(.subheadline)
                                    }
                                    if log.id != plant.healthLogs.last?.id {
                                        Divider()
                                    }
                                }
                            }

                            Button {
                                showingHealthLogSheet = true
                            } label: {
                                Label("Add Health Log", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    InfoCard(title: "Watering History") {
                        VStack(alignment: .leading, spacing: 8) {
                            if plant.wateringLogs.isEmpty {
                                Text("No watering history yet")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            } else {
                                ForEach(plant.wateringLogs.sorted(by: { $0.date > $1.date }).prefix(5)) { log in
                                    HStack {
                                        Image(systemName: "drop.fill")
                                            .foregroundStyle(.blue)
                                        Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingHealthLogSheet) {
            AddHealthLogView(plant: plant, viewModel: viewModel)
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var icon: String?

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

struct AddHealthLogView: View {
    @Environment(\.dismiss) private var dismiss
    let plant: Plant
    let viewModel: PlantViewModel

    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 150)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            if let photoData = photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay {
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.title)
                                            Text("Add Photo")
                                                .font(.caption)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Health Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addHealthLog(to: plant, notes: notes, photoData: photoData)
                        dismiss()
                    }
                    .disabled(notes.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(
            plant: Plant(
                name: "Monstera",
                species: "Monstera deliciosa",
                location: .indoor,
                wateringIntervalDays: 7
            ),
            viewModel: PlantViewModel(modelContext: ModelContext(
                try! ModelContainer(for: Plant.self, WateringLog.self, HealthLog.self)
            ))
        )
    }
}
