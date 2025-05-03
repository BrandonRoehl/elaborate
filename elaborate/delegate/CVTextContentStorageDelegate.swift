//
//  CodeViewStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CVCoordinator: NSTextContentStorageDelegate {
    // MARK: - NSTextContentStorageDelegate
    
//        //        // In this method, we'll inject some attributes for display, without modifying the text storage directly.
//        //        var paragraphWithDisplayAttributes: NSTextParagraph? = nil
//        //
//        //        // First, get a copy of the paragraph from the original text storage.
//        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
//
//        let line = self.paragraphRanges.firstIndex(where: { pRange in
//            pRange.intersection(range) != nil
//        }).map { $0 + 1 }
//
//        print("Called for", range, "in", line ?? "nil", originalText.string.debugDescription)
//
//        guard let line, let result = self.results[line] else {
//            // No line or result was found so return this unmodified
//            // in the future we still need to do text highlighting
//            return nil
//        }
//        
//        let attachment = CodeAttachment(view: result)
//        
//        let newText = NSMutableAttributedString(attributedString: originalText)
//        newText.deleteCharacters(in: NSRange(location: originalText.length - 1, length: 1))
////        newText.append(NSAttributedString(string: "-"))
//        newText.append(NSAttributedString(attachment: attachment))
////        newText.append(NSAttributedString(string: "\n"))
//
////        if let textView = yourTextViewReference {
////            textView.layoutManager.invalidateLayout(forCharacterRange: NSRange(location: 0, length: textView.textStorage?.length ?? 0), actualCharacterRange: nil)
////            textView.setNeedsDisplay(textView.bounds)
////        }
//        // just invalidate the entire thing should do it better but for now
//        self.textLayoutManager.invalidateLayout(for: self.textLayoutManager.documentRange)
//        let pg = NSTextParagraph(attributedString: newText)
//        return pg
//    }

    // MARK: - NSTextContentManagerDelegate
    
    public func textContentManager(
        _ textContentManager: NSTextContentManager,
        textElementAt location: NSTextLocation
    ) -> NSTextElement? {
        guard
            let textContentManager = textContentManager as? NSTextContentStorage,
            let textStorage = textContentManager.textStorage
        else {
            print("TextKit2 this wasn't a text content manager")
            return nil
        }

        // This method is called when TextKit 2 needs a text element at a specific location
        // You can customize and return a different NSTextElement than the default

        // Get the offset from the start of the document to this location
        let begining = textContentManager.documentRange.location
        let offset = textContentManager.offset(from: textContentManager.documentRange.location, to: location)
        
        // For demonstration, we'll log the offset
        print("TextKit2 is requesting text element at offset: \(offset)")
        
        // location is the start of this
        let index = self.newlineOffsets.firstIndex(where: { $0 >= offset })
        
        if let index, self.newlineOffsets[index] == offset {
            // we are explicityly on an \n this is a special case
            print("<\\n new line detected>")
            let attString = NSAttributedString(string: "\n")
            let pg = NSTextParagraph(attributedString: attString)
            pg.elementRange = NSTextRange(location: location, end: location)
            return pg
        }
        
        // For everything else
        
        // if nil we are after the end
        // index is the next paragraph paragraph marker
        let range: NSRange
        // we are not at the end
        if let index {
            let startOffset: Int
            let endOffset: Int = self.newlineOffsets[index]
            if index > 0 {
                startOffset = self.newlineOffsets[index - 1] + 1
            } else {
                startOffset = 0
            }
//            assert(startOffset == offset)
            range = NSRange(location: startOffset, length: endOffset - startOffset)
        } else if let last = self.newlineOffsets.last {
            // our offset is within the last element of the string
            range = NSRange((last + 1)..<textStorage.length)
        } else {
            // return the entire thing
            range = NSRange(location: 0, length: textStorage.length)
        }
        
        let attString = textStorage.attributedSubstring(from: range)
        print(attString.string.debugDescription)
        print("returning charecters", offset, "to", offset + range.length)
        let pg = NSTextParagraph(attributedString: attString)
        let start = textContentManager.location(begining, offsetBy: range.lowerBound)!
        let end = textContentManager.location(begining, offsetBy: range.upperBound)
        pg.elementRange = NSTextRange(location: start, end: end)
        return pg
    }

//    public func textContentManager(_ textContentManager: NSTextContentManager,
//                                   shouldEnumerate textElement: NSTextElement,
//                                   options: NSTextContentManager.EnumerationOptions = []) -> Bool {
////        guard let range = textElement.elementRange else {
////            return true
////        }
////
////        guard let textElement = textElement as? NSTextParagraph else {
////            return true
////        }
////        let start = textContentManager.offset(from: textContentManager.documentRange.location, to: range.location)
////        let end = textContentManager.offset(from: textContentManager.documentRange.location, to: range.endLocation)
////        print("TextKit2 is requesting layout for text element at offset: \(start) - \(end)")
//        
//        // Control whether this text element should be included in layout
//        return true
//    }
}
