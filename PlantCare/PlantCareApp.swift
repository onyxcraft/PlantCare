import SwiftUI
import SwiftData

@main
struct PlantCareApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Plant.self, WateringLog.self, HealthLog.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
