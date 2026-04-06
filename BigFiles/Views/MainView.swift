import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ScanViewModel()
    @State private var showingHistory = false
    @State private var showingExport = false
    @State private var showingDeleteAlert = false
    @State private var fileToDelete: ScannedFile?

    var body: some View {
        NavigationSplitView {
            SidebarView(profile: $viewModel.profile, showingHistory: $showingHistory)
        } detail: {
            ZStack {
                if viewModel.isScanning, let progress = viewModel.progress {
                    ScanProgressView(
                        progress: progress,
                        isScanning: viewModel.isScanning,
                        onCancel: { viewModel.cancelScan() }
                    )
                }

                FileListView(
                    viewModel: viewModel,
                    onRevealInFinder: { file in
                        viewModel.revealInFinder(file)
                    },
                    onDelete: { file in
                        fileToDelete = file
                        showingDeleteAlert = true
                    }
                )
            }
            .overlay(alignment: .bottom) {
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.startScan() }
                }) {
                    Label("Scan", systemImage: "magnifyingglass")
                }
                .disabled(viewModel.isScanning)

                Button(action: { showingExport = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.files.isEmpty)
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView { profile in
                viewModel.profile = profile
            }
        }
        .sheet(isPresented: $showingExport) {
            ExportView(
                onExportCSV: { viewModel.exportToCSV() },
                onExportJSON: { viewModel.exportToJSON() }
            )
        }
        .alert("Move to Trash?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Move to Trash", role: .destructive) {
                if let file = fileToDelete {
                    try? viewModel.moveToTrash(file)
                }
            }
        } message: {
            if let file = fileToDelete {
                Text("Are you sure you want to move \"\(file.name)\" to Trash?")
            }
        }
    }

    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
            Spacer()
            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
