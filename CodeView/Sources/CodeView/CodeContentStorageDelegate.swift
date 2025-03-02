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
        //        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        print("textcontentstorage", textContentStorage, range)

        return nil
        //        if originalText.attribute(.commentDepth, at: 0, effectiveRange: nil) != nil {
        //            // Use white colored text to make our comments visible against the bright background.
        //            let displayAttributes: [NSAttributedString.Key: AnyObject] = [.font: commentFont, .foregroundColor: commentColor]
        //            let textWithDisplayAttributes = NSMutableAttributedString(attributedString: originalText)
        //            // Use the display attributes for the text of the comment itself, without the reaction.
        //            // The last character is the newline, second to last is the attachment character for the reaction.
        //            let rangeForDisplayAttributes = NSRange(location: 0, length: textWithDisplayAttributes.length - 2)
        //            textWithDisplayAttributes.addAttributes(displayAttributes, range: rangeForDisplayAttributes)
        //
        //            // Create our new paragraph with our display attributes.
        //            paragraphWithDisplayAttributes = NSTextParagraph(attributedString: textWithDisplayAttributes)
        //        } else {
        //            return nil
        //        }
        //        // If the original paragraph wasn't a comment, this return value will be nil.
        //        // The text content storage will use the original paragraph in this case.
        //        return paragraphWithDisplayAttributes
    }
}
