import Foundation
import CryptoKit

struct NoteAttachment: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let file: String
    let kind: String
    let added: Date
    let bytes: Int64
    var drawingFile: String?
}

struct NoteDetails: Codable {
    var id = UUID()
    var created: Date?
    var edited: Date?
    var firstRecorded = Date()
    var textDigest = ""
    var attachments: [NoteAttachment] = []
    var placeQuery: String?
    var nearbyDisabled = false
    var tags: [String] = []
}

// Additive storage: legacy note bodies, RTFD, icons and preference keys stay intact.
@objc(ALUNoteDetailsStore)
public final class ALUNoteDetailsStore: NSObject {
    @objc public static let shared = ALUNoteDetailsStore()
    private(set) var records: [String: NoteDetails] = [:]
    private(set) var errorMessage: String?
    let root: URL
    private let index: URL
    private var writable = true

    public override convenience init() {
        self.init(root: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AtoZNoteDetails", isDirectory: true))
    }

    init(root: URL) {
        self.root = root
        index = root.appendingPathComponent("index.json")
        super.init()
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: index.path) {
                records = try JSONDecoder().decode([String: NoteDetails].self, from: Data(contentsOf: index))
            }
        } catch {
            writable = false
            errorMessage = "Note details could not be opened. Your existing notes and attachment files have been preserved. " + error.localizedDescription
        }
    }

    @discardableResult
    func ensure(_ title: String, new: Bool = false) -> NoteDetails {
        if let record = records[title] { return record }
        var record = NoteDetails()
        record.created = new ? Date() : nil
        records[title] = record
        persist()
        return record
    }

    @objc(noteCreated:)
    public func noteCreated(_ title: String) { _ = ensure(title, new: true) }

    @objc(noteSaved:text:)
    public func noteSaved(_ title: String, text: String) {
        var record = ensure(title)
        let digest = SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
        guard digest != record.textDigest else { return }
        // An existing note's original timestamps are unknown; first observation is not an edit.
        if !record.textDigest.isEmpty || record.created != nil { record.edited = Date() }
        record.textDigest = digest
        records[title] = record
        persist()
    }

    @objc(renameNote:to:)
    @discardableResult
    public func renameNote(_ title: String, to newTitle: String) -> Bool {
        guard title != newTitle else { return true }
        guard writable, records[newTitle] == nil else { return false }
        let previous = records
        var record = ensure(title)
        record.edited = Date()
        records[newTitle] = record
        records.removeValue(forKey: title)
        guard persist() else { records = previous; return false }
        return true
    }

    @objc(removeNote:)
    public func removeNote(_ title: String) {
        // Keep orphaned files so an interrupted legacy delete cannot destroy attachments.
        records.removeValue(forKey: title)
        persist()
    }

    @objc(identifierForTitle:)
    public func identifier(forTitle title: String) -> String { ensure(title).id.uuidString }

    @objc(summaryForTitle:)
    public func summary(forTitle title: String) -> String {
        let record = ensure(title)
        var parts = [String]()
        if let date = record.edited { parts.append("Edited " + date.formatted(date: .abbreviated, time: .omitted)) }
        if !record.attachments.isEmpty { parts.append("\(record.attachments.count) attachments") }
        return parts.joined(separator: " · ")
    }

    @discardableResult
    func update(_ title: String, _ body: (inout NoteDetails) -> Void) -> Bool {
        let previous = records
        var record = ensure(title)
        body(&record)
        record.edited = Date()
        records[title] = record
        guard persist() else { records = previous; return false }
        NotificationCenter.default.post(name: .init("ALULibraryChanged"), object: nil)
        return true
    }

    func fileURL(_ title: String, _ file: String) -> URL {
        root.appendingPathComponent(ensure(title).id.uuidString, isDirectory: true).appendingPathComponent(file)
    }

    @discardableResult
    func importFile(_ source: URL, title: String, kind: String, name: String? = nil, drawing: Data? = nil, replacing: UUID? = nil) throws -> NoteAttachment {
        guard writable else { throw CocoaError(.fileWriteUnknown) }
        let id = UUID()
        let ext = source.pathExtension.lowercased()
        let file = id.uuidString + (ext.isEmpty ? "" : "." + ext)
        let destination = fileURL(title, file)
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: source, to: destination)
        let bytes = (try destination.resourceValues(forKeys: [.fileSizeKey])).fileSize ?? 0
        guard bytes > 0 else { try? FileManager.default.removeItem(at: destination); throw CocoaError(.fileReadCorruptFile) }
        let drawingFile = drawing == nil ? nil : id.uuidString + ".drawing"
        if let drawing, let drawingFile { try drawing.write(to: fileURL(title, drawingFile), options: .atomic) }
        let attachment = NoteAttachment(id: id, name: name ?? source.lastPathComponent, file: file, kind: kind, added: Date(), bytes: Int64(bytes), drawingFile: drawingFile)
        update(title) {
            if let replacing { $0.attachments.removeAll { $0.id == replacing } }
            $0.attachments.append(attachment)
        }
        if let errorMessage { throw NSError(domain: "AtoZDetails", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]) }
        return attachment
    }

    @discardableResult
    func persist() -> Bool {
        guard writable else { return false }
        do {
            try JSONEncoder().encode(records).write(to: index, options: .atomic)
            errorMessage = nil
            return true
        } catch { errorMessage = "Note details could not be saved. " + error.localizedDescription; return false }
    }
}

struct NotePlaceIntent: Equatable {
    let query: String
    let automatic: Bool

    static func infer(title: String, text: String, details: NoteDetails) -> NotePlaceIntent? {
        guard !details.nearbyDisabled else { return nil }
        if let query = details.placeQuery?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty {
            return NotePlaceIntent(query: query, automatic: false)
        }
        let normalized = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let stores = ["target": "Target", "walmart": "Walmart", "costco": "Costco", "ikea": "IKEA", "aldi": "ALDI", "lidl": "Lidl", "home depot": "The Home Depot", "the home depot": "The Home Depot", "trader joe's": "Trader Joe's", "whole foods": "Whole Foods Market", "walgreens": "Walgreens", "cvs": "CVS", "best buy": "Best Buy", "albert heijn": "Albert Heijn", "jumbo": "Jumbo", "tesco": "Tesco", "sainsbury's": "Sainsbury's"]
        for (name, query) in stores {
            let allowed = [name, name + " shopping", name + " shopping list", name + " list", "shopping at " + name, "shopping - " + name]
            guard allowed.contains(normalized) else { continue }
            let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            let active = lines.filter { !$0.isEmpty && !$0.hasPrefix("[x]") && !$0.hasPrefix("- [x]") && !$0.hasPrefix("✓") && !$0.hasPrefix("☑") }
            let products = Set("milk bread eggs cheese yogurt butter coffee tea rice pasta cereal fruit apple banana vegetables tomato potato onion lettuce chicken fish meat groceries batteries charger toothpaste shampoo soap detergent towels paper toilet socks shoes shirt clothing nappies diapers wipes medicine vitamins paint screws wood furniture lamp desk pillow towels curtains notebook pencils printer headphones television buy purchase pick collect shopping groceries melk brood eieren kaas koffie rijst boodschappen zeep batterijen".split(separator: " ").map(String.init))
            let tokens = active.joined(separator: " ").components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
            let words = Set(tokens + tokens.filter { $0.count > 3 && $0.hasSuffix("s") }.map { String($0.dropLast()) })
            if !active.isEmpty && !products.isDisjoint(with: words) { return NotePlaceIntent(query: query, automatic: true) }
        }
        return nil
    }

    func matchesPlaceName(_ name: String) -> Bool {
        guard automatic else { return true }
        let name = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let query = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return name == query || name == query.replacingOccurrences(of: "the ", with: "") ||
            [" store", " superstore", " supercenter", " grocery", " market", " pharmacy", " express"].contains { name == query + $0 }
    }
}
