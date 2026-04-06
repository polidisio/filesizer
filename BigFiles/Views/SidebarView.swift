import SwiftUI

struct SidebarView: View {
    @Binding var profile: ScanProfile
    @Binding var showingHistory: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Directory")
                    .font(.headline)
                Spacer()
            }

            DirectoryPickerButton(directory: $profile.directory)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Min Size: \(Int(profile.minSizeMB)) MB")
                    .font(.subheadline)
                Slider(value: $profile.minSizeMB, in: 1...1000, step: 1)
                    .labelsHidden()

                if let maxMB = profile.maxSizeMB {
                    HStack {
                        Text("Max: \(Int(maxMB)) MB")
                            .font(.caption)
                        Slider(value: Binding(
                            get: { maxMB },
                            set: { profile.maxSizeMB = $0 }
                        ), in: 1...10000, step: 1)
                        .labelsHidden()
                        Button("Clear") {
                            profile.maxSizeMB = nil
                        }
                        .font(.caption)
                    }
                } else {
                    Button("Set Max Size") {
                        profile.maxSizeMB = 500
                    }
                    .font(.caption)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Sort By")
                    .font(.subheadline)
                Picker("Sort", selection: $profile.sortBy) {
                    ForEach(ScanProfile.SortField.allCases, id: \.self) { field in
                        Text(field.rawValue).tag(field)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Limit: \(profile.limit == 0 ? "None" : "\(profile.limit)")")
                    .font(.subheadline)
                Slider(value: Binding(
                    get: { Double(profile.limit) },
                    set: { profile.limit = Int($0) }
                ), in: 0...500, step: 10)
                .labelsHidden()
            }

            Divider()

            Toggle("Exclude System Dirs", isOn: $profile.excludeSystemDirs)
                .font(.subheadline)

            Spacer()

            Divider()

            Button(action: { showingHistory = true }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Scan History")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(minWidth: 220)
    }
}

struct DirectoryPickerButton: View {
    @Binding var directory: String

    var body: some View {
        Button(action: pickDirectory) {
            HStack {
                Image(systemName: "folder")
                Text(truncatedPath)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var truncatedPath: String {
        if directory.count > 30 {
            return "..." + String(directory.suffix(27))
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
