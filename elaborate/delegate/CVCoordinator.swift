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

        // TODO: this check is very slow and also dumb but I don't have time
        // to figure out the correct way to do this
        if self.text.wrappedValue != self.textStorage.string {
            self.textContentStorage.performEditingTransaction {
                let attrString = NSMutableAttributedString(string: self.text.wrappedValue)
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
                self.textStorage.setAttributedString(attrString)
            }
        }
    }
    
    var newlineOffsets: [Int] = []
    
    @MainActor func syncHeights() {
        guard let lineHeights = self.lineHeight, let layout = self.textContainer.layoutManager else {
            return
        }
        var heights: [CGFloat] = []
        var runningOffset: CGFloat = 0
        var j: Int = 0
        for i in 0..<self.newlineOffsets.count {
            let offset = self.newlineOffsets[i]
            if offset > self.textStorage.length {
                continue
            }
            let rect = layout.lineFragmentRect(forGlyphAt: self.newlineOffsets[i], effectiveRange: nil, withoutAdditionalLayout: false)
            var height = rect.maxY - runningOffset
            // What
            if j < self.exclusionPaths.count && self.exclusionPaths[j].maxY <= rect.minY {
                height -= self.exclusionPaths[j].height
                j += 1
            }
            runningOffset += rect.maxY - runningOffset

            let rounded = (height * 10).rounded(.awayFromZero) / 10
            heights.append(rounded)
        }
        let lastOffset = self.textStorage.length - 1
        if lastOffset != self.newlineOffsets.last {
            let rect = layout.lineFragmentRect(forGlyphAt: lastOffset, effectiveRange: nil, withoutAdditionalLayout: false)
            heights.append(rect.maxY - runningOffset)
        }
        // for now
        print(heights)
//        assert(heights.allSatisfy { $0 >= 0 }, "Check your math, lines cannot have negative height")
        lineHeights.wrappedValue = heights
    }
}


extension CodeTextView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
