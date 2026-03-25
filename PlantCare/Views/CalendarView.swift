import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CalendarMonthView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate,
                        plants: plants
                    )
                    .padding(.horizontal)

                    WateringEventsView(
                        selectedDate: selectedDate,
                        plants: plants
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Calendar")
        }
    }
}

struct CalendarMonthView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let plants: [Plant]

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasWatering: hasWateringOnDate(date),
                            plants: plants
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func getDaysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    private func hasWateringOnDate(_ date: Date) -> Bool {
        plants.contains { plant in
            plant.wateringLogs.contains { log in
                calendar.isDate(log.date, inSameDayAs: date)
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasWatering: Bool
    let plants: [Plant]

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : (isToday ? .blue : .primary))

            if hasWatering {
                Circle()
                    .fill(isSelected ? .white : .blue)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(isSelected ? Color.blue : Color.clear)
        .clipShape(Circle())
    }
}

struct WateringEventsView: View {
    let selectedDate: Date
    let plants: [Plant]

    private let calendar = Calendar.current

    var wateringsOnDate: [(Plant, WateringLog)] {
        plants.flatMap { plant in
            plant.wateringLogs
                .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
                .map { (plant, $0) }
        }
        .sorted { $0.1.date > $1.1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(date: .long, time: .omitted))
                .font(.headline)

            if wateringsOnDate.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No waterings on this date")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(wateringsOnDate, id: \.1.id) { plant, log in
                        HStack {
                            if let photoData = plant.photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.green.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image(systemName: "leaf.fill")
                                            .foregroundStyle(.green)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(plant.name)
                                    .font(.headline)
                                Text("Watered at \(log.date.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "drop.fill")
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [Plant.self, WateringLog.self, HealthLog.self])
}
