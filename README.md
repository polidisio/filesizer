# BigFiles for macOS

<p align="center">
  <img src="https://img.icons8.com/color/96/000000/search--v1.png" alt="BigFiles Icon" width="80"/>
</p>

<p align="center">
  <strong>Official native macOS app for finding large files</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/swift-5.9-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/platform-macOS%2013+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/App%20Store-Ready-blue.svg" alt="App Store">
</p>

---

## Features

- **Native SwiftUI** - Modern macOS interface with NavigationSplitView
- **Async Scanning** - Fast directory traversal without blocking the UI
- **File Management** - Move files to Trash, Reveal in Finder
- **Scan History** - Re-run past scans with one click
- **Export** - Save results as CSV or JSON
- **Finder Comments** - Read and write Finder comments directly
- **App Store Ready** - Sandboxed with Hardened Runtime

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0+

## Building from Source

```bash
# Clone the repo
git clone https://github.com/polidisio/bigfiles-mac.git
cd bigfiles-mac

# Generate Xcode project (requires XcodeGen)
xcodegen generate

# Open in Xcode
open BigFiles.xcodeproj
```

Then in Xcode: **Product > Run** (⌘R) to build and run.

## Project Structure

```
BigFiles/
├── App/                 # App entry point
├── Models/              # Data models (ScannedFile, ScanProfile, ScanResult)
├── ViewModels/          # MVVM view models
├── Views/               # SwiftUI views
├── Services/            # FileScanner, ExclusionManager, FinderComments
├── Persistence/         # SQLite.swift for scan history
└── Resources/           # Info.plist, entitlements, assets
```

## Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI with NavigationSplitView
- **Persistence**: SQLite.swift for scan history
- **Build System**: XcodeGen with Swift Package Manager

## Related

- **CLI Tool**: [bigfiles](https://github.com/polidisio/bigfiles) - Python CLI version

## License

MIT License - see [LICENSE](LICENSE)

## Author

Jose M. - [polidisio](https://github.com/polidisio)
