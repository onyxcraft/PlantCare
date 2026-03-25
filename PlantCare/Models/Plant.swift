import Foundation
import SwiftData
import SwiftUI

@Model
final class Plant {
    var id: UUID
    var name: String
    var species: String
    var location: PlantLocation
    var wateringIntervalDays: Int
    var lastWateredDate: Date?
    var createdDate: Date
    var photoData: Data?
    var notes: String

    @Relationship(deleteRule: .cascade)
    var wateringLogs: [WateringLog] = []

    @Relationship(deleteRule: .cascade)
    var healthLogs: [HealthLog] = []

    init(
        name: String,
        species: String,
        location: PlantLocation,
        wateringIntervalDays: Int,
        photoData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.location = location
        self.wateringIntervalDays = wateringIntervalDays
        self.photoData = photoData
        self.notes = notes
        self.createdDate = Date()
        self.lastWateredDate = nil
    }

    var nextWateringDate: Date? {
        guard let lastWatered = lastWateredDate else {
            return createdDate.addingTimeInterval(TimeInterval(wateringIntervalDays * 86400))
        }
        return lastWatered.addingTimeInterval(TimeInterval(wateringIntervalDays * 86400))
    }

    var daysUntilWatering: Int {
        guard let nextDate = nextWateringDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
        return days
    }

    var isOverdue: Bool {
        return daysUntilWatering < 0
    }

    var daysOverdue: Int {
        return isOverdue ? abs(daysUntilWatering) : 0
    }

    var needsWateringToday: Bool {
        return daysUntilWatering <= 0
    }

    func water() {
        lastWateredDate = Date()
    }
}

enum PlantLocation: String, Codable, CaseIterable {
    case indoor = "Indoor"
    case outdoor = "Outdoor"

    var icon: String {
        switch self {
        case .indoor:
            return "house.fill"
        case .outdoor:
            return "sun.max.fill"
        }
    }
}
