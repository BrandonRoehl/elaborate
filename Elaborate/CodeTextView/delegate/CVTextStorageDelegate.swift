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
    /// Set the line endings
    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: OSTextStorageEditActions,
        range newRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }

#if DEBUG
        Self.logger.debug("range: \(newRange), changeInLength: \(delta)")
#endif
        // The textStorage holds the string it will be and not the string it was
        // so you have to determine where we were before here
        let oldRange = NSRange(location: newRange.location, length: newRange.length - delta)
        
        // Grab how many pg markers are going to get replaced
        var startIndex: Int = 0
        while startIndex < self.newlineOffsets.count, self.newlineOffsets[startIndex] < oldRange.lowerBound {
            startIndex += 1
        }
        
        var endIndex: Int = startIndex
        while endIndex < self.newlineOffsets.count, self.newlineOffsets[endIndex] < oldRange.upperBound {
            endIndex += 1
        }
        
        // update the offset for those that are at final index
        for i in endIndex..<self.newlineOffsets.count {
            self.newlineOffsets[i] += delta
        }
        
        // Remove the ones we know are bad
        self.newlineOffsets.removeSubrange(startIndex..<endIndex)
        // The string to look at for changes
        let substring = textStorage.attributedSubstring(from: newRange)
        // construct the array of the new lineends
        let newOffsets: [Int] = substring.string.enumerated().filter(\.element.isNewline).map { (index, _) in
            return index + newRange.location
        }
        // Insert all the new stuff into here now
        self.newlineOffsets.insert(contentsOf: newOffsets, at: startIndex)
 
#if DEBUG && os(macOS)
        Self.logger.debug("newline offsets: \(self.newlineOffsets)")
        for offset in self.newlineOffsets {
            assert(textStorage.characters[offset].string.first?.isNewline ?? true, "Bad offset: \(offset)")
        }
#endif
       
        // Add in the new paragraph markers
        let text = textStorage.string
        if self.text.wrappedValue != text {
            Task.detached { @MainActor in
                self.syncHeights()
                self.text.wrappedValue = text
            }
        }
    }
}
