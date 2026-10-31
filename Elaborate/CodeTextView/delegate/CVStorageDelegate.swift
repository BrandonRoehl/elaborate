//
//  CVStorageDelegate.swift
//  Elaborate
//
//  Created by Brandon Roehl on 6/6/25.
//

import SwiftUI
import Elb

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension CVCoordinator {
    // MARK: - NSTextContentStorageDelegate

    public func textContentStorage(
        _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
    ) -> NSTextParagraph? {
        guard let textStorage = textContentStorage.textStorage else {
            print("TextKit2 this wasn't a text content manager")
            return nil
        }
        // Get the places to replace with a view
        let originalText = textStorage.attributedSubstring(from: range)
#if DEBUG
        print(originalText.string.debugDescription)
#endif
        let attrString = NSMutableAttributedString(attributedString: originalText)
        let attr: [NSAttributedString.Key: Any]
#if os(macOS)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: NSColor.labelColor,
        ]
#elseif os(iOS) || targetEnvironment(macCatalyst)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: UIColor.label,
        ]
#endif
        attrString.setAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        
        // Embed a message view at every attachment character (U+FFFC) in the
        // paragraph. The view is full container width and as tall as its
        // content.
        let string = attrString.string
        var searchStart = string.startIndex
        while let found = string[searchStart...].range(of: "\u{FFFC}") {
            let offset = string.utf16.distance(from: string.startIndex, to: found.lowerBound)
            // `offset` is relative to the paragraph; convert it to a buffer
            // offset so the source line can be looked up correctly.
            if let attachment = self.attachment(for: range.location + offset, in: textContentStorage) {
                attrString.addAttribute(.attachment, value: attachment, range: NSRange(location: offset, length: 1))
            }
            searchStart = found.upperBound
        }
        
        return NSTextParagraph(attributedString: attrString)
    }
    
    // MARK: - Attachments
    
    /// Builds the message attachment for the line that owns the attachment
    /// character at `offset`.
    func attachment(for offset: Int, in textContentStorage: NSTextContentStorage) -> MessageAttachment? {
        // `offset` is a buffer offset; the attachment sits at the linebreak of
        // its source line.
        let line = self.lineNumber(at: offset)
        guard let message = self.messages[line] else {
            return nil
        }
        let width = max(self.textContainer.size.width, 1)
        let height = MessageAttachment.measuredHeight(line: line, results: message.results, width: width)
        return MessageAttachment(line: line, results: message.results, size: CGSize(width: width, height: height))
    }
}
