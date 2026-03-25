import Foundation
import SwiftData

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
