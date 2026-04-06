import SwiftUI

struct FileDetailView: View {
    let file: ScannedFile
    @State private var comment: String = ""
    @State private var isEditingComment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text(file.name)
                        .font(.headline)
                    Text(file.extension_.uppercased())
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "Size", value: file.sizeDescription)
                DetailRow(label: "Modified", value: file.modifiedDescription)
                DetailRow(label: "Path", value: file.path)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Finder Comment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(isEditingComment ? "Save" : "Edit") {
                        if isEditingComment {
                            saveComment()
                        } else {
                            loadComment()
                            isEditingComment = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isEditingComment && comment == file.finderComment)
                }

                if isEditingComment {
                    TextEditor(text: $comment)
                        .frame(height: 80)
                        .font(.caption)
                        .border(Color.secondary.opacity(0.3))
                } else {
                    Text(comment.isEmpty ? "No comment" : comment)
                        .font(.caption)
                        .foregroundColor(comment.isEmpty ? .secondary : .primary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                }
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 280)
    }

    private func loadComment() {
        comment = FinderComments.readComment(for: URL(fileURLWithPath: file.path)) ?? ""
    }

    private func saveComment() {
        do {
            if comment.isEmpty {
                try FinderComments.deleteComment(from: URL(fileURLWithPath: file.path))
            } else {
                try FinderComments.writeComment(comment, to: URL(fileURLWithPath: file.path))
            }
            isEditingComment = false
        } catch {
            print("Failed to save comment: \(error)")
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}
