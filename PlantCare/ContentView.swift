import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PlantListView()
                .tabItem {
                    Label("Plants", systemImage: "leaf.fill")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)

            CareTipsView()
                .tabItem {
                    Label("Care Tips", systemImage: "book.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Plant.self, WateringLog.self, HealthLog.self])
}
