import Foundation

actor FileScanner {
    struct Progress {
        let scannedItems: Int
        let currentFile: String
        let totalSize: Int64
    }

    enum ScanError: Error, LocalizedError {
        case directoryNotFound(String)
        case accessDenied(String)
        case cancelled

        var errorDescription: String? {
            switch self {
            case .directoryNotFound(let path):
                return "Directory not found: \(path)"
            case .accessDenied(let path):
                return "Access denied: \(path)"
            case .cancelled:
                return "Scan was cancelled"
            }
        }
    }

    private var isCancelled = false

    func cancel() {
        isCancelled = true
    }

    func scan(
        profile: ScanProfile,
        progressHandler: @escaping @Sendable (Progress) -> Void
    ) async throws -> [ScannedFile] {
        isCancelled = false

        let fileManager = FileManager.default
        let baseURL = URL(fileURLWithPath: profile.directory)

        guard fileManager.fileExists(atPath: profile.directory) else {
            throw ScanError.directoryNotFound(profile.directory)
        }

        var scannedFiles: [ScannedFile] = []
        var scannedCount = 0
        var totalSize: Int64 = 0

        let exclusionManager = ExclusionManager(excludeSystemDirs: profile.excludeSystemDirs)
        let minSizeBytes = Int64(profile.minSizeMB * 1_000_000)
        let maxSizeBytes = profile.maxSizeMB.map { Int64($0 * 1_000_000) }

        let enumerator = fileManager.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )

        guard let directoryEnumerator = enumerator else {
            throw ScanError.accessDenied(profile.directory)
        }

        var fileURL: URL?
        while !isCancelled {
            fileURL = directoryEnumerator.nextObject() as? URL
            
            guard let currentURL = fileURL else {
                break
            }

            let path = currentURL.path

            if exclusionManager.shouldExclude(path: path) {
                directoryEnumerator.skipDescendants()
                continue
            }

            do {
                let resourceValues = try currentURL.resourceValues(forKeys: [
                    .fileSizeKey,
                    .contentModificationDateKey,
                    .isRegularFileKey
                ])

                guard resourceValues.isRegularFile == true,
                      let fileSize = resourceValues.fileSize,
                      fileSize >= minSizeBytes else {
                    continue
                }

                if let maxBytes = maxSizeBytes, fileSize > maxBytes {
                    continue
                }

                let fileExtension = currentURL.pathExtension.lowercased()
                if !profile.extensions.isEmpty && !profile.extensions.contains(fileExtension) {
                    continue
                }

                let modifiedDate = resourceValues.contentModificationDate ?? Date.distantPast
                let name = currentURL.lastPathComponent

                let scannedFile = ScannedFile(
                    path: path,
                    name: name,
                    size: Int64(fileSize),
                    modifiedDate: modifiedDate,
                    extension_: fileExtension
                )

                scannedFiles.append(scannedFile)
                totalSize += Int64(fileSize)
                scannedCount += 1

                if scannedCount % 100 == 0 {
                    progressHandler(Progress(
                        scannedItems: scannedCount,
                        currentFile: name,
                        totalSize: totalSize
                    ))
                }

            } catch {
                continue
            }
        }

        if isCancelled {
            throw ScanError.cancelled
        }

        scannedFiles = sortFiles(scannedFiles, by: profile.sortBy)

        if profile.limit > 0 && scannedFiles.count > profile.limit {
            scannedFiles = Array(scannedFiles.prefix(profile.limit))
        }

        return scannedFiles
    }

    private func sortFiles(_ files: [ScannedFile], by field: ScanProfile.SortField) -> [ScannedFile] {
        switch field {
        case .size:
            return files.sorted { $0.size > $1.size }
        case .name:
            return files.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .path:
            return files.sorted { $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending }
        case .modified:
            return files.sorted { $0.modifiedDate > $1.modifiedDate }
        }
    }
}
