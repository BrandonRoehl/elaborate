//
//  CodeViewStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CodeViewCoordinator: NSTextContentStorageDelegate {
    public func textContentStorage(
        _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
    ) -> NSTextParagraph? {
        return nil
        //        // In this method, we'll inject some attributes for display, without modifying the text storage directly.
        //        var paragraphWithDisplayAttributes: NSTextParagraph? = nil
        //
        //        // First, get a copy of the paragraph from the original text storage.
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)

        let line = self.paragraphRanges.firstIndex(where: { pRange in
            pRange.intersection(range) != nil
        }).map { $0 + 1 }

        print("Called for", range, "in", line ?? "nil", originalText.string)

//        return nil
        guard let line, let result = self.results[line] else {
            // No line or result was found so return this unmodified
            // in the future we still need to do text highlighting
            return nil
        }
        
        let attachment = CodeAttachment(view: result)
//        attachment.coordinator = self
//        let attributedString = AttributedString("\(UnicodeScalar(NSTextAttachment.character)!)", attributes: AttributeContainer.attachment(attachment))
        
        let newText = NSMutableAttributedString(attributedString: originalText)
        newText.append(NSAttributedString(attachment: attachment))
//        let newText = NSMutableAttributedString(attachment: attachment)
//        newText.append(NSAttributedString(string: "\n"))
//        newText.insert(originalText, at: 0)
//        newText.append(originalText)
//        newText.append(NSAttributedString(attachment: attachment))
//        newText.endEditing()

        let pg = NSTextParagraph(attributedString: newText)
        return pg
    }
}
