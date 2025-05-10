//
//  CodeViewCoordinator.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import Foundation
import SwiftUI

/** Push `NSTextContentStorage` changes through `NSTextContentManager`
`NSTextContentManager.performEditingTransaction(_ transaction: () -> Void)`
*/

public class CVCoordinator: NSObject {
    let textStorage: NSTextStorage
    let textContainer: NSTextContainer
    let textLayoutManager: NSTextLayoutManager
    let textContentStorage: NSTextContentStorage

    var text: Binding<String>
    var lineHeight: Binding<[CGFloat]>?

    var exclusionPaths: [CGRect] = [] {
        didSet {
#if os(macOS)
            self.textContainer.exclusionPaths = self.exclusionPaths.map(NSBezierPath.init(rect:))
#elseif os(iOS) || targetEnvironment(macCatalyst)
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
        self.textLayoutManager = NSTextLayoutManager()
        self.textContentStorage = NSTextContentStorage()

        super.init()

        // MARK: NSTextStorageDelegate
        self.textStorage.delegate = self

        self.textContentStorage.delegate = self
        self.textContentStorage.textStorage = self.textStorage
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)

        // Update the text container
        self.textLayoutManager.textContainer = self.textContainer

        // At the end refresh the contents
        self.update(codeView)
    }

    @MainActor func update(_ codeView: borrowing CodeTextView) {
        self.text = codeView.text
        self.lineHeight = codeView.lineHeight
        // Thse have to be sorted before they are set
        self.exclusionPaths = codeView.exclusionPaths.sorted { $0.minY < $1.minY }
        self.textLayoutManager.invalidateLayout(for: self.textLayoutManager.documentRange)

        // TODO: this check is very slow and also dumb but I don't have time
        // to figure out the correct way to do this
        if self.text.wrappedValue != self.textStorage.string {
            self.textContentStorage.performEditingTransaction {
                let attrString = NSAttributedString(string: self.text.wrappedValue)
                self.textStorage.setAttributedString(attrString)
            }
        }
    }
    
    var newlineOffsets: [Int] = []
    
    @MainActor func syncHeights() {
        guard let lineHeights = self.lineHeight else {
            return
        }
        var heights: [CGFloat] = []
        self.textLayoutManager.ensureLayout(for: self.textLayoutManager.documentRange)
        
        self.textLayoutManager.enumerateTextLayoutFragments(from: self.textLayoutManager.documentRange.location) { fragement in
            var height: CGFloat = 0
            for line in fragement.textLineFragments {
                height += line.typographicBounds.height
            }
            let rounded = (height * 10).rounded(.awayFromZero) / 10
            heights.append(rounded)
            return true
        }
#if DEBUG
        print("heights:", heights.count, heights)
#endif
        // assert(heights.allSatisfy { $0 >= 0 }, "Check your math, lines cannot have negative height")
        lineHeights.wrappedValue = heights
    }
}


extension CodeTextView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
