import Foundation

struct ExclusionManager {
    static let defaultExcludedDirs: Set<String> = [
        ".git",
        "node_modules",
        "__pycache__",
        "Caches",
        ".cache",
        ".npm",
        ".pip",
        ".cargo",
        "vendor",
        ".cocoapods",
        ".swiftpm",
        "Pods",
        ".build",
        "DerivedData"
    ]

    static let defaultExcludedPatterns: Set<String> = [
        "^\\.DS_Store$",
        "^\\.Spotlight-V100$",
        "^\\.Trashes$",
        "^\\.fseventsd$",
        "^\\.TemporaryItems$",
        "^\\.DocumentRevisions-V100$"
    ]

    var excludedDirs: Set<String>
    var excludedPatterns: [String]

    init(excludeSystemDirs: Bool = true) {
        self.excludedDirs = excludeSystemDirs ? Self.defaultExcludedDirs : []
        self.excludedPatterns = excludeSystemDirs ? Array(Self.defaultExcludedPatterns) : []
    }

    func shouldExclude(path: String) -> Bool {
        let components = path.components(separatedBy: "/")
        for component in components {
            if excludedDirs.contains(component) {
                return true
            }
        }

        let filename = (path as NSString).lastPathComponent
        for pattern in excludedPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(filename.startIndex..., in: filename)
                if regex.firstMatch(in: filename, options: [], range: range) != nil {
                    return true
                }
            }
        }
        return false
    }
}
