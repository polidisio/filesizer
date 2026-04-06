import Foundation

struct ScannedFile: Identifiable, Codable, Hashable {
    let id: UUID
    let path: String
    let name: String
    let size: Int64
    let modifiedDate: Date
    let extension_: String
    var finderComment: String?

    var url: URL {
        URL(fileURLWithPath: path)
    }

    var sizeDescription: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var modifiedDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modifiedDate)
    }

    init(path: String, name: String, size: Int64, modifiedDate: Date, extension_: String, finderComment: String? = nil) {
        self.id = UUID()
        self.path = path
        self.name = name
        self.size = size
        self.modifiedDate = modifiedDate
        self.extension_ = extension_
        self.finderComment = finderComment
    }
}
