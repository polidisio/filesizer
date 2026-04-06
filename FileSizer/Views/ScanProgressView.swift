import SwiftUI

struct ScanProgressView: View {
    let progress: FileScanner.Progress?
    let isScanning: Bool
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()

            if let prog = progress {
                VStack(spacing: 8) {
                    Text("Scanning...")
                        .font(.headline)
                    Text(prog.currentFile)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("\(prog.scannedItems) items scanned")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Preparing scan...")
                    .font(.headline)
            }

            Button("Cancel", action: onCancel)
                .buttonStyle(.bordered)
        }
        .frame(width: 280, height: 180)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
