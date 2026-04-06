import Foundation
import CoreServices

struct FinderComments {
    static func readComment(for url: URL) -> String? {
        guard let mdItem = MDItemCreateWithURL(nil, url as CFURL) else { return nil }
        return MDItemCopyAttribute(mdItem, kMDItemComment) as? String
    }

    static func writeComment(_ comment: String, to url: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        process.arguments = ["-w", "com.apple.metadata:kMDItemFinderComment", comment, url.path]
        try process.run()
        process.waitUntilExit()
    }

    static func deleteComment(from url: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        process.arguments = ["-d", "com.apple.metadata:kMDItemFinderComment", url.path]
        try process.run()
        process.waitUntilExit()
    }
}
