import Foundation
import AppKit

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var profile = ScanProfile()
    @Published var files: [ScannedFile] = []
    @Published var isScanning = false
    @Published var progress: FileScanner.Progress?
    @Published var errorMessage: String?
    @Published var selectedFile: ScannedFile?

    private let scanner = FileScanner()
    private let historyStore = ScanHistoryStore.shared

    var currentResult: ScanResult? {
        guard !files.isEmpty else { return nil }
        return ScanResult(profile: profile, files: files)
    }

    func startScan() async {
        guard !isScanning else { return }

        isScanning = true
        errorMessage = nil
        files = []
        progress = nil

        do {
            let scannedFiles = try await scanner.scan(profile: profile) { [weak self] prog in
                Task { @MainActor in
                    self?.progress = prog
                }
            }

            files = scannedFiles

            if !files.isEmpty {
                let result = ScanResult(profile: profile, files: files)
                historyStore.save(result: result)
            }
        } catch let error as FileScanner.ScanError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isScanning = false
        progress = nil
    }

    func cancelScan() {
        Task {
            await scanner.cancel()
        }
    }

    func moveToTrash(_ file: ScannedFile) throws {
        let url = URL(fileURLWithPath: file.path)
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        files.removeAll { $0.id == file.id }
    }

    func revealInFinder(_ file: ScannedFile) {
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
    }

    func exportToCSV() -> URL? {
        var csv = "Name,Path,Size,Modified,Extension\n"
        for file in files {
            let row = "\"\(file.name)\",\"\(file.path)\",\(file.size),\"\(file.modifiedDescription)\",\"\(file.extension_)\"\n"
            csv += row
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("bigfiles_export_\(Date().timeIntervalSince1970).csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    func exportToJSON() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(files)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("bigfiles_export_\(Date().timeIntervalSince1970).json")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}
