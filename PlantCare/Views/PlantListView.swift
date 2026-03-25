import SwiftUI
import SwiftData

struct PlantListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlantViewModel
    @State private var showingAddPlant = false

    init() {
        let context = ModelContext(
            try! ModelContainer(for: Plant.self, WateringLog.self, HealthLog.self)
        )
        _viewModel = StateObject(wrappedValue: PlantViewModel(modelContext: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.plants.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(.green.opacity(0.6))
                        Text("No plants yet")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Add your first plant to get started")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    List {
                        if !viewModel.plantsNeedingWater.isEmpty {
                            Section {
                                ForEach(viewModel.plantsNeedingWater) { plant in
                                    PlantRowView(plant: plant, viewModel: viewModel)
                                }
                            } header: {
                                Label("Needs Water Today", systemImage: "drop.fill")
                                    .foregroundStyle(.blue)
                            }
                        }

                        Section {
                            ForEach(viewModel.filteredPlants) { plant in
                                PlantRowView(plant: plant, viewModel: viewModel)
                            }
                            .onDelete(perform: deletePlants)
                        } header: {
                            Text("All Plants")
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search plants")
                }
            }
            .navigationTitle("PlantCare")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView(viewModel: viewModel)
            }
            .onAppear {
                updateViewModel()
                viewModel.fetchPlants()
            }
        }
    }

    private func updateViewModel() {
        viewModel.modelContext = modelContext
    }

    private func deletePlants(at offsets: IndexSet) {
        for index in offsets {
            let plant = viewModel.filteredPlants[index]
            viewModel.deletePlant(plant)
        }
    }
}

struct PlantRowView: View {
    let plant: Plant
    let viewModel: PlantViewModel

    var body: some View {
        NavigationLink(destination: PlantDetailView(plant: plant, viewModel: viewModel)) {
            HStack(spacing: 12) {
                if let photoData = plant.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.green.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(.green)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name)
                        .font(.headline)

                    Text(plant.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: plant.location.icon)
                            .font(.caption)
                        Text(plant.location.rawValue)
                            .font(.caption)

                        if plant.isOverdue {
                            Text("• \(plant.daysOverdue)d overdue")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else if plant.needsWateringToday {
                            Text("• Water today")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        } else {
                            Text("• Water in \(plant.daysUntilWatering)d")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if plant.needsWateringToday {
                    Button {
                        viewModel.waterPlant(plant)
                    } label: {
                        Image(systemName: "drop.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    PlantListView()
        .modelContainer(for: [Plant.self, WateringLog.self, HealthLog.self])
}
