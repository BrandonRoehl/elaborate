//
//  CodeViewStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CVCoordinator: NSTextContentStorageDelegate {
    // MARK: - NSTextContentStorageDelegate
    
    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard let textStorage = textContentStorage.textStorage else {
            print("TextKit2 this wasn't a text content manager")
            return nil
        }
        // Get the places to replace with a view
        let originalText = textStorage.attributedSubstring(from: range)

        // Return a regular paragraph there is nothing fancy here
        let lines = self.newlineOffsets.enumerated().filter { _, o in range.contains(o) }
        if lines.count == 0 {
            return NSTextParagraph(attributedString: originalText)
        }

        let mutableText = NSMutableAttributedString(attributedString: originalText)
        for (i, o) in lines {
            let offset = o - range.location
            guard let view = self.results[i + 1] else {
                continue
            }
            print(mutableText.string.debugDescription, ":", offset, "line", i+1)
            let attachment = CodeAttachment(view: view)
            let attrString = NSAttributedString(attachment: attachment)
//            let attrString = NSAttributedString(string: "🚀")

            mutableText.deleteCharacters(in: NSRange(location: offset, length: 1))
            mutableText.insert(attrString, at: offset)
        }
        
        return NSTextParagraph(attributedString: mutableText)
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
//        let begining = textContentManager.documentRange.location
//        let offset = textContentManager.offset(from: textContentManager.documentRange.location, to: location)
//        
//        // For demonstration, we'll log the offset
//        print("TextKit2 is requesting text element at offset: \(offset)")
//        
//        // location is the start of this
//        let index = self.newlineOffsets.firstIndex(where: { $0 >= offset })
//        
//        if let index, self.newlineOffsets[index] == offset {
//            // we are explicityly on an \n this is a special case
//            print("<\\n new line detected>")
//            let attString = NSAttributedString(string: "\n")
//            let pg = NSTextParagraph(attributedString: attString)
//            pg.elementRange = NSTextRange(location: location, end: location)
//            return pg
//        }
//        
//        // For everything else
//        
//        // if nil we are after the end
//        // index is the next paragraph paragraph marker
//        let range: NSRange
//        // we are not at the end
//        if let index {
//            let startOffset: Int
//            let endOffset: Int = self.newlineOffsets[index]
//            if index > 0 {
//                startOffset = self.newlineOffsets[index - 1] + 1
//            } else {
//                startOffset = 0
//            }
//            
//            // Why are these identical??? WHAT IS GOING ON WHY DON'T YOU
//            // DOCUMENT SHIT APPLE FUCK YOU
//            range = NSRange(startOffset...endOffset)
////            range = NSRange(startOffset..<endOffset)
//        } else if let last = self.newlineOffsets.last {
//            // our offset is within the last element of the string
//            range = NSRange((last + 1)..<textStorage.length)
//        } else {
//            // return the entire thing
//            range = NSRange(location: 0, length: textStorage.length)
//        }
//        
//        let attString = textStorage.attributedSubstring(from: range)
//        print(attString.string.debugDescription)
//        print("returning charecters", offset, "to", offset + range.length)
//        let pg = NSTextParagraph(attributedString: attString)
//        let start = textContentManager.location(begining, offsetBy: range.lowerBound)!
//        let end = textContentManager.location(begining, offsetBy: range.upperBound)
//        pg.elementRange = NSTextRange(location: start, end: end)
//        return pg
//    }

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
