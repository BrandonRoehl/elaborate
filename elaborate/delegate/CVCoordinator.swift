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

//struct BindingUpdates: OptionSet {
//    let rawValue: Int8
//
//    static let text = BindingUpdates(rawValue: 1 << 0)
//    static let results = BindingUpdates(rawValue: 1 << 1)
//
//    static let all: BindingUpdates = [.text, .results]
//}

public class CVCoordinator: NSObject {
    let textStorage: NSTextStorage
    let textContainer: NSTextContainer
    let textLayoutManager: NSTextLayoutManager
    let textContentStorage: NSTextContentStorage

    var text: Binding<String>
    var results: [Int: OSView]
   
    var exclusionPaths: [NSRect] = [] {
        didSet {
            self.textContainer.exclusionPaths = self.exclusionPaths.map(NSBezierPath.init(rect:))
        }
    }

    @MainActor init<T>(_ codeView: borrowing CodeView<T>) {
        // Set to defaults to void dump until we get an initialized binding
        self.text = codeView.$text
        self.results = [:]

        // Initilize the container first
        self.textStorage = NSTextStorage()
        self.textContainer = NSTextContainer()
        self.textLayoutManager = NSTextLayoutManager()
        self.textContentStorage = NSTextContentStorage()

//        self.textContainer.exclusionPaths = self.exclusionPaths.map(NSBezierPath.init(rect:))
//        self.exclusionPaths = [NSRect(x: 0, y: 16, width: CGFloat.greatestFiniteMagnitude, height: 100)]

        super.init()

        // MARK: NSTextStorageDelegate
        self.textStorage.delegate = self

        // MARK: NSTextLayoutManagerDelegate
//        self.textLayoutManager.delegate = self

        // MARK: NSTextContentStorageDelegate
//        self.textContentStorage.delegate = self
        self.textContentStorage.textStorage = self.textStorage
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)

        // Update the text container
        self.textLayoutManager.textContainer = self.textContainer
        
        // TODO: REMOVE
//        self.textStorage.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
//        self.textStorage.foregroundColor = .labelColor
//        self.textStorage.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        // At the end refresh the contents
        self.update(codeView)
    }

    @MainActor func update<T>(_ codeView: borrowing CodeView<T>) {
        self.exclusionPaths = [NSRect(x: 0, y: 16, width: CGFloat.greatestFiniteMagnitude, height: 100)]

        self.text = codeView.$text
//        let newResults = codeView.results.mapValues { $0.platformView() }
//        defer { self.results = newResults }
        
        self.results = codeView.results.mapValues { $0.platformView() }
        // Mark edit for the specific chars that need to be updated
//        var lines: Set<Int> = Set(newResults.keys)
//        lines.formUnion(self.results.keys)
//        for lineNumber in lines {
//        let begining = self.textLayoutManager.documentRange.location
//        for offset in self.newlineOffsets.reversed() {
////            guard self.newlineOffsets.count > lineNumber - 1 else {
////                continue
////            }
////            
////            let offset = self.newlineOffsets[lineNumber - 1]
////            self.textStorage.beginEditing()
//            self.textStorage.edited(.editedCharacters, range: NSRange(location: offset, length: 1), changeInLength: 0)
//            guard let loc = self.textLayoutManager.location(begining, offsetBy: offset) else {
//                continue
//            }
//            self.textLayoutManager.invalidateLayout(for: NSTextRange(location: loc))
//        }
        // relayout

        // TODO: this check is very slow and also dumb but I don't have time
        // to figure out the correct way to do this
        if self.text.wrappedValue != self.textStorage.string {
            self.textContentStorage.performEditingTransaction {
                self.textStorage.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
                self.textStorage.foregroundColor = .labelColor
                self.textStorage.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            }
        }
    }
    
    var newlineOffsets: [Int] = []
    
    func syncHeights() {
        guard let layout = self.textContainer.layoutManager else {
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
            heights.append(height)
        }
        let lastOffset = self.textStorage.length - 1
        if lastOffset != self.newlineOffsets.last {
            let rect = layout.lineFragmentRect(forGlyphAt: lastOffset, effectiveRange: nil, withoutAdditionalLayout: false)
            heights.append(rect.maxY - runningOffset)
        }
        return
    }
}


extension CodeView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
