//
//  CodeViewCoordinator.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import Foundation
import SwiftUI
import os

/** Push `NSTextContentStorage` changes through `NSTextContentManager`
`NSTextContentManager.performEditingTransaction(_ transaction: () -> Void)`
*/

public class CVCoordinator: NSObject {
    static let logger = Logger(subsystem: "elb", category: "coordinator")
    
    let textStorage: NSTextStorage
    let textContainer: NSTextContainer
    let textLayoutManager: NSLayoutManager

    var text: Binding<String>
    var lineHeight: Binding<[CGFloat]>?

    var exclusionPaths: [CGRect] = [] {
        didSet {
#if os(macOS)
            self.textContainer.exclusionPaths = self.exclusionPaths.map(NSBezierPath.init(rect:))
#else
            self.textContainer.exclusionPaths = self.exclusionPaths.map(UIBezierPath.init(rect:))
#endif
        }
    }

    @MainActor init(_ codeView: borrowing CodeTextView) {
        // Set to defaults to void dump until we get an initialized binding
        self.text = codeView.text

        // Initilize the container first
        self.textStorage = NSTextStorage()
        self.textContainer = NSTextContainer()
        self.textLayoutManager = NSLayoutManager()

        super.init()

        // MARK: NSTextStorageDelegate
        self.textStorage.delegate = self
        // Update the text container
        self.textStorage.addLayoutManager(self.textLayoutManager)
        self.textContainer.replaceLayoutManager(self.textLayoutManager)
        // At the end refresh the contents
        self.update(codeView)
    }

    @MainActor func update(_ codeView: borrowing CodeTextView) {
        self.text = codeView.text
        self.lineHeight = codeView.lineHeight
        // Thse have to be sorted before they are set
        self.exclusionPaths = codeView.exclusionPaths.sorted { $0.minY < $1.minY }

        // TODO: this check is very slow and also dumb but I don't have time
        if self.text.wrappedValue != self.textStorage.string {
            let attrString = NSAttributedString(string: self.text.wrappedValue)
            self.textStorage.setAttributedString(attrString)
        }
    }
    
    var newlineOffsets: [Int] = []
    
    @MainActor func syncHeights() {
        guard let lineHeights = self.lineHeight else {
            return
        }
        // let to prevent accidental modification
        let offsets = self.newlineOffsets
        var heights: [CGFloat] = []

        let documentRange = NSRange(location: 0, length: self.textStorage.length)
        var line: Int = 0
        self.textLayoutManager.enumerateLineFragments(forGlyphRange: documentRange) {
            rect, usedRect, textContainer, glyphRange, stop in
            while line < offsets.count && offsets[line] < glyphRange.location {
                line += 1
            }
            
            if heights.count < line + 1 {
                heights.append(contentsOf: Array(repeating: 0, count: line - heights.count + 1))
            }
            
            heights[line] += ((rect.height * 100).rounded(.awayFromZero) / 100)
        }
        if lineHeights.wrappedValue != heights {
            lineHeights.wrappedValue = heights
        }
    }
}


extension CodeTextView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
