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

        // Add in the new paragraph markers
        Task.detached {
            @MainActor [
                text = self.text,
                newText = textStorage.string,
                sync = self.syncHeights,
            ] in
            if text.wrappedValue != newText {
                text.wrappedValue = newText
            }
            sync()
        }
    }
}
