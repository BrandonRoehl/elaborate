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

    @MainActor init<T>(_ codeView: borrowing CodeView<T>) {
        // Set to defaults to void dump until we get an initialized binding
        self.text = codeView.$text
        self.results = [:]

        // Initilize the container first
        self.textStorage = NSTextStorage()
        self.textContainer = NSTextContainer()
        self.textLayoutManager = NSTextLayoutManager()
        self.textContentStorage = NSTextContentStorage()
        
        super.init()

        // MARK: NSTextStorageDelegate
        self.textStorage.delegate = self

        // MARK: NSTextLayoutManagerDelegate
//        self.textLayoutManager.delegate = self

        // MARK: NSTextContentStorageDelegate
        self.textContentStorage.delegate = self
        self.textContentStorage.textStorage = self.textStorage
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)

        // Update the text container
        self.textLayoutManager.textContainer = self.textContainer
        
        // At the end refresh the contents
        self.update(codeView)
    }

    @MainActor func update<T>(_ codeView: borrowing CodeView<T>) {
        self.text = codeView.$text
        self.results = codeView.results.mapValues { $0.platformView() }
//        defer { self.results = newResults }
        
        // Make sure the selection and cursor doesn't move
        let selections = self.textLayoutManager.textSelections
        defer { self.textLayoutManager.textSelections = selections }
        
        // TODO: this check is very slow and also dumb but I don't have time
        // to figure out the correct way to do this
        if self.text.wrappedValue != self.textStorage.string {
            self.textContentStorage.performEditingTransaction {
                self.textStorage.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
                self.textStorage.foregroundColor = .labelColor
                self.textStorage.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            }
        }

//        for line in self.results.keys.sorted(by: <) {
//            let line = line + 1
//            guard line < self.paragraphRanges.count else { continue }
//            let range = self.paragraphRanges[line]
//            print("update", range)
//            self.textStorage.edited(.editedCharacters, range: range, changeInLength: 0)
//            if range.lowerBound < start {
//                start = range.lowerBound
//            }
//            if range.upperBound > end {
//                end = range.upperBound
//            }
//        }
        
    }
    
    var newlineOffsets: [Int] = []
}


extension CodeView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
