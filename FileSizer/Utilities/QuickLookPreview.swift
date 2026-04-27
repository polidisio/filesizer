import Foundation
import Quartz
import AppKit

/// QuickLook panel controller for file previews
final class QuickLookController: NSObject, QLPreviewPanelDelegate, QLPreviewPanelDataSource {

    static let shared = QuickLookController()

    private(set) var currentFile: ScannedFile?

    func showPanel(for file: ScannedFile) {
        currentFile = file

        guard let panel = QLPreviewPanel.shared() else { return }

        if QLPreviewPanel.sharedPreviewPanelExists() && panel.isVisible {
            panel.reloadData()
        } else {
            panel.delegate = self
            panel.dataSource = self
            panel.makeKeyAndOrderFront(nil)
        }
    }

    func hidePanel() {
        QLPreviewPanel.shared()?.orderOut(nil)
        currentFile = nil
    }

    // MARK: - QLPreviewPanelDataSource

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return currentFile != nil ? 1 : 0
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> (any QLPreviewItem)! {
        guard let file = currentFile else { return nil }
        return file.url as NSURL
    }

    // MARK: - QLPreviewPanelDelegate

    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type == .keyDown {
            switch event.keyCode {
            case 53: // Escape
                hidePanel()
                return true
            default:
                break
            }
        }
        return false
    }
}
