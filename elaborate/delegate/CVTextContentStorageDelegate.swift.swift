//
//  CodeViewStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

extension CVCoordinator: NSTextContentStorageDelegate {
    // MARK: - NSTextContentStorageDelegate
    
    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard let textStorage = textContentStorage.textStorage else {
            print("TextKit2 this wasn't a text content manager")
            return nil
        }
        // Get the places to replace with a view
        let originalText = textStorage.attributedSubstring(from: range)
#if DEBUG
        print(originalText.string.debugDescription)
#endif
        let attrString = NSMutableAttributedString(attributedString: originalText)
        let attr: [NSAttributedString.Key: Any]
#if os(macOS)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: NSColor.labelColor
        ]
#elseif os(iOS) || targetEnvironment(macCatalyst)
        attr = [
            .font: OSMonoFont,
            .foregroundColor: UIColor.label
        ]
#endif
        attrString.setAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        return NSTextParagraph(attributedString: attrString)
    }
}
