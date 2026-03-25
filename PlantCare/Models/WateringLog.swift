import Foundation
import SwiftData

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
