import SwiftUI

@objc(ALULibraryBuilder)
public final class ALULibraryBuilder: NSObject {
    @objc(makeControllerWithNotes:create:delete:editor:save:cards:)
    public static func makeController(notes: @escaping () -> [[String: String]], create: @escaping (String) -> Bool, delete: @escaping (String) -> Void, editor: @escaping (String) -> UIViewController, save: @escaping (UIViewController) -> Void, cards: @escaping () -> UIViewController) -> UIViewController {
        UIHostingController(rootView: NotesLibraryView(load: notes, create: create, delete: delete, editor: editor, save: save, cards: cards))
    }
}

private struct LibraryNote: Identifiable {
    let title: String
    let text: String
    var id: String { title }
}
private struct NoteDestination: Identifiable {
    let id: String
    let controller: UIViewController
}

private struct NotesLibraryView: View {
    let load: () -> [[String: String]]
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
                                Text(String(note.title.prefix(1)).uppercased()).font(.title2.bold())
                                    .frame(width: 44, height: 50).foregroundStyle(.indigo)
                                    .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.title).font(.headline).foregroundStyle(.primary)
                                    Text(note.text.isEmpty ? "Empty note" : note.text).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
                                }
                                Spacer(minLength: 0)
                            }.padding(.vertical, 5)
                        }.buttonStyle(.plain)
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
                    Button("Card library", systemImage: "rectangle.stack") { destination = NoteDestination(id: "card-library", controller: cards()) }
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
                    HStack { Spacer(); Button("Done") { save(target.controller); destination = nil }.font(.headline).padding() }
                    NoteEditorBridge(controller: target.controller, save: save).ignoresSafeArea(edges: .bottom)
                }
            }
            .onAppear(perform: reload)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ALULibraryChanged"))) { _ in reload() }
        }.tint(.indigo)
    }
    private func reload() { notes = load().compactMap { item in item["title"].map { LibraryNote(title: $0, text: item["text"] ?? "") } } }
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
