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
        let startIndex: Int = self.newlineOffsets.firstIndex(where: { newLine in
            return newLine >= editedRange.location
        }) ?? self.newlineOffsets.endIndex

        let finalIndex: Int
        if textStorage.length < self.newlineOffsets.last ?? 0 {
            finalIndex = self.newlineOffsets.count
        } else {
            finalIndex = self.newlineOffsets.firstIndex(where: { newLine in
                return newLine > (editedRange.location + editedRange.length)
            }) ?? self.newlineOffsets.count
        }

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
