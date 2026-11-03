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

extension CVCoordinator: @MainActor NSTextStorageDelegate {
    /// Color the text
    public func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        // TODO: this very dumb but also I don't have time
        // to figure out the correct way to do this
        let attr: [NSAttributedString.Key: Any]
#if os(macOS)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: NSColor.labelColor
        ]
#else
        attr = [
            .font: OSMonoFont,
            .foregroundColor: UIColor.label
        ]
#endif
        textStorage.setAttributes(attr, range: editedRange)
    }

    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        self.invalidateLineIndex()
        self.linesDidChange()
    }
}
