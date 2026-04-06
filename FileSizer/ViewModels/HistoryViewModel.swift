import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var historyItems: [ScanResult] = []

    private let store = ScanHistoryStore.shared

    func load() {
        historyItems = store.loadHistory()
    }

    func delete(_ item: ScanResult) {
        store.delete(id: item.id)
        historyItems.removeAll { $0.id == item.id }
    }

    func clearAll() {
        store.clearAll()
        historyItems.removeAll()
    }
}
