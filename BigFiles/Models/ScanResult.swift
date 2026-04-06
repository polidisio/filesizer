import Foundation

struct ScanResult: Identifiable, Codable {
    let id: UUID
    let profile: ScanProfile
    let files: [ScannedFile]
    let scanDate: Date
    let totalFilesFound: Int
    let totalSize: Int64

    var totalSizeDescription: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var scanDateDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scanDate)
    }

    init(profile: ScanProfile, files: [ScannedFile], scanDate: Date = Date()) {
        self.id = UUID()
        self.profile = profile
        self.files = files
        self.scanDate = scanDate
        self.totalFilesFound = files.count
        self.totalSize = files.reduce(0) { $0 + $1.size }
    }
}
