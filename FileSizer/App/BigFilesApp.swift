import SwiftUI
import AppKit

@main
struct BigFilesApp: App {
    @StateObject private var viewModel = ScanViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
        .commands {
            // Remove default New command
            CommandGroup(replacing: .newItem) {}

            // Scan command
            CommandGroup(after: .sidebar) {
                Button("New Scan") {
                    Task { await viewModel.startScan() }
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Cancel Scan") {
                    viewModel.cancelScan()
                }
                .keyboardShortcut(".", modifiers: .command)
                .disabled(!viewModel.isScanning)
            }

            // Export command
            CommandGroup(after: .saveItem) {
                Button("Export...") {
                    // Export action - handled by toolbar
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(viewModel.files.isEmpty)
            }

            // Focus search
            CommandGroup(after: .sidebar) {
                Divider()
                Button("Focus Search") {
                    NotificationCenter.default.post(name: .focusSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }

        // Settings for window
        Settings {
            // Could add preferences window here
        }
    }
}

extension Notification.Name {
    static let focusSearch = Notification.Name("focusSearch")
}
