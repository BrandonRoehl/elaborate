//
//  CodeViewText.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/8/25.
//

#if os(macOS)
    import AppKit
    public typealias OSTextStorageEditActions = NSTextStorageEditActions
#elseif os(iOS) || targetEnvironment(macCatalyst)
    import UIKit
    public typealias OSTextStorageEditActions = NSTextStorage.EditActions
#endif

extension CVCoordinator: NSTextStorageDelegate {
    
    public func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        // The textStorage holds the string it will be and not the string it was
        // so you have to determine where we were before here
        
        // Grab how many pg markers are going to get replaced
        let startIndex = self.newlineOffsets.firstIndex(where: { newLine in
            return newLine >= editedRange.location
        }) ?? self.newlineOffsets.startIndex

        let finalIndex = self.newlineOffsets.firstIndex(where: { newLine in
            return newLine >= (editedRange.location + editedRange.length)
        }) ?? self.newlineOffsets.endIndex
        
        // Will this blow up?
        self.newlineOffsets.removeSubrange(startIndex..<finalIndex)
        
        // The string to look at for changes
        let substring = textStorage.attributedSubstring(from: editedRange)
        // construct the array of the new lineends
//        let newOffsets = (0..<substring.length).filter { i in
//            substring.string[i].isNewline
//            
//            substring.string[substring.string.ind]
//            return true
//        }.map { i in
//            return i + editedRange.location
//        }
//        let newOffsets = substring.string.indices(where: \.isNewline).ranges.flatMap { range in
//        }
        let newOffsets: [Int] = substring.string.enumerated().filter(\.element.isNewline).map { (index, char) in
            return index + editedRange.location
        }
            
        
//        var paragraphRanges: [NSRange] = []
//                text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byParagraphs) { (substring, substringRange, enclosingRange, stop) in
//                    // Convert Swift range to NSRange
//                    let nsRange = NSRange(enclosingRange, in: text)
//                    paragraphRanges.append(nsRange)
//                }
        
        self.newlineOffsets.insert(contentsOf: newOffsets, at: startIndex)
        
        print(newlineOffsets)
    }
    
    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        
        // Add in the new paragraph markers
        
        let text = textStorage.string
        Task.detached { @MainActor in
            if self.text.wrappedValue != text {
                self.text.wrappedValue = text
            }
        }
    }
}
