import SwiftUI
import AppKit

/// Progress HUD view with macOS Finder-style blur and determinate progress
struct ScanProgressHUDView: View {
    let progress: FileScanner.Progress?
    let isScanning: Bool
    let onCancel: () -> Void

    @State private var displayedProgress: Double = 0
    @State private var scanRate: String = "0"

    var body: some View {
        VStack(spacing: 16) {
            // Animated progress indicator
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: displayedProgress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: displayedProgress)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
            }

            // Stats
            if let prog = progress {
                VStack(spacing: 8) {
                    Text("Scanning...")
                        .font(.headline)

                    Text(prog.currentFile)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: 300)
                        .truncationMode(.middle)

                    HStack(spacing: 16) {
                        StatView(
                            icon: "doc.on.doc",
                            value: "\(prog.scannedItems.formatted())",
                            label: "files"
                        )

                        Divider()
                            .frame(height: 30)

                        StatView(
                            icon: "externaldrive",
                            value: ByteCountFormatter.string(fromByteCount: prog.totalSize, countStyle: .file),
                            label: "found"
                        )

                        Divider()
                            .frame(height: 30)

                        StatView(
                            icon: "speedometer",
                            value: scanRate,
                            label: "/sec"
                        )
                    }

                    // Progress bar
                    ProgressView(value: min(displayedProgress, 1.0))
                        .progressViewStyle(.linear)
                        .frame(width: 250)
                        .tint(.accentColor)
                }
            } else {
                Text("Preparing scan...")
                    .font(.headline)
                Text("Counting files...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("Cancel") {
                onCancel()
            }
            .buttonStyle(.bordered)
            .keyboardShortcut(.escape)
        }
        .padding(30)
        .frame(width: 350)
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            startAnimation()
        }
        .onChange(of: progress?.scannedItems) { newValue in
            updateProgress(newValue ?? 0)
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard isScanning else {
                timer.invalidate()
                return
            }
            // Pulse animation
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                displayedProgress = min(displayedProgress + 0.02, 0.9)
            }
        }
    }

    private func updateProgress(_ scannedItems: Int) {
        // Simulate determinate progress based on scan rate
        let rate = max(scannedItems / 100, 1)
        scanRate = "\(rate)"
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Compact Progress Bar for Header

struct ScanProgressBar: View {
    let progress: FileScanner.Progress?

    var body: some View {
        if let prog = progress {
            HStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.7)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Scanning: \(prog.currentFile)")
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    HStack(spacing: 8) {
                        Text("\(prog.scannedItems.formatted()) items")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(ByteCountFormatter.string(fromByteCount: prog.totalSize, countStyle: .file))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
