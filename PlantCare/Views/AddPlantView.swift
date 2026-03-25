import SwiftUI
import PhotosUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlantViewModel

    @State private var name = ""
    @State private var species = ""
    @State private var location: PlantLocation = .indoor
    @State private var wateringInterval = 7
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Plant Name", text: $name)
                    TextField("Species", text: $species)

                    Picker("Location", selection: $location) {
                        ForEach(PlantLocation.allCases, id: \.self) { location in
                            HStack {
                                Image(systemName: location.icon)
                                Text(location.rawValue)
                            }
                            .tag(location)
                        }
                    }
                }

                Section("Watering Schedule") {
                    Stepper("Every \(wateringInterval) days", value: $wateringInterval, in: 1...90)
                    Text("Next watering will be in \(wateringInterval) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlant()
                    }
                    .disabled(name.isEmpty || species.isEmpty)
                }
            }
        }
    }

    private func savePlant() {
        let plant = Plant(
            name: name,
            species: species,
            location: location,
            wateringIntervalDays: wateringInterval,
            photoData: photoData,
            notes: notes
        )

        viewModel.addPlant(plant)
        dismiss()
    }
}

#Preview {
    AddPlantView(viewModel: PlantViewModel(modelContext: ModelContext(
        try! ModelContainer(for: Plant.self, WateringLog.self, HealthLog.self)
    )))
}
