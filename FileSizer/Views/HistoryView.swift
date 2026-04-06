import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    var onSelectProfile: (ScanProfile) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scan History")
                    .font(.headline)
                Spacer()
                if !viewModel.historyItems.isEmpty {
                    Button("Clear All", role: .destructive) {
                        viewModel.clearAll()
                    }
                    .buttonStyle(.bordered)
                }
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if viewModel.historyItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No scan history")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.historyItems) { item in
                        HistoryRowView(item: item) {
                            onSelectProfile(item.profile)
                            dismiss()
                        }
                        .contextMenu {
                            Button("Use This Profile") {
                                onSelectProfile(item.profile)
                                dismiss()
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                viewModel.delete(item)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 400)
        .onAppear {
            viewModel.load()
        }
    }
}

struct HistoryRowView: View {
    let item: ScanResult
    let onUse: () -> Void

    var body: some View {
        Button(action: onUse) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.profile.directory)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Text(item.scanDateDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 16) {
                    Label("\(item.totalFilesFound) files", systemImage: "doc.fill")
                    Label(item.totalSizeDescription, systemImage: "externaldrive.fill")
                    Label("\(Int(item.profile.minSizeMB)) MB+", systemImage: "arrow.up")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
