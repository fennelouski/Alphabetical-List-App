//
//  ALUNotePolisher.swift
//  Alphabetical List Utility
//
//  Polishes a note with Apple's on-device foundation model.
//
//  This is the only Swift file in an otherwise Objective-C app. It exists because the
//  FoundationModels framework ships Swift-only — there are no Objective-C headers for it — so
//  this class is the bridge. It exposes a small `@objc` surface with completion handlers, since
//  Swift's async/await isn't directly callable from Objective-C.
//
//  Unlike Writing Tools, which may route requests to Private Cloud Compute, the system language
//  model runs on device. Note text never leaves the phone.
//

import Foundation
import FoundationModels

@objc(ALUNotePolisher)
public final class ALUNotePolisher: NSObject {

    private static let errorDomain = "com.nathanfennel.A2Z.NotePolisher"

    /// Roughly the longest note we'll hand to the model. The on-device context window is small
    /// compared with a server model, and a long note fails late and confusingly; better to skip
    /// straight to the deterministic tidy.
    private static let maximumNoteLength = 4000

    // MARK: - Availability

    /// Whether the on-device model can run right now. False on older hardware, when Apple
    /// Intelligence is switched off, or while the model is still downloading.
    @objc public static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }

        return false
    }

    /// A human-readable reason the model can't run, or nil when it can.
    @objc public static var unavailableReason: String? {
        guard #available(iOS 26.0, *) else {
            return NSLocalizedString("Polishing notes on device requires iOS 26 or later.", comment: "")
        }

        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return NSLocalizedString("This device doesn't support Apple Intelligence.", comment: "")
        case .unavailable(.appleIntelligenceNotEnabled):
            return NSLocalizedString("Turn on Apple Intelligence in Settings to polish notes.", comment: "")
        case .unavailable(.modelNotReady):
            return NSLocalizedString("Apple Intelligence is still getting ready. Try again shortly.", comment: "")
        case .unavailable:
            return NSLocalizedString("Apple Intelligence isn't available right now.", comment: "")
        }
    }

    // MARK: - Polishing

    /// Polish `noteText` and call `completion` on the main queue with either the polished note or
    /// an error. The caller is expected to fall back to something else on failure.
    @objc public static func polishNote(_ noteText: String,
                                        completion: @escaping (String?, NSError?) -> Void) {
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNote.isEmpty else {
            finish(nil, failure("There's nothing in this note to polish."), completion)
            return
        }

        guard trimmedNote.count <= maximumNoteLength else {
            finish(nil, failure("This note is too long to polish on device."), completion)
            return
        }

        guard #available(iOS 26.0, *) else {
            finish(nil, failure(unavailableReason ?? "Apple Intelligence isn't available."), completion)
            return
        }

        polishOnDevice(trimmedNote, completion: completion)
    }

    @available(iOS 26.0, *)
    private static func polishOnDevice(_ noteText: String,
                                       completion: @escaping (String?, NSError?) -> Void) {
        guard SystemLanguageModel.default.isAvailable else {
            finish(nil, failure(unavailableReason ?? "Apple Intelligence isn't available."), completion)
            return
        }

        // Notes here are usually lists, so the instructions lean hard on preserving every item and
        // returning nothing but the note itself — models otherwise like to add a preamble.
        let instructions = """
            You tidy up personal notes and lists.

            Rules:
            - Keep every item and every piece of information. Never add, remove or invent content.
            - Fix spelling, grammar and capitalisation.
            - Keep the note's existing structure: if it is a list, it stays a list with one item \
            per line.
            - Make bullet characters and punctuation consistent.
            - Preserve the author's wording and tone. This is a private note, not prose to rewrite.
            - Reply with the polished note only. No preamble, no explanation, no code fences.
            """

        Task {
            do {
                let session = LanguageModelSession(instructions: instructions)
                let response = try await session.respond(
                    to: noteText,
                    // Low temperature: this is a clean-up task, not a creative one.
                    options: GenerationOptions(temperature: 0.2)
                )

                let polishedNote = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !polishedNote.isEmpty else {
                    finish(nil, failure("The polished note came back empty."), completion)
                    return
                }

                finish(polishedNote, nil, completion)
            } catch {
                finish(nil, error as NSError, completion)
            }
        }
    }

    // MARK: - Helpers

    private static func failure(_ message: String) -> NSError {
        return NSError(domain: errorDomain,
                       code: 1,
                       userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(message, comment: "")])
    }

    /// Always call back on the main queue: the caller updates a text view.
    private static func finish(_ polishedNote: String?,
                               _ error: NSError?,
                               _ completion: @escaping (String?, NSError?) -> Void) {
        DispatchQueue.main.async {
            completion(polishedNote, error)
        }
    }
}
