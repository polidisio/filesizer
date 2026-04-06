import Foundation
import SQLite

final class ScanHistoryStore {
    static let shared = ScanHistoryStore()

    private var db: Connection?

    private let history = Table("scan_history")
    private let id = Expression<String>("id")
    private let profileData = Expression<Data>("profile_data")
    private let fileCount = Expression<Int>("file_count")
    private let totalSize = Expression<Int64>("total_size")
    private let scanDate = Expression<Date>("scan_date")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!

            let appFolder = appSupport.appendingPathComponent("BigFiles", isDirectory: true)
            try FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

            let dbPath = appFolder.appendingPathComponent("history.sqlite3")
            db = try Connection(dbPath.path)

            try db?.run(history.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(profileData)
                t.column(fileCount)
                t.column(totalSize)
                t.column(scanDate)
            })
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    func save(result: ScanResult) {
        guard let db = db else { return }

        do {
            let encoder = JSONEncoder()
            let profileEncoded = try encoder.encode(result.profile)

            let insert = history.insert(
                id <- result.id.uuidString,
                profileData <- profileEncoded,
                fileCount <- result.totalFilesFound,
                totalSize <- result.totalSize,
                scanDate <- result.scanDate
            )

            try db.run(insert)
        } catch {
            print("Failed to save scan result: \(error)")
        }
    }

    func loadHistory() -> [ScanResult] {
        guard let db = db else { return [] }

        var results: [ScanResult] = []
        let decoder = JSONDecoder()

        do {
            for row in try db.prepare(history.order(scanDate.desc)) {
                guard let profile = try? decoder.decode(ScanProfile.self, from: row[profileData]) else {
                    continue
                }

                let result = ScanResult(
                    profile: profile,
                    files: [],
                    scanDate: row[scanDate]
                )
                results.append(result)
            }
        } catch {
            print("Failed to load history: \(error)")
        }

        return results
    }

    func delete(id scanId: UUID) {
        guard let db = db else { return }

        do {
            let item = history.filter(id == scanId.uuidString)
            try db.run(item.delete())
        } catch {
            print("Failed to delete: \(error)")
        }
    }

    func clearAll() {
        guard let db = db else { return }

        do {
            try db.run(history.delete())
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}
