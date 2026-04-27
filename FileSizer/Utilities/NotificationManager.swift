import Foundation
import UserNotifications

/// Notification manager for macOS notification center
final class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private var isAuthorized = false

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func sendScanCompleteNotification(
        fileCount: Int,
        totalSize: Int64,
        duration: TimeInterval,
        directory: String
    ) {
        guard isAuthorized else {
            requestAuthorization()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🔍 Scan Complete"
        content.body = "Found \(fileCount) files (\(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)))"
        content.sound = .default

        // Add info to userInfo for potential deep linking
        content.userInfo = [
            "fileCount": fileCount,
            "totalSize": totalSize,
            "duration": duration,
            "directory": directory
        ]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

    func sendErrorNotification(message: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "❌ Scan Error"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func sendFilesTrashedNotification(count: Int) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🗑️ Files Removed"
        content.body = "\(count) file(s) moved to Trash"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
