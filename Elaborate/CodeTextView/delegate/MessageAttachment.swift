//
//  MessageAttachment.swift
//  Elaborate
//
//  A TextKit 2 attachment that embeds a result view at a linebreak.
//

import SwiftUI
import Elb

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// The attachment that backs an embedded message view.
///
/// The width is the full container width and the height is inferred from the
/// hosted content.
final class MessageAttachment: NSTextAttachment {
    static let fileType = "elaborate.message"
    
    let line: Int
    let results: [Response]
    var size: CGSize = .zero
    
    init(line: Int, results: [Response], size: CGSize) {
        self.line = line
        self.results = results
        self.size = size
        super.init(data: Data(), ofType: Self.fileType)
        self.bounds = CGRect(origin: .zero, size: size)
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// TextKit 2 size negotiation. Recomputes the height if the container
    /// width changed since the attachment was created (e.g. window resize).
    override func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any]?,
        location: NSTextLocation?,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        let width = textContainer?.size.width ?? proposedLineFragment.width
        if self.size.width != width && width > 0 {
            let height = Self.measuredHeight(line: self.line, results: self.results, width: width)
            self.size = CGSize(width: width, height: height)
            self.bounds = CGRect(origin: .zero, size: self.size)
        }
        return self.bounds
    }
    
    // MARK: - Measurement
    
    private struct CacheEntry {
        let width: CGFloat
        let height: CGFloat
        let results: [Response]
    }
    
    nonisolated(unsafe) private static var heightCache: [Int: CacheEntry] = [:]
    
    /// The ideal height of the message view at the given width, cached per
    /// line.
    static func measuredHeight(line: Int, results: [Response], width: CGFloat) -> CGFloat {
        if let entry = heightCache[line], entry.width == width, entry.results == results {
            return entry.height
        }
        let view = ResultGroup(results: results)
        #if os(macOS)
        let controller = NSHostingController(rootView: view)
        let height = controller.sizeThatFits(in: CGSize(width: width, height: 0)).height
        #else
        let controller = UIHostingController(rootView: view)
        let fitting = controller.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let height = fitting.height
        #endif
        heightCache[line] = CacheEntry(width: width, height: height, results: results)
        return height
    }
}

/// Creates and owns the view that represents a message attachment in the
/// text.
#if os(macOS)
final class MessageViewProvider: NSTextAttachmentViewProvider {
    private var message: MessageAttachment? {
        self.textAttachment as? MessageAttachment
    }
    
    override init(
        textAttachment: NSTextAttachment,
        parentView: NSView?,
        textLayoutManager: NSTextLayoutManager?,
        location: NSTextLocation
    ) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        // Let the framework query the attachment for its bounds.
        self.tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        guard let message = self.message else {
            return
        }
        let hosting = NSHostingView(rootView: ResultGroup(results: message.results))
        hosting.frame = CGRect(origin: .zero, size: message.size)
        self.view = hosting
    }
}
#else
final class MessageViewProvider: NSTextAttachmentViewProvider {
    private var message: MessageAttachment? {
        self.textAttachment as? MessageAttachment
    }
    
    override init(
        textAttachment: NSTextAttachment,
        parentView: UIView?,
        textLayoutManager: NSTextLayoutManager?,
        location: NSTextLocation
    ) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        // Let the framework query the attachment for its bounds.
        self.tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        guard let message = self.message else {
            return
        }
        let hosting = UIHostingController(rootView: ResultGroup(results: message.results))
        hosting.view.frame = CGRect(origin: .zero, size: message.size)
        self.view = hosting.view
    }
}
#endif
