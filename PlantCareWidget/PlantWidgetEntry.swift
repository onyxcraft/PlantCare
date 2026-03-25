import WidgetKit
import SwiftUI

struct PlantWidgetEntry: TimelineEntry {
    let date: Date
    let plantsNeedingWater: [PlantWidgetData]
}

struct PlantWidgetData: Identifiable {
    let id: String
    let name: String
    let species: String
    let daysOverdue: Int
    let photoData: Data?

    var isOverdue: Bool {
        daysOverdue > 0
    }
}
