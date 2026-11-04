//
//  CVTextContentStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CVCoordinator: @MainActor NSTextContentStorageDelegate {
    /// Swap the newline that ends a line for an attachment holding its results.
    /// The attachment is the same length as the newline so every offset in the
    /// text storage still lines up with the paragraph TextKit lays out.
    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard
            let storage = textContentStorage.textStorage,
            range.length > 0
        else {
            return nil
        }

		let paragraph = NSMutableAttributedString(attributedString: storage.attributedSubstring(from: range))
        let attr: [NSAttributedString.Key: Any]
#if os(macOS)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: NSColor.labelColor
        ]
#else
        attr = [
            .font: OSMonoFont,
            .foregroundColor: UIColor.label
        ]
#endif
		paragraph.setAttributes(attr, range: NSRange(location: 0, length: range.length))

        let last = range.length - 1
        guard (paragraph.string as NSString).character(at: last) == 0x0A else {
			return NSTextParagraph(attributedString: paragraph)
        }

        // The paragraph starts on the line its newline ends
        let line = self.lineIndex.lineNumber(at: range.location)
        guard let host = self.hosts[line] else {
			return NSTextParagraph(attributedString: paragraph)
        }

        let attributes = paragraph.attributes(at: last, effectiveRange: nil)
        let attachment = NSAttributedString(attachment: CodeAttachment(host: host), attributes: attributes)
        paragraph.replaceCharacters(in: NSRange(location: last, length: 1), with: attachment)
        return NSTextParagraph(attributedString: paragraph)
    }
}
