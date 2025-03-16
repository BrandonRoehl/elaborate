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

extension CodeViewCoordinator: NSTextStorageDelegate {
    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        
        // Hate to do this but keep track of the ranges of each paragraph
        var paragraphRanges: [NSRange] = []
        var currentLocation = 0
        while currentLocation < textStorage.length {
            // Get the effective paragraph style at the current location
            var range = NSRange(location: currentLocation, length: 0)
            let paragraphStyle = textStorage.attribute(.paragraphStyle, at: currentLocation, effectiveRange: &range) as? NSParagraphStyle
            
            // Add the range to our collection
            paragraphRanges.append(range)
            
            // Move to the next paragraph
            currentLocation = NSMaxRange(range)
        }
        self.paragraphRanges = paragraphRanges

        guard self.editing.try() else { return }
        // Yes this unlocks before the task finishes. That is fine we just need
        // to ensure its on the queue and then unlock it
        defer { self.editing.unlock() }

        Task { @MainActor [binding = self.text, text = textStorage.string] in
            self.performSuppressedEditingTransaction {
                binding.wrappedValue = text
            }
        }
    }
}
