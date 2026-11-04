//
//  CVTextContentStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

func colorAttr(_ named: String) -> [NSAttributedString.Key: Any] {
	return [
		.font: OSMonoFont,
		.foregroundColor: OSColor(named: named) ?? OSColor.textFallbackColor
	]
}

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
		
		paragraph.setAttributes(colorAttr("TextColor"), range: NSRange(location: 0, length: range.length))

		let rawString = paragraph.string

		// MARK: Highlight numbers
		for (regex, color) in [
			(/\d+/, colorAttr("NumberColor")),
			// Color comments last
			(/#.*/, colorAttr("CommentColor"))
		] {
			for match in rawString.matches(of: regex) {
				paragraph.setAttributes(color, range: NSRange(match.range, in: rawString))
			}
		}

		// MARK: Insert the attachment

        let last = range.length - 1
        guard (rawString as NSString).character(at: last) == 0x0A else {
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
