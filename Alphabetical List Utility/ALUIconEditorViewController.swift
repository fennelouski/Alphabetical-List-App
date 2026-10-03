//
//  ALUIconEditorViewController.swift
//  Alphabetical List Utility
//
//  Created by HAI on 7/23/26.
//  Copyright © 2026 HAI. All rights reserved.
//

import UIKit
import PhotosUI
import PencilKit

/// The dedicated note-icon editor, opened by tapping a card's corner icon. It rebuilds
/// the old two-screen "Note Icon" suite (photo / camera / text-emoji / draw) as one
/// modern screen: a live preview tile in the note's brand colour, a row of sources
/// (now including on-device AI generation), and a strip of Core Image effects.
///
/// Self-contained on purpose — there is no Swift bridging header, so it never touches
/// the Objective-C data layer. It takes the current icon in and hands the edited image
/// back through `onSave`, exactly like ALUImageGenerator / ALUNotePolisher; the caller
/// persists it via ALUDataManager.
@objc(ALUIconEditorViewController)
public final class ALUIconEditorViewController: UIViewController {

    /// Called with the finished icon when the user taps Save (never on Cancel).
    @objc public var onSave: ((UIImage?) -> Void)?

    private let noteTitle: String
    private let tint: UIColor

    /// The chosen source image with no effect applied. Effects are layered on top for
    /// display and only baked in at save time, so switching effects is non-destructive.
    private var baseImage: UIImage?
    private var effect: IconEffect = .none

    private let ciContext = CIContext(options: nil)

    // AI generations the user can page through. `genIndex` is the one on screen, or -1
    // when the current preview came from another source (text, draw, photo…).
    private var generations: [UIImage] = []
    private var genIndex = -1
    private var isGenerating = false
    private var didPrecompute = false
    /// Set once the user taps Generate — until then a precomputed result stays off-screen
    /// instead of hijacking the icon they opened the editor with.
    private var wantsGenerations = false
    private var shownUnavailableAlert = false

    // UI
    private let previewTile = UIView()
    private let frameView = UIView()   // fixed clip window; the image is zoomed/rotated inside it
    private let previewImageView = UIImageView()
    private let placeholderView = UIImageView()
    private let textField = UITextField()
    private let effectsStack = UIStackView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let pageControl = UIPageControl()
    private weak var generateButton: UIButton?
    private let generateButtonSpinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Init

    @objc public init(noteTitle: String, tintColor: UIColor, image: UIImage?) {
        self.noteTitle = noteTitle
        self.tint = tintColor
        self.baseImage = image
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.tintColor = tint

        title = noteTitle.isEmpty ? "Note Icon" : noteTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.style = .done

        buildLayout()
        refreshPreview()
        rebuildEffectStrip()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Precompute one generation in the background so the first Generate tap is instant.
        guard !didPrecompute, ALUImageGenerator.isSupported else { return }
        didPrecompute = true
        startGeneration()
    }

    // MARK: - Layout

    private func buildLayout() {
        // Preview tile — a rounded card in the note's brand colour, matching the list.
        previewTile.backgroundColor = tint
        previewTile.layer.cornerRadius = 28
        previewTile.layer.cornerCurve = .continuous
        previewTile.layer.shadowColor = UIColor.black.cgColor
        previewTile.layer.shadowOpacity = 0.18
        previewTile.layer.shadowRadius = 16
        previewTile.layer.shadowOffset = CGSize(width: 0, height: 8)
        previewTile.translatesAutoresizingMaskIntoConstraints = false

        // A fixed window that clips whatever the image is zoomed/rotated to. The clip must
        // live on a view that does NOT get transformed, or the crop would scale with it.
        frameView.clipsToBounds = true
        frameView.backgroundColor = .clear
        frameView.layer.cornerRadius = 14
        frameView.layer.cornerCurve = .continuous
        frameView.translatesAutoresizingMaskIntoConstraints = false
        previewTile.addSubview(frameView)

        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        frameView.addSubview(previewImageView)

        placeholderView.image = UIImage(systemName: "photo")
        placeholderView.tintColor = tint.oppositeBlackOrWhiteText.withAlphaComponent(0.6)
        placeholderView.contentMode = .scaleAspectFit
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        previewTile.addSubview(placeholderView)

        // Effects strip — horizontally scrolling thumbnails of the current image.
        effectsStack.axis = .horizontal
        effectsStack.spacing = 14
        effectsStack.alignment = .top
        let effectsScroll = UIScrollView()
        effectsScroll.showsHorizontalScrollIndicator = false
        effectsScroll.translatesAutoresizingMaskIntoConstraints = false
        effectsStack.translatesAutoresizingMaskIntoConstraints = false
        effectsScroll.addSubview(effectsStack)

        // Source row — where a new icon comes from.
        let sourceRow = UIStackView(arrangedSubviews: sourceButtons())
        sourceRow.axis = .horizontal
        sourceRow.distribution = .fillEqually
        sourceRow.alignment = .top
        sourceRow.spacing = 8
        sourceRow.translatesAutoresizingMaskIntoConstraints = false

        // Inline text field, revealed only in text mode.
        textField.placeholder = "Type text or emoji"
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.delegate = self
        textField.isHidden = true
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false

        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false

        // Dots that appear once there is more than one generation to swipe between.
        pageControl.hidesForSinglePage = false
        pageControl.currentPageIndicatorTintColor = tint.contrastingAccent
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.isUserInteractionEnabled = false
        pageControl.isHidden = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(previewTile)
        view.addSubview(pageControl)
        view.addSubview(effectsScroll)
        view.addSubview(textField)
        view.addSubview(sourceRow)
        previewTile.addSubview(spinner)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            previewTile.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            previewTile.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            previewTile.widthAnchor.constraint(equalToConstant: 200),
            previewTile.heightAnchor.constraint(equalToConstant: 200),

            frameView.topAnchor.constraint(equalTo: previewTile.topAnchor, constant: 24),
            frameView.leadingAnchor.constraint(equalTo: previewTile.leadingAnchor, constant: 24),
            frameView.trailingAnchor.constraint(equalTo: previewTile.trailingAnchor, constant: -24),
            frameView.bottomAnchor.constraint(equalTo: previewTile.bottomAnchor, constant: -24),

            previewImageView.topAnchor.constraint(equalTo: frameView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: frameView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: previewTile.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: previewTile.centerYAnchor),
            placeholderView.widthAnchor.constraint(equalToConstant: 64),
            placeholderView.heightAnchor.constraint(equalToConstant: 64),

            spinner.centerXAnchor.constraint(equalTo: previewTile.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: previewTile.centerYAnchor),

            textField.topAnchor.constraint(equalTo: previewTile.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 32),
            textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -32),

            effectsScroll.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            effectsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            effectsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            effectsScroll.heightAnchor.constraint(equalToConstant: 96),

            effectsStack.topAnchor.constraint(equalTo: effectsScroll.topAnchor),
            effectsStack.bottomAnchor.constraint(equalTo: effectsScroll.bottomAnchor),
            effectsStack.leadingAnchor.constraint(equalTo: effectsScroll.leadingAnchor, constant: 20),
            effectsStack.trailingAnchor.constraint(equalTo: effectsScroll.trailingAnchor, constant: -20),
            effectsStack.heightAnchor.constraint(equalTo: effectsScroll.heightAnchor),

            sourceRow.topAnchor.constraint(equalTo: effectsScroll.bottomAnchor, constant: 12),
            sourceRow.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 12),
            sourceRow.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -12),

            pageControl.topAnchor.constraint(equalTo: previewTile.bottomAnchor, constant: 2),
            pageControl.centerXAnchor.constraint(equalTo: previewTile.centerXAnchor),
        ])

        // Pinch + rotate transform the image inside the frame; a one-finger swipe pages
        // through generations. Different finger counts, so the gestures never fight.
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        rotate.delegate = self
        previewTile.addGestureRecognizer(pinch)
        previewTile.addGestureRecognizer(rotate)

        let swipeNext = UISwipeGestureRecognizer(target: self, action: #selector(swipedToNext))
        swipeNext.direction = .left
        let swipePrevious = UISwipeGestureRecognizer(target: self, action: #selector(swipedToPrevious))
        swipePrevious.direction = .right
        previewTile.addGestureRecognizer(swipeNext)
        previewTile.addGestureRecognizer(swipePrevious)
        previewTile.isUserInteractionEnabled = true
    }

    private func sourceButtons() -> [UIView] {
        var buttons = [sourceButton("Text", "textformat", #selector(textSourceTapped))]
        buttons.append(sourceButton("Draw", "scribble.variable", #selector(drawTapped)))
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            buttons.append(sourceButton("Photo", "photo.on.rectangle", #selector(photoTapped)))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            buttons.append(sourceButton("Camera", "camera", #selector(cameraTapped)))
        }
        if ALUImageGenerator.isSupported {
            buttons.append(sourceButton("Generate", "wand.and.sparkles", #selector(generateTapped)))
        }
        return buttons
    }

    /// A stacked icon-in-a-circle over a caption, the modern replacement for the old
    /// toolbar buttons.
    private func sourceButton(_ title: String, _ symbol: String, _ action: Selector) -> UIView {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        button.tintColor = tint.contrastingAccent
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 52),
            button.heightAnchor.constraint(equalToConstant: 52),
        ])

        // The Generate button doubles as its own progress indicator while a generation runs.
        if action == #selector(generateTapped) {
            generateButton = button
            generateButtonSpinner.hidesWhenStopped = true
            generateButtonSpinner.color = tint.contrastingAccent
            generateButtonSpinner.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(generateButtonSpinner)
            NSLayoutConstraint.activate([
                generateButtonSpinner.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                generateButtonSpinner.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            ])
        }

        let caption = UILabel()
        caption.text = title
        caption.font = .systemFont(ofSize: 12, weight: .medium)
        caption.textColor = .secondaryLabel
        caption.textAlignment = .center

        let column = UIStackView(arrangedSubviews: [button, caption])
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 6
        return column
    }

    // MARK: - Preview

    private var displayImage: UIImage? {
        guard let baseImage = baseImage else { return nil }
        return effect.apply(to: baseImage, context: ciContext)
    }

    private func refreshPreview() {
        let image = displayImage
        previewImageView.image = image
        previewImageView.isHidden = (image == nil)
        placeholderView.isHidden = (image != nil)
        navigationItem.rightBarButtonItem?.isEnabled = (image != nil)
    }

    private func setBaseImage(_ image: UIImage?, generationIndex: Int = -1) {
        baseImage = image
        genIndex = generationIndex
        previewImageView.transform = .identity   // a fresh image starts unzoomed / unrotated
        refreshPreview()
        rebuildEffectStrip()
        updatePageControl()
    }

    // MARK: - Effects strip

    private func rebuildEffectStrip() {
        effectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let base = baseImage else { return }
        let thumbnail = base.iconThumbnail(side: 132)  // 2x the 66pt chip

        for candidate in IconEffect.allCases {
            let chip = EffectChip(title: candidate.title,
                                  image: candidate.apply(to: thumbnail, context: ciContext),
                                  selected: candidate == effect,
                                  accent: tint.contrastingAccent)
            chip.tag = candidate.rawValue
            chip.addTarget(self, action: #selector(effectChipTapped(_:)), for: .touchUpInside)
            effectsStack.addArrangedSubview(chip)
        }
    }

    @objc private func effectChipTapped(_ sender: UIControl) {
        guard let picked = IconEffect(rawValue: sender.tag) else { return }
        effect = picked
        refreshPreview()
        for case let chip as EffectChip in effectsStack.arrangedSubviews {
            chip.setSelected(chip.tag == sender.tag)
        }
    }

    // MARK: - Sources

    @objc private func textSourceTapped() {
        textField.isHidden = false
        textField.becomeFirstResponder()
    }

    @objc private func textChanged() {
        setBaseImage(ALUIconEditorViewController.renderIcon(text: textField.text ?? "",
                                                          color: tint.oppositeBlackOrWhiteText,
                                                          background: tint))
    }

    @objc private func drawTapped() {
        let draw = IconDrawViewController(tint: tint)
        draw.onDone = { [weak self] image in
            if let image = image { self?.setBaseImage(image) }
        }
        present(UINavigationController(rootViewController: draw), animated: true)
    }

    @objc private func photoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func cameraTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Generation

    @objc private func generateTapped() {
        guard ALUImageGenerator.isSupported else { showUnavailable(); return }
        wantsGenerations = true

        // Show a precomputed generation the user hasn't seen yet — instant, no waiting.
        if genIndex + 1 < generations.count {
            setBaseImage(generations[genIndex + 1], generationIndex: genIndex + 1)
            return
        }
        // Otherwise cook a fresh one — but never two at once (guarded in startGeneration).
        startGeneration()
    }

    private func startGeneration() {
        guard !isGenerating else { return }
        isGenerating = true
        updateGeneratingUI()
        ALUImageGenerator.generateIcon(forNoteTitle: noteTitle) { [weak self] image in
            self?.handleGenerated(image)
        }
    }

    private func handleGenerated(_ image: UIImage?) {
        isGenerating = false
        updateGeneratingUI()

        guard let image = image else {
            if wantsGenerations { showUnavailable() }
            return
        }

        generations.append(image)
        // Only jump to it if the user asked for a generation; a silent precompute waits.
        if wantsGenerations {
            setBaseImage(image, generationIndex: generations.count - 1)
        }
    }

    private func updateGeneratingUI() {
        generateButton?.isEnabled = !isGenerating
        if isGenerating { generateButtonSpinner.startAnimating() } else { generateButtonSpinner.stopAnimating() }
        // The big in-frame spinner only shows while the user waits for the first result.
        if isGenerating && wantsGenerations && genIndex < 0 { spinner.startAnimating() } else { spinner.stopAnimating() }
    }

    private func showUnavailable() {
        guard !shownUnavailableAlert else { return }
        shownUnavailableAlert = true
        let alert = UIAlertController(title: "Not Available",
                                      message: "On-device image generation needs Apple Intelligence and a supported device.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Paging through generations

    @objc private func swipedToNext() { showGeneration(at: genIndex + 1) }
    @objc private func swipedToPrevious() { showGeneration(at: genIndex - 1) }

    private func showGeneration(at index: Int) {
        guard index >= 0, index < generations.count else { return }
        wantsGenerations = true
        setBaseImage(generations[index], generationIndex: index)
    }

    private func updatePageControl() {
        pageControl.numberOfPages = generations.count
        pageControl.currentPage = max(0, genIndex)
        pageControl.isHidden = !(genIndex >= 0 && generations.count > 1)
    }

    // MARK: - Pinch / rotate to place the image in the frame

    @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        guard baseImage != nil, recognizer.state == .changed else { return }
        // Clamp the cumulative scale so the image can't shrink to nothing or blow up.
        let t = previewImageView.transform
        let current = (t.a * t.a + t.c * t.c).squareRoot()
        let factor = min(max(recognizer.scale, 0.25 / current), 6.0 / current)
        previewImageView.transform = previewImageView.transform.scaledBy(x: factor, y: factor)
        recognizer.scale = 1
    }

    @objc private func handleRotate(_ recognizer: UIRotationGestureRecognizer) {
        guard baseImage != nil, recognizer.state == .changed else { return }
        previewImageView.transform = previewImageView.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
    }

    // MARK: - Save / Cancel

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let result = finalIcon()
        dismiss(animated: true) { [weak self] in
            self?.onSave?(result)
        }
    }

    /// The display image with the user's pinch / rotate baked into a square icon. If they
    /// never transformed it, the untouched image is returned so nothing else changes.
    private func finalIcon() -> UIImage? {
        guard let image = displayImage else { return nil }
        let transform = previewImageView.transform
        if transform.isIdentity { return image }

        let side: CGFloat = 256
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { context in
            let cg = context.cgContext
            // Reproduce the preview: transform about the frame centre, then draw aspect-fit.
            cg.translateBy(x: side / 2, y: side / 2)
            cg.concatenate(transform)
            cg.translateBy(x: -side / 2, y: -side / 2)
            let scale = min(side / image.size.width, side / image.size.height)
            let drawn = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            image.draw(in: CGRect(x: (side - drawn.width) / 2,
                                  y: (side - drawn.height) / 2,
                                  width: drawn.width,
                                  height: drawn.height))
        }
    }

    // MARK: - Text rendering

    /// Draws text or emoji centred in a square, coloured tile — the modern take on
    /// the old emoji screen's label-to-image trick.
    static func renderIcon(text: String, color: UIColor, background: UIColor) -> UIImage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let side: CGFloat = 256
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side)).image { _ in
            background.withAlphaComponent(1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: side, height: side))
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            var fontSize = side
            var attributes: [NSAttributedString.Key: Any] = [:]
            var textSize = CGSize.zero
            repeat {
                fontSize -= 8
                attributes = [.font: UIFont.boldSystemFont(ofSize: fontSize),
                              .foregroundColor: color,
                              .paragraphStyle: paragraph]
                textSize = (trimmed as NSString).size(withAttributes: attributes)
            } while (textSize.width > side * 0.9 || textSize.height > side * 0.9) && fontSize > 12

            let rect = CGRect(x: 0, y: (side - textSize.height) / 2, width: side, height: textSize.height)
            (trimmed as NSString).draw(in: rect, withAttributes: attributes)
        }
    }
}

// MARK: - Picker delegates

extension ALUIconEditorViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { self?.setBaseImage(image) }
        }
    }
}

extension ALUIconEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        if let image = image { setBaseImage(image) }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ALUIconEditorViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ALUIconEditorViewController: UIGestureRecognizerDelegate {
    // Let pinch and rotate run together so the image can be zoomed and turned at once.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Effects

/// A small, curated set of Core Image effects. `.none` is index 0 so the raw image is
/// always the first, selected-by-default chip.
private enum IconEffect: Int, CaseIterable {
    case none, mono, noir, sepia, vivid, invert, comic

    var title: String {
        switch self {
        case .none:   return "Original"
        case .mono:   return "Mono"
        case .noir:   return "Noir"
        case .sepia:  return "Sepia"
        case .vivid:  return "Vivid"
        case .invert: return "Invert"
        case .comic:  return "Comic"
        }
    }

    private var filter: CIFilter? {
        switch self {
        case .none:   return nil
        case .mono:   return CIFilter(name: "CIPhotoEffectMono")
        case .noir:   return CIFilter(name: "CIPhotoEffectNoir")
        case .sepia:  return CIFilter(name: "CISepiaTone", parameters: [kCIInputIntensityKey: 0.9])
        case .vivid:  return CIFilter(name: "CIVibrance", parameters: ["inputAmount": 1.0])
        case .invert: return CIFilter(name: "CIColorInvert")
        case .comic:  return CIFilter(name: "CIComicEffect")
        }
    }

    func apply(to image: UIImage, context: CIContext) -> UIImage {
        guard let filter = filter, let input = CIImage(image: image) else { return image }
        filter.setValue(input, forKey: kCIInputImageKey)
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: input.extent) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

/// One tappable effect thumbnail with a caption; rings itself in the accent when selected.
private final class EffectChip: UIControl {
    private let imageView = UIImageView()
    private let accent: UIColor

    init(title: String, image: UIImage, selected: Bool, accent: UIColor) {
        self.accent = accent
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.layer.cornerCurve = .continuous
        imageView.layer.borderColor = accent.cgColor
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        let caption = UILabel()
        caption.text = title
        caption.font = .systemFont(ofSize: 11, weight: .medium)
        caption.textColor = .secondaryLabel
        caption.textAlignment = .center
        caption.translatesAutoresizingMaskIntoConstraints = false
        addSubview(caption)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 66),
            imageView.heightAnchor.constraint(equalToConstant: 66),
            widthAnchor.constraint(equalToConstant: 66),
            caption.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            caption.leadingAnchor.constraint(equalTo: leadingAnchor),
            caption.trailingAnchor.constraint(equalTo: trailingAnchor),
            caption.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        setSelected(selected)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ selected: Bool) {
        imageView.layer.borderWidth = selected ? 3 : 0
    }
}

// MARK: - Drawing

/// A PencilKit canvas standing in for the old hand-rolled LinearInterpView drawing
/// screen: a real tool picker (pen, marker, eraser, colours, undo) for free.
private final class IconDrawViewController: UIViewController {

    var onDone: ((UIImage?) -> Void)?

    private let canvas = PKCanvasView()
    private let toolPicker = PKToolPicker()
    private let tint: UIColor

    init(tint: UIColor) {
        self.tint = tint
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.tintColor = tint
        title = "Draw Icon"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput  // finger works even without a Pencil
        canvas.layer.borderColor = UIColor.separator.cgColor
        canvas.layer.borderWidth = 1
        canvas.layer.cornerRadius = 16
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)

        // Square canvas, centred — icons are square.
        let side = canvas.widthAnchor.constraint(equalTo: canvas.heightAnchor)
        NSLayoutConstraint.activate([
            canvas.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            canvas.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            canvas.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            canvas.widthAnchor.constraint(lessThanOrEqualToConstant: 420),
            canvas.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32).withPriority(.defaultHigh),
            side,
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        // Nothing drawn → return nil so an accidental Done never wipes the icon with a
        // blank image.
        let image = canvas.drawing.strokes.isEmpty ? nil : canvas.drawing.image(from: canvas.bounds, scale: UIScreen.main.scale)
        dismiss(animated: true) { [weak self] in
            self?.onDone?(image)
        }
    }
}

// MARK: - Helpers

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

private extension UIColor {
    /// Choose the higher-contrast foreground using the colour's relative luminance.
    var oppositeBlackOrWhiteText: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return .label }
        func linear(_ component: CGFloat) -> CGFloat {
            component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        let luminance = 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
        return luminance > 0.179 ? .black : .white
    }

    /// The brand colour if it has enough contrast on a system background, otherwise the
    /// adaptive label colour — keeps accents legible in light and dark mode.
    var contrastingAccent: UIColor {
        var white: CGFloat = 0, alpha: CGFloat = 0
        guard getWhite(&white, alpha: &alpha) else { return self }
        return (white > 0.75) ? .label : self
    }
}

private extension UIImage {
    /// A small, square, aspect-filled copy for effect thumbnails — cheap to run filters on.
    func iconThumbnail(side: CGFloat) -> UIImage {
        let target = CGSize(width: side, height: side)
        return UIGraphicsImageRenderer(size: target).image { _ in
            let scale = max(side / size.width, side / size.height)
            let scaled = CGSize(width: size.width * scale, height: size.height * scale)
            draw(in: CGRect(x: (side - scaled.width) / 2,
                            y: (side - scaled.height) / 2,
                            width: scaled.width,
                            height: scaled.height))
        }
    }
}
