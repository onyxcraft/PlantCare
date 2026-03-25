import SwiftUI

struct HealthLogView: View {
    let plant: Plant

    var body: some View {
        List {
            if plant.healthLogs.isEmpty {
                ContentUnavailableView(
                    "No Health Logs",
                    systemImage: "heart.text.square",
                    description: Text("Add health logs to track your plant's progress")
                )
            } else {
                ForEach(plant.healthLogs.sorted(by: { $0.date > $1.date })) { log in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(log.date.formatted(date: .long, time: .shortened))
                                .font(.headline)
                            Spacer()
                        }

                        if let photoData = log.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Text(log.notes)
                            .font(.body)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Health Log")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HealthLogView(plant: Plant(
            name: "Monstera",
            species: "Monstera deliciosa",
            location: .indoor,
            wateringIntervalDays: 7
        ))
    }
}
