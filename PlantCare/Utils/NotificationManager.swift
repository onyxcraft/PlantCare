import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleWateringNotification(for plant: Plant) {
        guard let nextWateringDate = plant.nextWateringDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to Water! 💧"
        content.body = "\(plant.name) needs watering today."
        content.sound = .default
        content.badge = 1

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextWateringDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotification(for plant: Plant) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [plant.id.uuidString]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func rescheduleAllNotifications(for plants: [Plant]) {
        cancelAllNotifications()
        plants.forEach { scheduleWateringNotification(for: $0) }
    }
}
