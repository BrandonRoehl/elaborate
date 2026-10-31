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
        
        // Sync the plain source text (attachment characters stripped) back to
        // the binding.
        let newText = Self.undecorate(textStorage.string)
        if self.text.wrappedValue != newText {
            self.text.wrappedValue = newText
        }
        self.syncHeights()
    }
}
