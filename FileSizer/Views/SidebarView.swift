import SwiftUI

struct SidebarView: View {
    @Binding var profile: ScanProfile
    @Binding var showingHistory: Bool
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                searchField
                
                sizeSection
                
                sortSection
                
                optionsSection
                
                Spacer(minLength: 20)
                
                historyButton
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .frame(minWidth: 220)
        .background(Color.accentColor.opacity(0.12))
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.caption)
            TextField("Search...", text: $profile.searchText)
                .textFieldStyle(.plain)
                .font(.caption)
                .focused($isSearchFocused)
                .onSubmit { isSearchFocused = false }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.primary.opacity(0.08))
        .cornerRadius(8)
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("SIZE")

            VStack(spacing: 12) {
                HStack {
                    Text("Min:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(profile.minSizeMB)) MB")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .controlSize(.small)

                DottedDivider()

                HStack {
                    Text("Max:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    if let maxMB = profile.maxSizeMB {
                        Text("\(Int(maxMB)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else {
                        Text("No limit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if profile.maxSizeMB != nil {
                        Button(action: { profile.maxSizeMB = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if profile.maxSizeMB != nil {
                    Slider(value: Binding(
                        get: { profile.maxSizeMB ?? 500 },
                        set: { profile.maxSizeMB = $0 }
                    ), in: 1...10000, step: 10)
                    .controlSize(.small)
                } else {
                    Button("Set max") {
                        profile.maxSizeMB = 500
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("SORT")

            VStack(spacing: 12) {
                HStack {
                    Text("Primary:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $profile.sortBy) {
                        ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                            Text(field.rawValue).tag(field)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 100)
                }

                HStack {
                    Text("Secondary:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { profile.secondarySortBy ?? .name },
                        set: { profile.secondarySortBy = $0 }
                    )) {
                        Text("None").tag(ScanProfile.SortField.name)
                        ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                            Text(field.rawValue).tag(field)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 100)
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("OPTIONS")

            VStack(spacing: 12) {
                HStack {
                    Text("Limit:")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(profile.limit == 0 ? "No limit" : "\(profile.limit)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .controlSize(.small)

                Toggle("Exclude system dirs", isOn: $profile.excludeSystemDirs)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(10)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private var historyButton: some View {
        Button(action: { showingHistory = true }) {
            HStack {
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                Text("History")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
}

struct DirectoryPickerButton: View {
    @Binding var directory: String

    var body: some View {
        Button(action: pickDirectory) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.accentColor)
                Text(truncatedPath)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.primary.opacity(0.06))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var truncatedPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if directory.hasPrefix(home) {
            let relative = String(directory.dropFirst(home.count))
            return "~" + relative
        }
        if directory.count > 40 {
            return "..." + String(directory.suffix(37))
        }
        return directory
    }

    private func pickDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: directory)

        if panel.runModal() == .OK {
            if let url = panel.url {
                directory = url.path
            }
        }
    }
}

struct DottedDivider: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<Int(geometry.size.width / 6), id: \.self) { _ in
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 3, height: 3)
                }
            }
        }
        .frame(height: 3)
    }
}
