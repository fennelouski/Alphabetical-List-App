import SwiftUI
import PhotosUI
import PencilKit
import QuickLook
import AVFoundation
import UniformTypeIdentifiers
import ImageIO

@objc(ALUNoteAttachmentsBuilder)
public final class ALUNoteAttachmentsBuilder: NSObject {
    @objc(makeControllerForTitle:text:)
    public static func makeController(title: String, text: String) -> UIViewController {
        UIHostingController(rootView: NoteDetailsView(title: title, text: text))
    }
    @objc public static func makeNearbyController() -> UIViewController {
        UIHostingController(rootView: NearbyRemindersView())
    }
}

struct NearbyRemindersView: View {
    @ObservedObject private var reminders = ALUPlaceReminders.shared
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Nearby note reminders", isOn: Binding(get: { reminders.enabled }, set: reminders.setEnabled))
                    Text(reminders.status).foregroundStyle(.secondary)
                } footer: {
                    Text("A shopping note named Target, Costco or another recognized store can remind you when you arrive. Other places can be chosen in Note Details. Allow notifications and Always location access for reminders while AtoZ is closed.")
                }
                Section("Privacy") {
                    Text("Matching happens on your device. Apple Maps receives the place query and search area, never the note body. Location reminders depend on system permissions, connectivity, Background App Refresh and iOS delivery timing.")
                    Button("Open system settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                    }
                }
                if !reminders.places.isEmpty {
                    Section("Monitored nearby places") {
                        ForEach(Array(Set(reminders.places)).sorted(), id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("Nearby Reminders")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

private enum AttachmentSheet: Identifiable {
    case photos, camera, drawing(NoteAttachment?), audio, preview(NoteAttachment)
    var id: String {
        switch self {
        case .photos: return "photos"
        case .camera: return "camera"
        case .drawing(let item): return "drawing" + (item?.id.uuidString ?? "new")
        case .audio: return "audio"
        case .preview(let item): return item.id.uuidString
        }
    }
}

private struct NoteDetailsView: View {
    let title: String
    let text: String
    @Environment(\.dismiss) private var dismiss
    @State private var record: NoteDetails
    @State private var sheet: AttachmentSheet?
    @State private var importing = false
    @State private var errorMessage: String?
    @State private var deleting: NoteAttachment?
    @State private var tags = ""
    @State private var place = ""
    private let store = ALUNoteDetailsStore.shared

    init(title: String, text: String) {
        self.title = title; self.text = text
        _record = State(initialValue: ALUNoteDetailsStore.shared.ensure(title))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Note metadata") {
                    if let date = record.created { LabeledContent("Created", value: date.formatted()) }
                    else { LabeledContent("Created", value: "Unknown for this existing note") }
                    if let date = record.edited { LabeledContent("Edited", value: date.formatted()) }
                    LabeledContent("Words", value: String(text.split(whereSeparator: { $0.isWhitespace }).count))
                    LabeledContent("Characters", value: String(text.count))
                    TextField("Tags, separated by commas", text: $tags)
                    Button("Save tags") {
                        store.update(title) { $0.tags = Array(Set(tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })).sorted() }
                        reload()
                    }
                }
                Section {
                    Toggle("Suggest this note nearby", isOn: Binding(get: { !record.nearbyDisabled }, set: { value in
                        store.update(title) { $0.nearbyDisabled = !value }; reload()
                    }))
                    if let inferred = NotePlaceIntent.infer(title: title, text: text, details: record) {
                        LabeledContent("Matching place", value: inferred.query)
                    }
                    TextField("Optional store or place name", text: $place)
                    Button("Save place") {
                        let query = place.trimmingCharacters(in: .whitespacesAndNewlines)
                        store.update(title) { $0.placeQuery = query.isEmpty ? nil : query }; reload()
                    }
                    NavigationLink("Nearby reminder permissions") { NearbyRemindersView() }
                } header: { Text("Nearby recommendations") }
                  footer: { Text("Automatic matching uses recognized store titles and unfinished shopping content. A chosen place overrides matching. Notifications require Nearby Reminders to be enabled.") }
                Section("Attachments") {
                    if record.attachments.isEmpty { Text("Add a drawing, photo, recording, video or file.").foregroundStyle(.secondary) }
                    ForEach(record.attachments) { item in
                        Button { sheet = item.kind == "drawing" ? .drawing(item) : .preview(item) } label: {
                            HStack(spacing: 12) {
                                if let image = thumbnail(item) { Image(uiImage: image).resizable().scaledToFit().frame(width: 48, height: 48) }
                                else { Image(systemName: symbol(item.kind)).font(.title2).frame(width: 48) }
                                VStack(alignment: .leading) {
                                    Text(item.name).foregroundStyle(.primary)
                                    Text(ByteCountFormatter.string(fromByteCount: item.bytes, countStyle: .file)).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .contextMenu {
                            ShareLink(item: store.fileURL(title, item.file))
                            Button("Remove attachment", role: .destructive) { deleting = item }
                        }
                    }
                    Button("Photos and videos", systemImage: "photo.on.rectangle") { sheet = .photos }
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Take a photo or video", systemImage: "camera") { sheet = .camera }
                    }
                    Button("Draw", systemImage: "pencil.tip.crop.circle") { sheet = .drawing(nil) }
                    Button("Record audio", systemImage: "mic") { sheet = .audio }
                    Button("Attach a file", systemImage: "paperclip") { importing = true }
                }
            }
            .navigationTitle("Note Details")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .onAppear { tags = record.tags.joined(separator: ", "); place = record.placeQuery ?? ""; reload() }
            .sheet(item: $sheet, onDismiss: reload) { destination in
                switch destination {
                case .photos: NotePhotoPicker(title: title, report: report)
                case .camera: NoteCameraPicker(title: title, report: report)
                case .drawing(let item): NoteDrawingEditor(title: title, attachment: item, report: report)
                case .audio: NoteAudioRecorder(title: title, report: report)
                case .preview(let item):
                    NavigationStack {
                        AttachmentPreview(url: store.fileURL(title, item.file))
                            .navigationTitle(item.name).navigationBarTitleDisplayMode(.inline)
                            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { sheet = nil } } }
                    }
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
                do {
                    for url in try result.get() {
                        let access = url.startAccessingSecurityScopedResource()
                        defer { if access { url.stopAccessingSecurityScopedResource() } }
                        let type = (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType
                        let kind = type?.conforms(to: .audio) == true ? "audio" : type?.conforms(to: .movie) == true ? "video" : type?.conforms(to: .image) == true ? "photo" : "file"
                        try store.importFile(url, title: title, kind: kind)
                    }
                    reload()
                } catch { errorMessage = error.localizedDescription }
            }
            .alert("Attachment could not be saved", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
            .confirmationDialog("Remove this attachment from the note?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
                Button("Remove attachment", role: .destructive) {
                    if let deleting { store.update(title) { $0.attachments.removeAll { $0.id == deleting.id } } }
                    deleting = nil; reload()
                }
            }
        }
    }
    private func reload() { record = store.ensure(title); if let error = store.errorMessage { errorMessage = error } }
    private func report(_ error: String?) { if let error { errorMessage = error }; sheet = nil; reload() }
    private func symbol(_ kind: String) -> String { ["audio": "waveform", "video": "film", "drawing": "pencil.tip", "photo": "photo"][kind] ?? "doc" }
    private func thumbnail(_ item: NoteAttachment) -> UIImage? {
        guard item.kind == "photo" || item.kind == "drawing",
              let source = CGImageSourceCreateWithURL(store.fileURL(title, item.file) as CFURL, nil),
              let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: 120, kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }
}

private struct AttachmentPreview: UIViewControllerRepresentable {
    let url: URL
    func makeCoordinator() -> Coordinator { Coordinator(url) }
    func makeUIViewController(context: Context) -> QLPreviewController {
        let view = QLPreviewController(); view.dataSource = context.coordinator; return view
    }
    func updateUIViewController(_ view: QLPreviewController, context: Context) {}
    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(_ url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { url as NSURL }
    }
}

private struct NotePhotoPicker: UIViewControllerRepresentable {
    let title: String
    let report: (String?) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(title, report) }
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(); config.filter = .any(of: [.images, .videos]); config.selectionLimit = 10
        let picker = PHPickerViewController(configuration: config); picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let title: String
        let report: (String?) -> Void
        init(_ title: String, _ report: @escaping (String?) -> Void) { self.title = title; self.report = report }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let group = DispatchGroup(); var errors: [String] = []; let lock = NSLock()
            for result in results {
                let video = result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
                group.enter()
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: video ? UTType.movie.identifier : UTType.image.identifier) { url, error in
                    do {
                        guard let url else { throw error ?? CocoaError(.fileReadUnknown) }
                        // Copy before the provider deletes its temporary URL; mutate the index on main.
                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(url.pathExtension)
                        try FileManager.default.copyItem(at: url, to: temp)
                        DispatchQueue.main.async {
                            do { try ALUNoteDetailsStore.shared.importFile(temp, title: self.title, kind: video ? "video" : "photo", name: result.itemProvider.suggestedName ?? (video ? "Video" : "Photo")) }
                            catch { lock.lock(); errors.append(error.localizedDescription); lock.unlock() }
                            try? FileManager.default.removeItem(at: temp); group.leave()
                        }
                    } catch { lock.lock(); errors.append(error.localizedDescription); lock.unlock(); group.leave() }
                }
            }
            group.notify(queue: .main) { self.report(errors.isEmpty ? nil : errors.joined(separator: "\n")) }
        }
    }
}

private struct NoteCameraPicker: UIViewControllerRepresentable {
    let title: String
    let report: (String?) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(title, report) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController(); picker.sourceType = .camera
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? [UTType.image.identifier]
        picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let title: String; let report: (String?) -> Void
        init(_ title: String, _ report: @escaping (String?) -> Void) { self.title = title; self.report = report }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { report(nil) }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            do {
                if let url = info[.mediaURL] as? URL { try ALUNoteDetailsStore.shared.importFile(url, title: title, kind: "video", name: "Camera video") }
                else if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.9) {
                    let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                    try data.write(to: temp, options: .atomic)
                    defer { try? FileManager.default.removeItem(at: temp) }
                    try ALUNoteDetailsStore.shared.importFile(temp, title: title, kind: "photo", name: "Camera photo")
                } else { throw CocoaError(.fileReadCorruptFile) }
                report(nil)
            } catch { report(error.localizedDescription) }
        }
    }
}

private struct NoteDrawingEditor: UIViewControllerRepresentable {
    let title: String
    let attachment: NoteAttachment?
    let report: (String?) -> Void
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: DrawingController(title: title, attachment: attachment, report: report))
    }
    func updateUIViewController(_ controller: UINavigationController, context: Context) {}
}

private final class DrawingController: UIViewController {
    let canvas = PKCanvasView()
    let tools = PKToolPicker()
    let noteTitle: String
    let attachment: NoteAttachment?
    let report: (String?) -> Void
    init(title: String, attachment: NoteAttachment?, report: @escaping (String?) -> Void) {
        noteTitle = title; self.attachment = attachment; self.report = report; super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad(); title = "Drawing"; view.backgroundColor = .systemBackground
        canvas.drawingPolicy = .anyInput; canvas.backgroundColor = .systemBackground
        canvas.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(canvas)
        NSLayoutConstraint.activate([canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor), canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor), canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), canvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        if let file = attachment?.drawingFile, let data = try? Data(contentsOf: ALUNoteDetailsStore.shared.fileURL(noteTitle, file)), let drawing = try? PKDrawing(data: data) { canvas.drawing = drawing }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated); tools.addObserver(canvas); tools.setVisible(true, forFirstResponder: canvas); canvas.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); tools.setVisible(false, forFirstResponder: canvas); tools.removeObserver(canvas) }
    @objc func cancel() { report(nil) }
    @objc func save() {
        guard !canvas.drawing.strokes.isEmpty else { report("Draw something before saving."); return }
        do {
            let store = ALUNoteDetailsStore.shared
            let image = canvas.drawing.image(from: canvas.drawing.bounds.insetBy(dx: -12, dy: -12), scale: 2)
            guard let data = image.pngData() else { throw CocoaError(.fileWriteUnknown) }
            let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
            try data.write(to: temp, options: .atomic); defer { try? FileManager.default.removeItem(at: temp) }
            try store.importFile(temp, title: noteTitle, kind: "drawing", name: "Drawing",
                                 drawing: canvas.drawing.dataRepresentation(), replacing: attachment?.id)
            if let error = store.errorMessage { report(error) } else { report(nil) }
        } catch { report(error.localizedDescription) }
    }
}

private final class AudioRecording: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var recording = false
    @Published var url: URL?
    @Published var error: String?
    private var recorder: AVAudioRecorder?
    func start() {
        let begin: (Bool) -> Void = { allowed in
            DispatchQueue.main.async {
                guard allowed else { self.error = "Allow microphone access in Settings to record audio."; return }
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
                    self.recorder = try AVAudioRecorder(url: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue])
                    self.recorder?.delegate = self
                    guard self.recorder?.record() == true else { throw CocoaError(.fileWriteUnknown) }
                    self.url = url; self.recording = true
                } catch { self.error = error.localizedDescription; self.stop() }
            }
        }
        if #available(iOS 17, *) { AVAudioApplication.requestRecordPermission(completionHandler: begin) }
        else { AVAudioSession.sharedInstance().requestRecordPermission(begin) }
    }
    func stop() { recorder?.stop(); recording = false; try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) { self.error = error?.localizedDescription ?? "Audio recording failed."; stop() }
}

private struct NoteAudioRecorder: View {
    let title: String
    let report: (String?) -> Void
    @StateObject private var audio = AudioRecording()
    @Environment(\.scenePhase) private var phase
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: audio.recording ? "waveform" : "mic.circle").font(.system(size: 64)).accessibilityHidden(true)
                Text(audio.recording ? "Recording…" : audio.url == nil ? "Record a voice note" : "Recording ready").font(.title2)
                if let error = audio.error { Text(error).foregroundStyle(.red) }
                Button(audio.recording ? "Stop recording" : "Start recording") { audio.recording ? audio.stop() : audio.start() }
                    .buttonStyle(.borderedProminent).disabled(audio.url != nil && !audio.recording)
            }.padding()
            .navigationTitle("Audio")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { audio.stop(); report(nil) } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") {
                    audio.stop()
                    do {
                        guard let url = audio.url else { return }
                        try ALUNoteDetailsStore.shared.importFile(url, title: title, kind: "audio", name: "Voice recording")
                        try? FileManager.default.removeItem(at: url); report(nil)
                    } catch { audio.error = error.localizedDescription }
                }.disabled(audio.url == nil || audio.recording || audio.error != nil) }
            }
            .onChange(of: phase) { newPhase in if newPhase != .active { audio.stop() } }
            .onDisappear { audio.stop(); if let url = audio.url { try? FileManager.default.removeItem(at: url) } }
        }
    }
}
