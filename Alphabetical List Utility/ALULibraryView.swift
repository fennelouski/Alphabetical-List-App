import SwiftUI

@objc(ALULibraryBuilder)
public final class ALULibraryBuilder: NSObject {
    @objc(makeControllerWithNotes:create:delete:editor:save:cards:)
    public static func makeController(notes: @escaping () -> [[String: Any]], create: @escaping (String) -> Bool, delete: @escaping (String) -> Void, editor: @escaping (String) -> UIViewController, save: @escaping (UIViewController) -> Void, cards: @escaping () -> UIViewController) -> UIViewController {
        UIHostingController(rootView: NotesLibraryView(load: notes, create: create, delete: delete, editor: editor, save: save, cards: cards))
    }
}

private struct LibraryNote: Identifiable {
    let title: String
    let text: String
    let id: String
    let summary: String
    let styledTitle: AttributedString
    let color: Color
    let icon: UIImage?
    let styleColor: Color?
    let styleIntensity: Double
}
private struct NoteDestination: Identifiable {
    let id: String
    let controller: UIViewController
}

private struct NotesLibraryView: View {
    let load: () -> [[String: Any]]
    let create: (String) -> Bool
    let delete: (String) -> Void
    let editor: (String) -> UIViewController
    let save: (UIViewController) -> Void
    let cards: () -> UIViewController
    @State private var notes: [LibraryNote] = []
    @State private var query = ""
    @State private var newTitle = ""
    @State private var adding = false
    @State private var deletion: LibraryNote?
    @State private var destination: NoteDestination?
    @State private var duplicate = false

    private var filtered: [LibraryNote] {
        notes.filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.text.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("A little order for your thoughts.").font(.title2.bold())
                        Text("\(notes.count) notes, always in alphabetical order.").foregroundStyle(.secondary)
                    }.padding(.vertical, 10)
                }
                Section("Your notes") {
                    if filtered.isEmpty {
                        Text(query.isEmpty ? "Create a note to get started." : "No notes match your search.").foregroundStyle(.secondary)
                    }
                    ForEach(filtered) { note in
                        Button { destination = NoteDestination(id: note.id, controller: editor(note.title)) } label: {
                            HStack(alignment: .top, spacing: 14) {
                                Group {
                                    if let icon = note.icon { Image(uiImage: icon).resizable().scaledToFit() }
                                    else { Text(String(note.title.prefix(1)).uppercased()).font(.title2.bold()).foregroundStyle(note.color) }
                                }.frame(width: 44, height: 50)
                                    .background(note.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.styledTitle).font(.headline)
                                    Text(note.text.isEmpty ? "Empty note" : note.text).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
                                    if !note.summary.isEmpty { Text(note.summary).font(.caption).foregroundStyle(.secondary) }
                                }
                                Spacer(minLength: 0)
                            }.padding(.vertical, 5)
                        }.buttonStyle(.plain)
                        .listRowBackground(note.styleColor.map { $0.opacity(note.styleIntensity * 0.25) } ?? Color(uiColor: .secondarySystemGroupedBackground))
                        .contextMenu {
                            ShareLink(item: note.title + "\n\n" + note.text)
                            Button("Delete", role: .destructive) { deletion = note }
                        }
                        .swipeActions { Button("Delete", role: .destructive) { deletion = note } }
                    }
                }
            }
            .navigationTitle("A to Z Notes")
            .searchable(text: $query, prompt: "Search titles and notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Card library", systemImage: "rectangle.stack") { destination = NoteDestination(id: "card-library", controller: cards()) }
                        Button("Nearby reminders", systemImage: "location") { destination = NoteDestination(id: "nearby", controller: ALUNoteAttachmentsBuilder.makeNearbyController()) }
                    } label: { Label("Library options", systemImage: "line.3.horizontal.circle") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New note", systemImage: "square.and.pencil") { newTitle = ""; adding = true }.keyboardShortcut("n")
                }
            }
            .alert("New note", isPresented: $adding) {
                TextField("Title", text: $newTitle)
                Button("Create") {
                    let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    if create(title) { reload(); destination = NoteDestination(id: title, controller: editor(title)) }
                    else { duplicate = true }
                }.disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Cancel", role: .cancel) {}
            }
            .alert("A note with that title already exists", isPresented: $duplicate) { Button("OK", role: .cancel) {} }
            .confirmationDialog("Delete this note?", isPresented: Binding(get: { deletion != nil }, set: { if !$0 { deletion = nil } }), titleVisibility: .visible) {
                Button("Delete note", role: .destructive) { if let deletion { delete(deletion.title); reload() }; deletion = nil }
            }
            .sheet(item: $destination, onDismiss: reload) { target in
                VStack(spacing: 0) {
                    if target.id != "nearby" {
                        HStack { Spacer(); Button("Done") { save(target.controller); destination = nil }.font(.headline).padding() }
                    }
                    NoteEditorBridge(controller: target.controller, save: save).ignoresSafeArea(edges: .bottom)
                }
            }
            .onAppear(perform: reload)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ALULibraryChanged"))) { _ in reload() }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ALUNoteIconDidLoadNotification"))) { _ in reload() }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ALUOpenNote"))) { notification in
                reload()
                if let note = notes.first(where: { $0.id == notification.userInfo?["id"] as? String || $0.title == notification.userInfo?["title"] as? String }) {
                    if let destination { save(destination.controller) }
                    destination = NoteDestination(id: note.id, controller: editor(note.title))
                }
            }
        }.tint(.indigo)
    }
    private func reload() {
        notes = load().compactMap { item in
            guard let title = item["title"] as? String else { return nil }
            return LibraryNote(title: title, text: item["text"] as? String ?? "", id: item["id"] as? String ?? title,
                summary: item["summary"] as? String ?? "",
                styledTitle: (item["styledTitle"] as? NSAttributedString).map { original in
                    var styled = AttributedString()
                    original.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: original.length)) { value, range, _ in
                        var run = AttributedString(original.attributedSubstring(from: range).string)
                        run.foregroundColor = Color(uiColor: value as? UIColor ?? .label)
                        styled += run
                    }
                    return styled
                } ?? AttributedString(title), color: Color(uiColor: item["color"] as? UIColor ?? .label),
                icon: item["icon"] as? UIImage, styleColor: (item["styleColor"] as? UIColor).map { Color(uiColor: $0) },
                styleIntensity: item["styleIntensity"] as? Double ?? 0)
        }
    }
}

private struct NoteEditorBridge: UIViewControllerRepresentable {
    let controller: UIViewController
    let save: (UIViewController) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(save: save) }
    func makeUIViewController(context: Context) -> UIViewController { controller }
    func updateUIViewController(_ controller: UIViewController, context: Context) {}
    static func dismantleUIViewController(_ controller: UIViewController, coordinator: Coordinator) { coordinator.save(controller) }
    final class Coordinator {
        let save: (UIViewController) -> Void
        init(save: @escaping (UIViewController) -> Void) { self.save = save }
    }
}
