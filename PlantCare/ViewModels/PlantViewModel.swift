import Foundation
import SwiftData
import SwiftUI

@MainActor
class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var searchText: String = ""

    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchPlants()
    }

    func fetchPlants() {
        let descriptor = FetchDescriptor<Plant>(sortBy: [SortDescriptor(\.name)])
        do {
            plants = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch plants: \(error)")
        }
    }

    func addPlant(_ plant: Plant) {
        modelContext.insert(plant)
        saveContext()
        fetchPlants()

        NotificationManager.shared.scheduleWateringNotification(for: plant)
    }

    func updatePlant(_ plant: Plant) {
        saveContext()
        fetchPlants()

        NotificationManager.shared.cancelNotification(for: plant)
        NotificationManager.shared.scheduleWateringNotification(for: plant)
    }

    func deletePlant(_ plant: Plant) {
        NotificationManager.shared.cancelNotification(for: plant)
        modelContext.delete(plant)
        saveContext()
        fetchPlants()
    }

    func waterPlant(_ plant: Plant) {
        plant.water()

        let log = WateringLog(date: Date(), notes: "Watered")
        log.plant = plant
        plant.wateringLogs.append(log)
        modelContext.insert(log)

        saveContext()
        fetchPlants()

        NotificationManager.shared.cancelNotification(for: plant)
        NotificationManager.shared.scheduleWateringNotification(for: plant)
    }

    func addHealthLog(to plant: Plant, notes: String, photoData: Data?) {
        let healthLog = HealthLog(date: Date(), notes: notes, photoData: photoData)
        healthLog.plant = plant
        plant.healthLogs.append(healthLog)
        modelContext.insert(healthLog)
        saveContext()
        fetchPlants()
    }

    var plantsNeedingWater: [Plant] {
        plants.filter { $0.needsWateringToday }
    }

    var overduePlants: [Plant] {
        plants.filter { $0.isOverdue }
    }

    var filteredPlants: [Plant] {
        if searchText.isEmpty {
            return plants
        }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.species.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
