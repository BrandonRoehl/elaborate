//
//  CodeAttachment.swift
//  CodeView
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

/// Stands in for a newline and displays a result view inline in the text
final class CodeAttachment: NSTextAttachment {
    let host: ResultHost

    init(host: ResultHost) {
        self.host = host
        super.init(data: nil, ofType: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("CodeAttachment is never decoded")
    }

    override func viewProvider(
        for parentView: OSView?,
        location: any NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        let provider = CodeAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        return provider
    }
}

final class CodeAttachmentViewProvider: NSTextAttachmentViewProvider {
    override func loadView() {
        guard let attachment = self.textAttachment as? CodeAttachment else { return }
        let host = attachment.host
        self.view = MainActor.assumeIsolated { host.view }
    }

    override func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any],
        location: any NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        guard let attachment = self.textAttachment as? CodeAttachment else { return .zero }
        // Fit the container horizontally and the contents vertically
        let width = proposedLineFragment.width
        let host = attachment.host
        let size = MainActor.assumeIsolated { host.size(fitting: width) }
        return CGRect(origin: .zero, size: size)
    }
}
