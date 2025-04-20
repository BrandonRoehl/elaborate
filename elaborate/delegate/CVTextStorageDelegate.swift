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

extension CVCoordinator: @preconcurrency NSTextStorageDelegate {
    @MainActor public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: OSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        
        let text = textStorage.string
        
        // Hate to do this but keep track of the ranges of each paragraph
        var paragraphRanges: [NSRange] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byParagraphs) { (substring, substringRange, enclosingRange, stop) in
            // Convert Swift range to NSRange
            let nsRange = NSRange(enclosingRange, in: text)
            paragraphRanges.append(nsRange)
        }
        self.paragraphRanges = paragraphRanges
    }
}
