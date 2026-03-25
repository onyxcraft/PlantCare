import SwiftUI

struct CareTipsView: View {
    @State private var searchText = ""
    @State private var selectedTip: CareTip?

    private var filteredTips: [CareTip] {
        CareTipsDatabase.shared.searchTips(query: searchText)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTips) { tip in
                    Button {
                        selectedTip = tip
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tip.plantName)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(tip.scientificName)
                                .font(.subheadline)
                                .italic()
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Label(tip.wateringFrequency, systemImage: "drop.fill")
                                    .font(.caption)
                                Label(tip.sunlight, systemImage: "sun.max.fill")
                                    .font(.caption)
                            }
                            .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Care Tips")
            .searchable(text: $searchText, prompt: "Search plants")
            .sheet(item: $selectedTip) { tip in
                CareTipDetailView(careTip: tip)
            }
        }
    }
}

struct CareTipDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let careTip: CareTip

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(careTip.plantName)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(careTip.scientificName)
                            .font(.title3)
                            .italic()
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    CareInfoSection(title: "Watering", icon: "drop.fill", color: .blue) {
                        Text(careTip.wateringFrequency)
                    }

                    CareInfoSection(title: "Sunlight", icon: "sun.max.fill", color: .orange) {
                        Text(careTip.sunlight)
                    }

                    CareInfoSection(title: "Soil", icon: "mountain.2.fill", color: .brown) {
                        Text(careTip.soilType)
                    }

                    CareInfoSection(title: "Temperature", icon: "thermometer.medium", color: .red) {
                        Text(careTip.temperature)
                    }

                    CareInfoSection(title: "Humidity", icon: "humidity.fill", color: .cyan) {
                        Text(careTip.humidity)
                    }

                    CareInfoSection(title: "Fertilizing", icon: "leaf.fill", color: .green) {
                        Text(careTip.fertilizing)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Common Issues", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundStyle(.yellow)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(careTip.commonIssues, id: \.self) { issue in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(issue)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Care Tips", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(careTip.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(tip)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CareInfoSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content

    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            content
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CareTipsView()
}
