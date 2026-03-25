import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PlantWidgetEntry {
        PlantWidgetEntry(
            date: Date(),
            plantsNeedingWater: [
                PlantWidgetData(id: "1", name: "Monstera", species: "Monstera deliciosa", daysOverdue: 0, photoData: nil),
                PlantWidgetData(id: "2", name: "Snake Plant", species: "Sansevieria", daysOverdue: 2, photoData: nil)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantWidgetEntry) -> ()) {
        let entry = PlantWidgetEntry(
            date: Date(),
            plantsNeedingWater: fetchPlantsNeedingWater()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantWidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = PlantWidgetEntry(
            date: currentDate,
            plantsNeedingWater: fetchPlantsNeedingWater()
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchPlantsNeedingWater() -> [PlantWidgetData] {
        do {
            let modelContainer = try ModelContainer(for: Plant.self, WateringLog.self, HealthLog.self)
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<Plant>()
            let plants = try context.fetch(descriptor)

            return plants
                .filter { $0.needsWateringToday }
                .sorted { $0.daysOverdue > $1.daysOverdue }
                .prefix(5)
                .map { plant in
                    PlantWidgetData(
                        id: plant.id.uuidString,
                        name: plant.name,
                        species: plant.species,
                        daysOverdue: plant.daysOverdue,
                        photoData: plant.photoData
                    )
                }
        } catch {
            print("Failed to fetch plants: \(error)")
            return []
        }
    }
}

struct PlantCareWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: PlantWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text("Water Today")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }

            if entry.plantsNeedingWater.isEmpty {
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("All done!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ForEach(entry.plantsNeedingWater.prefix(2)) { plant in
                    HStack {
                        if let photoData = plant.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 30, height: 30)
                                .overlay {
                                    Image(systemName: "leaf.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(plant.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            if plant.isOverdue {
                                Text("\(plant.daysOverdue)d overdue")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: PlantWidgetEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Plants Needing Water", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text("\(entry.plantsNeedingWater.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            if entry.plantsNeedingWater.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                    Text("All plants watered!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                VStack(spacing: 8) {
                    ForEach(entry.plantsNeedingWater.prefix(3)) { plant in
                        HStack {
                            if let photoData = plant.photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.green.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Image(systemName: "leaf.fill")
                                            .foregroundStyle(.green)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(plant.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(plant.species)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if plant.isOverdue {
                                Text("\(plant.daysOverdue)d")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.red)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    let entry: PlantWidgetEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Plants Needing Water Today", systemImage: "drop.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                Spacer()
                Text("\(entry.plantsNeedingWater.count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            Divider()

            if entry.plantsNeedingWater.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("All your plants are watered!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Check back tomorrow")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(entry.plantsNeedingWater) { plant in
                            HStack(spacing: 12) {
                                if let photoData = plant.photoData,
                                   let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.green.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay {
                                            Image(systemName: "leaf.fill")
                                                .font(.title3)
                                                .foregroundStyle(.green)
                                        }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plant.name)
                                        .font(.headline)
                                    Text(plant.species)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(spacing: 4) {
                                    Image(systemName: "drop.fill")
                                        .foregroundStyle(.blue)
                                    if plant.isOverdue {
                                        Text("\(plant.daysOverdue)d")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct PlantCareWidget: Widget {
    let kind: String = "PlantCareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PlantCareWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PlantCare")
        .description("See which plants need watering today")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    PlantCareWidget()
} timeline: {
    PlantWidgetEntry(
        date: .now,
        plantsNeedingWater: [
            PlantWidgetData(id: "1", name: "Monstera", species: "Monstera deliciosa", daysOverdue: 0, photoData: nil),
            PlantWidgetData(id: "2", name: "Snake Plant", species: "Sansevieria", daysOverdue: 2, photoData: nil)
        ]
    )
}

#Preview(as: .systemMedium) {
    PlantCareWidget()
} timeline: {
    PlantWidgetEntry(
        date: .now,
        plantsNeedingWater: [
            PlantWidgetData(id: "1", name: "Monstera", species: "Monstera deliciosa", daysOverdue: 0, photoData: nil),
            PlantWidgetData(id: "2", name: "Snake Plant", species: "Sansevieria", daysOverdue: 2, photoData: nil),
            PlantWidgetData(id: "3", name: "Pothos", species: "Epipremnum aureum", daysOverdue: 1, photoData: nil)
        ]
    )
}

// Define models for the widget target
import Foundation
import SwiftData

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
}

enum PlantLocation: String, Codable, CaseIterable {
    case indoor = "Indoor"
    case outdoor = "Outdoor"
}

@Model
final class WateringLog {
    var id: UUID
    var date: Date
    var notes: String
    var plant: Plant?

    init(date: Date = Date(), notes: String = "") {
        self.id = UUID()
        self.date = date
        self.notes = notes
    }
}

@Model
final class HealthLog {
    var id: UUID
    var date: Date
    var notes: String
    var photoData: Data?
    var plant: Plant?

    init(date: Date = Date(), notes: String, photoData: Data? = nil) {
        self.id = UUID()
        self.date = date
        self.notes = notes
        self.photoData = photoData
    }
}
