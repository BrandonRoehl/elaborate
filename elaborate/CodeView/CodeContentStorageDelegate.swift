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
        //        // In this method, we'll inject some attributes for display, without modifying the text storage directly.
        //        var paragraphWithDisplayAttributes: NSTextParagraph? = nil
        //
        //        // First, get a copy of the paragraph from the original text storage.
        let line = self.paragraphRanges.firstIndex(where: { pRange in
            pRange.intersection(range) != nil
        }).map { $0 + 1 }

        print("Called for", range, "in", line ?? "nil")

//        return nil
        guard let line, let result = self.results[line] else {
            // No line or result was found so return this unmodified
            // in the future we still need to do text highlighting
            return nil
        }
        
        let newRange = NSRange(location: range.location, length: range.length)
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: newRange)

        let attachment = CodeAttachment(view: result)
        attachment.coordinator = self
        
        let newText = NSMutableAttributedString()
        newText.beginEditing()
        newText.append(originalText)
        newText.append(NSAttributedString(string: "\n"))
        newText.append(NSAttributedString(attachment: attachment))

        return NSTextParagraph(attributedString: newText)
    }
}
