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
            !self.results.isEmpty,
            let storage = textContentStorage.textStorage,
            range.length > 0
        else {
            return nil
        }
        let original = storage.attributedSubstring(from: range)
        let last = range.length - 1
        guard (original.string as NSString).character(at: last) == 0x0A else {
            return nil
        }

        // The paragraph starts on the line its newline ends
        let line = self.lineIndex.lineNumber(at: range.location)
        guard let host = self.hosts[line] else {
            return nil
        }

        let attributes = original.attributes(at: last, effectiveRange: nil)
        let attachment = NSAttributedString(attachment: CodeAttachment(host: host), attributes: attributes)
        let paragraph = NSMutableAttributedString(attributedString: original)
        paragraph.replaceCharacters(in: NSRange(location: last, length: 1), with: attachment)
        return NSTextParagraph(attributedString: paragraph)
    }
}
