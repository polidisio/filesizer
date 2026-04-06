import SwiftUI

@main
struct BigFilesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandGroup(after: .sidebar) {
                Button("New Scan") {
                    NotificationCenter.default.post(name: .startScan, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let startScan = Notification.Name("startScan")
}
