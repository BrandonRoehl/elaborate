//
//  CodeViewStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CVCoordinator: NSTextContentStorageDelegate {
    // MARK: - NSTextContentStorageDelegate
    
    public func textContentStorage(
        _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
    ) -> NSTextParagraph? {
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
        
        let newText = NSMutableAttributedString(attributedString: originalText)
        newText.append(NSAttributedString(attachment: attachment))

//        if let textView = yourTextViewReference {
//            textView.layoutManager.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textView.textStorage?.length ?? 0), actualCharacterRange: nil)
//            textView.setNeedsDisplay(textView.bounds)
//        }
        // just invalidate the entire thing should do it better but for now
        self.textLayoutManager.invalidateLayout(for: self.textLayoutManager.documentRange)
        let pg = NSTextParagraph(attributedString: newText)
        return pg
    }

    // MARK: - NSTextContentManagerDelegate
    
//    public func textContentManager(
//        _ textContentManager: NSTextContentManager,
//        textElementAt location: NSTextLocation
//    ) -> NSTextElement? {
//        guard
//            let textContentManager = textContentManager as? NSTextContentStorage,
//            let textStorage = textContentManager.textStorage
//        else {
//            print("TextKit2 this wasn't a text content manager")
//            return nil
//        }
//
//        // This method is called when TextKit 2 needs a text element at a specific location
//        // You can customize and return a different NSTextElement than the default
//
//        // Get the offset from the start of the document to this location
//        let offset = textContentManager.offset(from: textContentManager.documentRange.location, to: location)
//        
//        // For demonstration, we'll log the offset
//        print("TextKit2 is requesting text element at offset: \(offset)")
//
//        
//        guard let line = self.paragraphRanges.firstIndex(where: { range in
//            return range.contains(offset)
//        }) else {
//            print("No line so something is a problem")
//            return nil
//        }
//        let range = self.paragraphRanges[line]
//        
//        guard let range = self.paragraphRanges.first(where: { range in
//            return range.contains(offset)
//        }) else {
//            return nil
//        }
//        
//        let text = textStorage.attributedSubstring(from: range)
//        let pg = NSTextParagraph(attributedString: text)
//        return pg
//        // You can return nil to use the default text element, or create a custom one
//        // For example, you might want to customize how certain paragraphs are displayed:
//        
//        /*
//         // Example of returning a custom text element:
//         let range = NSRange(location: offset, length: 10) // Define appropriate range
//         if let textStorage = (textContentManager as? NSTextContentStorage)?.textStorage,
//         range.location + range.length <= textStorage.length {
//         let customAttributedString = NSMutableAttributedString(attributedString:
//         textStorage.attributedSubstring(from: range))
//         
//         // Apply custom attributes
//         customAttributedString.addAttribute(.foregroundColor, value: NSColor.red,
//         range: NSRange(location: 0, length: customAttributedString.length))
//         
//         // Create and return a custom paragraph
//         return NSTextParagraph(attributedString: customAttributedString)
//         }
//         */
//        
//        // Return nil to use the default text element
//    }
//    
//    public func textContentManager(_ textContentManager: NSTextContentManager,
//                                   shouldEnumerate textElement: NSTextElement,
//                                   options: NSTextContentManager.EnumerationOptions = []) -> Bool {
//        
//        guard let range = textElement.elementRange else {
//            return true
//        }
//
//        guard let textElement = textElement as? NSTextParagraph else {
//            return true
//        }
//        let start = textContentManager.offset(from: textContentManager.documentRange.location, to: range.location)
//        let end = textContentManager.offset(from: textContentManager.documentRange.location, to: range.endLocation)
//        print("TextKit2 is requesting layout for text element at offset: \(start) - \(end)")
//        
//        // Control whether this text element should be included in layout
//        return true
//    }
}
