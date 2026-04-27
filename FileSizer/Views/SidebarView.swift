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

                extensionsSection

                sortSection

                optionsSection

                Spacer(minLength: 20)

                historyButton
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .frame(minWidth: 280, idealWidth: 300)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var extensionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionLabel("EXTENSIONS")
                Spacer()
                if !profile.extensions.isEmpty {
                    Button(action: { profile.extensions = [] }) {
                        Text("Clear")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 10) {
                if profile.extensions.isEmpty {
                    Text("All extensions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(profile.extensions, id: \.self) { ext in
                                ExtensionChip(text: ext) {
                                    profile.extensions.removeAll { $0 == ext }
                                }
                            }
                        }
                    }
                }

                HStack {
                    TextField("Add ext...", text: $newExtension)
                        .textFieldStyle(.plain)
                        .font(.caption)
                        .frame(height: 26)
                        .padding(.horizontal, 10)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(6)
                        .onSubmit {
                            addExtension()
                        }

                    Button(action: { addExtension() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }

                // Quick add buttons - 2x2 grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ], spacing: 6) {
                    QuickAddButton(label: "Images") { addExtension("jpg") }
                    QuickAddButton(label: "Video") { addExtension("mp4") }
                    QuickAddButton(label: "Audio") { addExtension("mp3") }
                    QuickAddButton(label: "Docs") { addExtension("pdf") }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    @State private var newExtension: String = ""

    private func addExtension(_ ext: String? = nil) {
        var extToAdd = (ext ?? newExtension).lowercased().trimmingCharacters(in: .whitespaces)
        // Remove leading dot if present
        if extToAdd.hasPrefix(".") {
            extToAdd = String(extToAdd.dropFirst())
        }
        if !extToAdd.isEmpty && !profile.extensions.contains(extToAdd) {
            profile.extensions.append(extToAdd)
        }
        newExtension = ""
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.body)
            TextField("Search...", text: $profile.searchText)
                .textFieldStyle(.plain)
                .font(.body)
                .focused($isSearchFocused)
                .onSubmit { isSearchFocused = false }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("SIZE")

            VStack(spacing: 12) {
                HStack {
                    Text("Min:")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(profile.minSizeMB)) MB")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }

                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .controlSize(.small)

                SectionDivider()

                HStack {
                    Text("Max:")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    if let maxMB = profile.maxSizeMB {
                        Text("\(Int(maxMB)) MB")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    } else {
                        Text("No limit")
                            .font(.subheadline)
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
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("SORT")

            VStack(spacing: 12) {
                HStack {
                    Text("Primary:")
                        .font(.subheadline)
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
                        .font(.subheadline)
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
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("OPTIONS")

            VStack(spacing: 12) {
                HStack {
                    Text("Limit:")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(profile.limit == 0 ? "No limit" : "\(profile.limit)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }

                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .controlSize(.small)

                Toggle("Exclude system dirs", isOn: $profile.excludeSystemDirs)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }

    private var historyButton: some View {
        Button(action: { showingHistory = true }) {
            HStack {
                Image(systemName: "clock")
                    .font(.body)
                    .foregroundColor(.accentColor)
                Text("History")
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .tracking(0.5)
            .padding(.bottom, 4)
    }
}

struct DirectoryPickerButton: View {
    @Binding var directory: String

    var body: some View {
        Button(action: pickDirectory) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.accentColor)
                    .font(.body)
                Text(truncatedPath)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
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

struct SectionDivider: View {
    var body: some View {
        Divider()
            .background(Color.secondary.opacity(0.2))
    }
}

struct ExtensionChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(".\(text)")
                .font(.caption)
                .foregroundColor(.primary)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.15))
        .cornerRadius(6)
    }
}

struct QuickAddButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
