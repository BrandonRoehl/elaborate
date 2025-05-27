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
        didProcessEditing editedMask: OSTextStorageEditActions,
        range newRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        let text = textStorage.string
        // The textStorage holds the string it will be and not the string it was
        // so you have to determine where we were before here
        // these are here in this to help debug the code during development
        self.newlineOffsets = text.enumerated().filter(\.element.isNewline).map { (index, _) in
            return index
        }

        // Add in the new paragraph markers
        Task.detached { @MainActor in
            if self.text.wrappedValue != text {
                self.text.wrappedValue = text
            }
            self.syncHeights()
        }
    }
}
