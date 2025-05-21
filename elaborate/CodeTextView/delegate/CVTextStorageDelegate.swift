//
//  CodeViewText.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/8/25.
//

#if os(macOS)
    import AppKit
    public typealias OSTextStorageEditActions = NSTextStorageEditActions
#else
    import UIKit
    public typealias OSTextStorageEditActions = NSTextStorage.EditActions
#endif

extension CVCoordinator: NSTextStorageDelegate {
    
    public func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        // The textStorage holds the string it will be and not the string it was
        // so you have to determine where we were before here
        
#if DEBUG // these are here in this to help debug the code during development
        let text = textStorage.string
        let check: [Int] = text.enumerated().filter(\.element.isNewline).map { (index, _) in
            return index
        }
#endif
        
        // Grab how many pg markers are going to get replaced
        let startIndex: Int = self.newlineOffsets.firstIndex(where: { newLine in
            return newLine >= editedRange.lowerBound
        }) ?? self.newlineOffsets.endIndex

        let endOffset = (editedRange.upperBound - delta)
        let finalIndex = self.newlineOffsets.firstIndex(where: { newLine in
            return newLine >= endOffset
        }) ?? self.newlineOffsets.count

        // update the offset for those that are at final index
        for i in finalIndex..<self.newlineOffsets.count {
            self.newlineOffsets[i] += delta
        }

        // Remove the ones we know are bad
        self.newlineOffsets.removeSubrange(startIndex..<finalIndex)
        // The string to look at for changes
        let substring = textStorage.attributedSubstring(from: editedRange)
        // construct the array of the new lineends
        let newOffsets: [Int] = substring.string.enumerated().filter(\.element.isNewline).map { (index, _) in
            return index + editedRange.location
        }
        // Insert all the new stuff into here now
        self.newlineOffsets.insert(contentsOf: newOffsets, at: startIndex)
        
        // Good checks in dev but don't use this code in prod far to slow
        #if DEBUG
        for offset in newlineOffsets {
            let idx = text.index(text.startIndex, offsetBy: offset)
            assert(text[idx] == "\n", "our adjustments don't lead to a \n")
        }
        assert(check == newlineOffsets, "Somehow we lost count and newlines aren't aligned")
        #endif
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
            self.syncHeights()
            if self.text.wrappedValue != text {
                self.text.wrappedValue = text
            }
        }
    }
}
