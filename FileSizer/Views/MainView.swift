import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ScanViewModel()
    @State private var showingHistory = false
    @State private var showingExport = false
    @State private var showingDeleteAlert = false
    @State private var fileToDelete: ScannedFile?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText = ""
    @State private var isQuickLookActive = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(profile: $viewModel.profile, showingHistory: $showingHistory)
        } detail: {
            VStack(spacing: 0) {
                headerBar
                searchBar
                Divider()
                progressSection
                Divider()
                contentArea
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    Task { await viewModel.startScan() }
                }) {
                    Label("Scan", systemImage: "magnifyingglass")
                }
                .disabled(viewModel.isScanning)
                .keyboardShortcut("s", modifiers: .command)

                Button(action: { showingExport = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.files.isEmpty)
                .keyboardShortcut("e", modifiers: .command)
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
                    NotificationManager.shared.sendFilesTrashedNotification(count: 1)
                }
            }
        } message: {
            if let file = fileToDelete {
                Text("Are you sure you want to move \"\(file.name)\" to Trash?")
            }
        }
        .onAppear {
            setupKeyboardShortcuts()
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if viewModel.allFiles.isEmpty && !viewModel.isScanning {
                    Text("Ready to scan")
                        .font(.headline)
                    Text("Configure filters and click Scan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if viewModel.isScanning {
                    Text("Scanning...")
                        .font(.headline)
                    Text(viewModel.profile.directory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    let count = viewModel.files.count
                    let total = viewModel.allFiles.count
                    if count == total {
                        Text("\(count) files")
                            .font(.headline)
                    } else {
                        Text("\(count) of \(total) files")
                            .font(.headline)
                    }
                    Text(viewModel.profile.directory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search files...", text: $viewModel.profile.searchText)
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .onSubmit {
                    isSearchFocused = false
                }

            if !viewModel.profile.searchText.isEmpty {
                Button(action: { viewModel.profile.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.08))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var progressSection: some View {
        if viewModel.isScanning, let progress = viewModel.progress {
            ScanProgressBar(progress: progress)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isScanning, let progress = viewModel.progress {
            ScanProgressHUDView(
                progress: progress,
                isScanning: viewModel.isScanning,
                onCancel: { viewModel.cancelScan() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.selectedFile != nil && isQuickLookActive {
            // QuickLook panel is handled by QuickLookController.shared
            // This view is just a placeholder
            VStack {
                Text("Press Space or double-click to QuickLook")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        } else {
            FileListView(
                viewModel: viewModel,
                onRevealInFinder: { file in
                    viewModel.revealInFinder(file)
                },
                onDelete: { file in
                    fileToDelete = file
                    showingDeleteAlert = true
                },
                onQuickLook: { file in
                    viewModel.selectedFile = file
                    isQuickLookActive = true
                    QuickLookController.shared.showPanel(for: file)
                }
            )
        }
    }

    private func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Space = QuickLook
            if event.keyCode == 49, viewModel.selectedFile != nil { // Space
                DispatchQueue.main.async {
                    isQuickLookActive.toggle()
                    if isQuickLookActive, let file = viewModel.selectedFile {
                        QuickLookController.shared.showPanel(for: file)
                    }
                }
                return nil
            }
            // Cmd+Backspace = Delete
            if event.keyCode == 51 && event.modifierFlags.contains(.command), let file = viewModel.selectedFile {
                DispatchQueue.main.async {
                    fileToDelete = file
                    showingDeleteAlert = true
                }
                return nil
            }
            // Cmd+F = Focus search
            if event.keyCode == 3 && event.modifierFlags.contains(.command) { // F
                DispatchQueue.main.async {
                    isSearchFocused = true
                }
                return nil
            }
            // Escape = Close QuickLook or clear search
            if event.keyCode == 53 { // Escape
                if isQuickLookActive {
                    isQuickLookActive = false
                    return nil
                }
            }
            return event
        }
    }
}
