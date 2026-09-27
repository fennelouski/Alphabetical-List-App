//
//  ALUImageGenerator.swift
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/26.
//  Copyright © 2026 HAI. All rights reserved.
//

import UIKit

#if canImport(ImagePlayground)
import ImagePlayground
#endif

/// Generates a note icon with Apple's on-device Image Playground model. Swift-only
/// framework, so this wrapper is `@objc` with a completion handler, mirroring
/// ALUNotePolisher. Completion fires on the main queue with nil whenever the device
/// can't generate (no Apple Intelligence, old OS, unsupported hardware).
@objc(ALUImageGenerator)
public final class ALUImageGenerator: NSObject {

	/// Whether image generation could work at all on this OS/build. It can still fail at
	/// runtime (no Apple Intelligence, unsupported hardware); that surfaces as a nil result.
	@objc public static var isSupported: Bool {
		#if canImport(ImagePlayground)
		if #available(iOS 18.4, *) { return true }
		#endif
		return false
	}

	@objc public static func generateIcon(forNoteTitle title: String, completion: @escaping (UIImage?) -> Void) {
		#if canImport(ImagePlayground)
		guard #available(iOS 18.4, *) else {
			completion(nil)
			return
		}

		Task {
			var icon: UIImage?
			do {
				let creator = try await ImageCreator()
				if let style = creator.availableStyles.first {
					let concepts: [ImagePlaygroundConcept] = [
						.text("A simple, friendly, flat icon representing \"\(title)\""),
					]
					for try await created in creator.images(for: concepts, style: style, limit: 1) {
						icon = ALUImageGenerator.iconSized(UIImage(cgImage: created.cgImage))
						break
					}
				}
			} catch {
				icon = nil
			}

			let result = icon
			await MainActor.run { completion(result) }
		}
		#else
		completion(nil)
		#endif
	}

	/// The model returns large images; the card corner shows 40pt. Store a small tile.
	private static func iconSized(_ image: UIImage) -> UIImage {
		let side: CGFloat = 256
		return UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { _ in
			image.draw(in: CGRect(x: 0, y: 0, width: side, height: side))
		}
	}
}
