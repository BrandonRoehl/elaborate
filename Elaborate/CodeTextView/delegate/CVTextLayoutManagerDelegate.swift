//
//  CVTextLayoutManagerDelegate.swift
//  elaborate
//

import SwiftUI

extension CVCoordinator: @MainActor NSTextLayoutManagerDelegate {
    /// Keep result attachments on their own lines. The attachment replaces a
    /// newline in the displayed paragraph, so restore the wrapping boundary
    /// that the newline would otherwise provide on both sides of it.
    public func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        shouldBreakLineBefore location: any NSTextLocation,
        hyphenating: Bool
    ) -> Bool {
        guard
            let contentStorage = textLayoutManager.textContentManager as? NSTextContentStorage,
            let textStorage = contentStorage.textStorage
        else {
            return false
        }

        let offset = contentStorage.offset(from: contentStorage.documentRange.location, to: location)
        let text = textStorage.string as NSString
        return self.isResultNewline(at: offset, in: text)
            || self.isResultNewline(at: offset - 1, in: text)
    }

    private func isResultNewline(at offset: Int, in text: NSString) -> Bool {
        guard
            offset >= 0,
            offset < text.length,
            text.character(at: offset) == 0x0A
        else {
            return false
        }
        return self.hosts[self.lineIndex.lineNumber(at: offset)] != nil
    }
}
