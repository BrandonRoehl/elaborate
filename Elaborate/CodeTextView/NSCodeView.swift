//
//  NSCodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(macOS)
import SwiftUI
import AppKit

/// Line number gutter that lives inside the text view and scrolls with it
final class CodeGutterView: NSView {
    weak var coordinator: CVCoordinator?

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func draw(_ dirtyRect: NSRect) {
        // Stay inside the gutter and blend, NSRect.fill() defaults to .copy
        // which replaces what is underneath instead of tinting it
        let area = dirtyRect.intersection(bounds)
        guard !area.isEmpty else { return }
        GutterRenderer.backgroundColor.setFill()
        area.fill(using: .sourceOver)
        guard let coordinator else { return }
        let visible = CGRect(x: 0, y: frame.minY + dirtyRect.minY, width: bounds.width, height: dirtyRect.height)
        GutterRenderer.draw(coordinator.gutterLines(in: visible), originY: frame.minY, width: bounds.width)
    }
}

final class CodeNSTextView: NSTextView, CodeTextSurface {
    let gutter = CodeGutterView()
    private var observedClipView: NSClipView?

    var gutterWidth: CGFloat = 0 {
        didSet {
            guard oldValue != gutterWidth else { return }
            updateContainerSize()
            needsLayout = true
            needsDisplay = true
        }
    }

    var showsGutter = true

    private var gutterInset: CGFloat {
        showsGutter ? gutterWidth + GutterRenderer.textGap : 0
    }

    var footer: ResultHost? {
        didSet {
            guard oldValue !== footer else { return }
            oldValue?.view.removeFromSuperview()
            if let footer {
                addSubview(footer.view)
            }
            needsLayout = true
        }
    }

    var containerOrigin: CGPoint { textContainerOrigin }

    // The container is shifted right to make room for the gutter
    override var textContainerOrigin: NSPoint {
        NSPoint(x: gutterInset, y: 0)
    }

    func refreshGutter() {
        gutter.needsDisplay = true
    }

    private func updateContainerSize() {
        guard let container = textContainer else { return }
        let width = max(bounds.width - gutterInset, 0)
        if container.size.width != width {
            container.size = NSSize(width: width, height: .greatestFiniteMagnitude)
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateContainerSize()
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if gutter.superview == nil && showsGutter {
            gutter.wantsLayer = true
            gutter.layer?.masksToBounds = true
            addSubview(gutter)
        }
        if let clip = enclosingScrollView?.contentView, clip !== observedClipView {
            if let observedClipView {
                NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: observedClipView)
            }
            observedClipView = clip
            clip.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self, selector: #selector(scrolled), name: NSView.boundsDidChangeNotification, object: clip)
        }
    }

    @objc private func scrolled(_ notification: Notification) {
        layoutGutter()
    }

    private func layoutGutter() {
        guard showsGutter else { return }
        let visible = visibleRect
        let frame = CGRect(x: 0, y: visible.minY, width: gutterWidth, height: visible.height)
        if gutter.frame != frame {
            gutter.frame = frame
        }
        gutter.needsDisplay = true
    }

    override func layout() {
        super.layout()
        // The footer takes the room under the text, the inset is applied to
        // both ends of the view so it is split in half
        if let footer, let layout = textLayoutManager {
            let width = textContainer?.size.width ?? 0
            let height = footer.size(fitting: width).height
            let inset = NSSize(width: 0, height: height / 2)
            if textContainerInset != inset {
                textContainerInset = inset
            }
            let used = layout.usageBoundsForTextContainer
            footer.view.frame = CGRect(x: gutterInset, y: used.maxY, width: width, height: height)
        } else if textContainerInset != .zero {
            textContainerInset = .zero
        }
        layoutGutter()
    }
}

extension CodeTextView: NSViewRepresentable {
    public typealias Coordinator = CVCoordinator

    @MainActor public func makeNSView(context: Context) -> NSScrollView {
        let textView = CodeNSTextView(usingTextLayoutManager: true)
        textView.gutter.coordinator = context.coordinator
        textView.showsGutter = lineNumbers
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.textContainerInset = .zero
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = OSMonoFont
        // This is code, don't be clever with the input
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.delegate = context.coordinator

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.documentView = textView

        context.coordinator.attach(textView)
        context.coordinator.update(self)
        context.coordinator.linesDidChange()
        return scrollView
    }

    @MainActor public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.update(self)
    }
}

extension CVCoordinator: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        self.textDidChangeByUser()
    }
}
#endif
