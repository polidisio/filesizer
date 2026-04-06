import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    var onExportCSV: () -> URL?
    var onExportJSON: () -> URL?

    @State private var exportedURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Results")
                .font(.headline)

            Divider()

            VStack(spacing: 12) {
                Button(action: exportCSV) {
                    HStack {
                        Image(systemName: "tablecells")
                        Text("Export as CSV")
                        Spacer()
                        Image(systemName: "arrow.down.doc")
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: exportJSON) {
                    HStack {
                        Image(systemName: "curlybraces")
                        Text("Export as JSON")
                        Spacer()
                        Image(systemName: "arrow.down.doc")
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            if let url = exportedURL {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Saved to:")
                        .font(.caption)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
        .frame(width: 340)
        .alert("Export", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    private func exportCSV() {
        if let url = onExportCSV() {
            exportedURL = url
            alertMessage = "CSV exported successfully!"
            showingAlert = true
        }
    }

    private func exportJSON() {
        if let url = onExportJSON() {
            exportedURL = url
            alertMessage = "JSON exported successfully!"
            showingAlert = true
        }
    }
}
