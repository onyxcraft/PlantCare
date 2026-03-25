import Foundation

struct CareTip: Identifiable, Codable {
    let id: UUID
    let plantName: String
    let scientificName: String
    let wateringFrequency: String
    let sunlight: String
    let soilType: String
    let temperature: String
    let humidity: String
    let fertilizing: String
    let commonIssues: [String]
    let tips: [String]

    init(
        plantName: String,
        scientificName: String,
        wateringFrequency: String,
        sunlight: String,
        soilType: String,
        temperature: String,
        humidity: String,
        fertilizing: String,
        commonIssues: [String],
        tips: [String]
    ) {
        self.id = UUID()
        self.plantName = plantName
        self.scientificName = scientificName
        self.wateringFrequency = wateringFrequency
        self.sunlight = sunlight
        self.soilType = soilType
        self.temperature = temperature
        self.humidity = humidity
        self.fertilizing = fertilizing
        self.commonIssues = commonIssues
        self.tips = tips
    }
}
